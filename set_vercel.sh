#!/bin/bash
# Simple Vercel setup for GitHub Actions - just enter 3 values

echo "═══════════════════════════════════════════════════════════"
echo "  Vercel GitHub Secrets Setup"
echo "  Repo: youh4ck3dme/flutterdashb"
echo "═══════════════════════════════════════════════════════════"
echo ""

read -p "VERCEL_TOKEN (from https://vercel.com/account/tokens): " VERCEL_TOKEN
read -p "VERCEL_ORG_ID (from 'vercel whoami'): " VERCEL_ORG_ID
read -p "VERCEL_PROJECT_ID (from 'vercel projects'): " VERCEL_PROJECT_ID

echo ""
echo "Setting GitHub secrets..."

gh secret set VERCEL_TOKEN --repo youh4ck3dme/flutterdashb --body "$VERCEL_TOKEN"
gh secret set VERCEL_ORG_ID --repo youh4ck3dme/flutterdashb --body "$VERCEL_ORG_ID"
gh secret set VERCEL_PROJECT_ID --repo youh4ck3dme/flutterdashb --body "$VERCEL_PROJECT_ID"

echo ""
echo "✅ Done! Secrets set for youh4ck3dme/flutterdashb"
echo "   Deploy URL: https://flutterdashb.vercel.app"
echo "   GitHub Actions: https://github.com/youh4ck3dme/flutterdashb/actions"
