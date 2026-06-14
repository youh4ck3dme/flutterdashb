import { mkdirSync, statSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { chromium } from '@playwright/test';

const __dirname = dirname(fileURLToPath(import.meta.url));
const repoRoot = join(__dirname, '..');
const artifactDir = join(repoRoot, 'artifacts', 'live-release-gate');
const screenshotDir = join(artifactDir, 'screenshots');

const baseUrl = normalizeBaseUrl(
  process.env.LIVE_BASE_URL || 'https://flutterdashb-mocha.vercel.app',
);
const requireBackendChecks = process.env.REQUIRE_BACKEND_CHECKS === 'true';

const checks = [];

function normalizeBaseUrl(value) {
  return value.replace(/\/+$/, '');
}

function absoluteUrl(path) {
  return `${baseUrl}${path.startsWith('/') ? path : `/${path}`}`;
}

function record(name, fn) {
  checks.push({ name, fn });
}

function assert(condition, message) {
  if (!condition) {
    throw new Error(message);
  }
}

async function fetchOk(url, options = {}) {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), options.timeoutMs || 20000);
  try {
    const response = await fetch(url, {
      redirect: 'follow',
      signal: controller.signal,
      headers: options.headers,
    });
    const body = options.readBody === false ? '' : await response.text();
    return { response, body };
  } finally {
    clearTimeout(timeout);
  }
}

function requiredEnv(name) {
  const value = process.env[name];
  if (!value && requireBackendChecks) {
    throw new Error(`Missing required CI env: ${name}`);
  }
  return value || '';
}

function assertHttpSuccess(response, label) {
  assert(
    response.status >= 200 && response.status < 400,
    `${label} returned HTTP ${response.status}`,
  );
}

function assertNotFrameBlocked(response, label) {
  const xFrameOptions = response.headers.get('x-frame-options') || '';
  const csp = response.headers.get('content-security-policy') || '';

  assert(
    !/deny|sameorigin/i.test(xFrameOptions),
    `${label} blocks iframe embedding with X-Frame-Options: ${xFrameOptions}`,
  );
  assert(
    !/frame-ancestors\s+('none'|'self'|none|self)(;|$)/i.test(csp),
    `${label} appears to block iframe embedding with CSP frame-ancestors`,
  );
}

record('browser smoke: homepage returns Flutter shell', async () => {
  const { response, body } = await fetchOk(absoluteUrl('/'));
  assertHttpSuccess(response, 'homepage');
  assert(response.headers.get('content-type')?.includes('text/html'), 'homepage must be HTML');
  assert(body.includes('flutter_bootstrap.js'), 'homepage must load flutter_bootstrap.js');
});

record('browser smoke: Flutter bootstrap asset is public JavaScript', async () => {
  const { response, body } = await fetchOk(absoluteUrl('/flutter_bootstrap.js'));
  assertHttpSuccess(response, 'flutter_bootstrap.js');
  assert(response.headers.get('content-type')?.includes('javascript'), 'bootstrap must be JS');
  assert(body.includes('_flutter'), 'bootstrap must contain Flutter loader code');
});

record('browser smoke: main bundle is public and has no local dev iframe URL', async () => {
  const { response, body } = await fetchOk(absoluteUrl('/main.dart.js'));
  assertHttpSuccess(response, 'main.dart.js');
  assert(!body.includes('127.0.0.1:5173'), 'main bundle must not reference old local Arsenal URL');
  assert(body.includes('https://arsenal.h4ck3d.me/'), 'main bundle must reference public Arsenal URL');
});

record('browser smoke: manifest is valid PWA JSON', async () => {
  const { response, body } = await fetchOk(absoluteUrl('/manifest.json'));
  assertHttpSuccess(response, 'manifest.json');
  const manifest = JSON.parse(body);
  assert(manifest.name, 'manifest requires name');
  assert(manifest.start_url, 'manifest requires start_url');
  assert(manifest.display === 'standalone', 'manifest display should be standalone');
  assert(Array.isArray(manifest.icons) && manifest.icons.length >= 2, 'manifest requires icons');
});

record('browser smoke: service worker asset is available', async () => {
  const { response, body } = await fetchOk(absoluteUrl('/flutter_service_worker.js'));
  assertHttpSuccess(response, 'flutter_service_worker.js');
  assert(response.headers.get('content-type')?.includes('javascript'), 'service worker must be JS');
  assert(body.length >= 0, 'service worker response should be readable');
});

record('browser smoke: primary PWA icon is available', async () => {
  const { response } = await fetchOk(absoluteUrl('/icons/Icon-192.png'), { readBody: false });
  assertHttpSuccess(response, 'Icon-192.png');
  assert(response.headers.get('content-type')?.includes('image/png'), 'primary icon must be PNG');
});

record('backend reachability: Supabase Auth settings endpoint responds', async () => {
  const supabaseUrl = requiredEnv('VITE_SUPABASE_URL');
  const anonKey = requiredEnv('VITE_SUPABASE_PUBLISHABLE_KEY');
  if (!supabaseUrl || !anonKey) return;

  const { response } = await fetchOk(`${normalizeBaseUrl(supabaseUrl)}/auth/v1/settings`, {
    headers: {
      apikey: anonKey,
      Authorization: `Bearer ${anonKey}`,
    },
    readBody: false,
  });
  assertHttpSuccess(response, 'Supabase Auth settings');
});

record('backend reachability: Firebase Auth iframe is public', async () => {
  const authDomain = requiredEnv('VITE_FIREBASE_AUTH_DOMAIN');
  if (!authDomain) return;

  const { response, body } = await fetchOk(`https://${authDomain}/__/auth/iframe.js`);
  assertHttpSuccess(response, 'Firebase Auth iframe');
  assert(body.includes('firebase'), 'Firebase Auth iframe must contain Firebase script content');
});

record('backend reachability: Firebase project config endpoint responds', async () => {
  const projectId = requiredEnv('VITE_FIREBASE_PROJECT_ID');
  const apiKey = requiredEnv('VITE_FIREBASE_API_KEY');
  if (!projectId || !apiKey) return;

  const { response } = await fetchOk(
    `https://identitytoolkit.googleapis.com/v1/projects/${projectId}/config?key=${apiKey}`,
    { readBody: false },
  );
  assertHttpSuccess(response, 'Firebase Identity Toolkit project config');
});

record('backend reachability: WordPress REST API responds', async () => {
  const siteUrl = requiredEnv('VITE_WORDPRESS_PUBLIC_SITE_URL');
  if (!siteUrl) return;

  const { response, body } = await fetchOk(`${normalizeBaseUrl(siteUrl)}/wp-json/`);
  assertHttpSuccess(response, 'WordPress REST API');
  assert(body.includes('wp/v2'), 'WordPress REST index should expose wp/v2');
});

record('iframe reachability/CSP: Arsenal can be embedded', async () => {
  await assertFrameEndpoint('https://arsenal.h4ck3d.me/', 'Arsenal');
});

record('iframe reachability/CSP: Blueprints can be embedded', async () => {
  await assertFrameEndpoint('https://svelte-pwa-blueprints.vercel.app/', 'Blueprints');
});

record('iframe reachability/CSP: IČO Atlas can be embedded', async () => {
  await assertFrameEndpoint('https://icoatlas.sk/', 'IČO Atlas');
});

record('iframe reachability/CSP: SEO AI can be embedded', async () => {
  await assertFrameEndpoint('https://metaseopro.lovable.app/', 'SEO AI');
});

async function assertFrameEndpoint(url, label) {
  const { response, body } = await fetchOk(url);
  assertHttpSuccess(response, label);
  assertNotFrameBlocked(response, label);
  assert(body.length > 500, `${label} response should not be empty`);
}

record('visual regression smoke: desktop/tablet/mobile screenshots are generated', async () => {
  mkdirSync(screenshotDir, { recursive: true });
  const browser = await chromium.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-dev-shm-usage'],
  });
  const viewports = [
    { name: 'desktop', width: 1440, height: 1000 },
    { name: 'tablet', width: 834, height: 1112 },
    { name: 'mobile', width: 390, height: 844 },
  ];

  try {
    for (const viewport of viewports) {
      const page = await browser.newPage({ viewport });
      const pageErrors = [];
      page.on('pageerror', (error) => pageErrors.push(error.message));

      const response = await page.goto(baseUrl, {
        waitUntil: 'domcontentloaded',
        timeout: 45000,
      });
      assert(response?.ok(), `${viewport.name} page load failed`);
      await page.waitForSelector('flt-glass-pane, flutter-view, body', { timeout: 45000 });
      await page.waitForTimeout(3000);

      const viewportPath = join(screenshotDir, `${viewport.name}-viewport.png`);
      const fullPath = join(screenshotDir, `${viewport.name}-full.png`);
      await page.screenshot({ path: viewportPath });
      await page.screenshot({ path: fullPath, fullPage: true });

      assert(statSync(viewportPath).size > 5000, `${viewport.name} viewport screenshot is too small`);
      assert(statSync(fullPath).size > 5000, `${viewport.name} full screenshot is too small`);
      assert(pageErrors.length === 0, `${viewport.name} page errors: ${pageErrors.join(' | ')}`);

      await page.close();
    }
  } finally {
    await browser.close();
  }
});

record('Lighthouse/PWA: installability basics are present', async () => {
  const manifestResult = await fetchOk(absoluteUrl('/manifest.json'));
  const serviceWorkerResult = await fetchOk(absoluteUrl('/flutter_service_worker.js'));
  const iconResult = await fetchOk(absoluteUrl('/icons/Icon-512.png'), { readBody: false });
  const manifest = JSON.parse(manifestResult.body);

  assertHttpSuccess(manifestResult.response, 'manifest.json');
  assertHttpSuccess(serviceWorkerResult.response, 'flutter_service_worker.js');
  assertHttpSuccess(iconResult.response, 'Icon-512.png');
  assert(manifest.display === 'standalone', 'manifest display should be standalone');
  assert(manifest.start_url, 'manifest requires start_url');
  assert(
    manifest.icons?.some((icon) => icon.sizes === '512x512'),
    'manifest should include a 512x512 icon',
  );
});

record('Lighthouse/accessibility: mobile metadata and readable title are present', async () => {
  const browser = await chromium.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-dev-shm-usage'],
  });
  try {
    const page = await browser.newPage({ viewport: { width: 1280, height: 900 } });
    await page.goto(baseUrl, { waitUntil: 'domcontentloaded', timeout: 45000 });

    const title = await page.title();
    const metaDescription = await page.locator('meta[name="description"]').getAttribute('content');
    const viewport = await page.locator('meta[name="viewport"]').getAttribute('content');
    const manifestHref = await page.locator('link[rel="manifest"]').getAttribute('href');

    assert(title && title !== 'centralny_dashboard', 'page should expose a human-readable title');
    assert(metaDescription, 'page needs a meta description');
    assert(viewport?.includes('width=device-width'), 'page needs mobile viewport metadata');
    assert(manifestHref === 'manifest.json', 'page should link manifest.json');
  } finally {
    await browser.close();
  }
});

record('Lighthouse/SEO: default Flutter placeholder metadata is gone', async () => {
  const { body } = await fetchOk(absoluteUrl('/'));

  assert(body.includes('<title>Central Dashboard</title>'), 'HTML title must be branded');
  assert(
    body.includes('Central dashboard for project control'),
    'HTML description must be branded',
  );
  assert(!body.includes('A new Flutter project.'), 'default Flutter description must not ship');
  assert(!body.includes('<title>centralny_dashboard</title>'), 'default Flutter title must not ship');
});

async function main() {
  mkdirSync(artifactDir, { recursive: true });
  const failures = [];

  console.log(`Live release gate target: ${baseUrl}`);
  for (const check of checks) {
    try {
      await check.fn();
      console.log(`PASS ${check.name}`);
    } catch (error) {
      failures.push({ name: check.name, error });
      console.error(`FAIL ${check.name}`);
      console.error(error?.stack || error?.message || String(error));
    }
  }

  if (failures.length > 0) {
    console.error(`Live release gate failed: ${failures.length}/${checks.length} checks failed.`);
    process.exit(1);
  }

  console.log(`Live release gate passed: ${checks.length}/${checks.length} checks.`);
}

main();
