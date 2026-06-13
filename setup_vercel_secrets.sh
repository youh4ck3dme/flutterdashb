#!/usr/bin/env bash

# Vercel Secrets Setup Script for GitHub Actions.
# Uses no interactive browser auth and supports non-interactive token loading
# from env variables or a local file.

set -euo pipefail

REPO_OWNER="youh4ck3dme"
REPO_NAME="flutterdashb"
VERCEL_TOKEN_FILE="${VERCEL_TOKEN_FILE:-$HOME/Documents/secrets/rh4ck3d-vercel-ecovery-codes.txt}"
VERCEL_SCOPE="${VERCEL_SCOPE:-h4ck3d}"
NON_INTERACTIVE=false
CREATE_PROJECT=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo=*)
      IFS='/' read -r REPO_OWNER REPO_NAME <<<"${1#*=}"
      shift
      ;;
    --repo)
      IFS='/' read -r REPO_OWNER REPO_NAME <<<"$2"
      shift 2
      ;;
    --token-file=*)
      VERCEL_TOKEN_FILE="${1#*=}"
      shift
      ;;
    --no-interactive)
      NON_INTERACTIVE=true
      shift
      ;;
    --create-project)
      CREATE_PROJECT=true
      shift
      ;;
    --scope=*)
      VERCEL_SCOPE="${1#*=}"
      shift
      ;;
    --scope)
      VERCEL_SCOPE="$2"
      shift 2
      ;;
    -h|--help)
      echo "Usage: $0 [--no-interactive] [--create-project] [--repo=<owner/name>] [--scope=<team>] [--token-file=<path>]"
      exit 0
      ;;
    *)
      echo "Unknown arg: $1"
      echo "Usage: $0 [--no-interactive] [--create-project] [--repo=<owner/name>] [--scope=<team>] [--token-file=<path>]"
      exit 1
      ;;
  esac
done

REPO_FULL="$REPO_OWNER/$REPO_NAME"

if [[ "$REPO_FULL" != */* ]]; then
  echo "Invalid repo format. Use owner/name."
  exit 1
fi

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || { echo "❌ ERROR: '$1' is required."; exit 1; }
}

normalize() {
  printf '%s' "$1" | tr -d '\r\n' | tr -d '"'
}

is_valid_token() {
  [[ "$1" =~ ^(vcp_|vc_|vercel_|gho_)[A-Za-z0-9_-]+$ ]]
}

read_secret_line() {
  local prompt="$1"
  local var_name="$2"
  if [ "$NON_INTERACTIVE" = true ]; then
    return 1
  fi
  local value
  read -r -p "$prompt: " value
  printf -v "$var_name" '%s' "$(normalize "$value")"
}

extract_token_from_file() {
  local file="$1"
  [ -f "$file" ] || return 1
  local line
  while IFS= read -r line || [ -n "$line" ]; do
    line="$(normalize "$line")"
    if [[ "$line" =~ ^(vcp_|vc_|vercel_|gho_)[A-Za-z0-9_-]+$ ]]; then
      printf '%s' "$line"
      return 0
    fi
  done < "$file"
  return 1
}

resolve_org_id() {
  local token="$1"
  local response
  response="$(curl -sS -H "Authorization: Bearer $token" https://api.vercel.com/v2/user || true)"
  printf '%s' "$response" | jq -r '.user.defaultTeamId // .user.id // empty'
}

resolve_project_id() {
  local token="$1"
  local org_id="$2"
  local name="$3"
  local next_cursor=""
  local response
  local endpoint
  local project_id

  while :; do
    endpoint="https://api.vercel.com/v10/projects?limit=100"
    [ -n "$org_id" ] && endpoint+="&teamId=$org_id"
    [ -n "$next_cursor" ] && endpoint+="&until=$next_cursor"

    response="$(curl -sS -H "Authorization: Bearer $token" "$endpoint" || true)"
    project_id="$(printf '%s' "$response" | jq -r --arg name "$name" '.projects[] | select(.name == $name) | .id' | head -n 1)"
    if [ -n "$project_id" ]; then
      printf '%s' "$project_id"
      return 0
    fi

    next_cursor="$(printf '%s' "$response" | jq -r '.pagination.next // empty')"
    if [ -z "$next_cursor" ]; then
      break
    fi
  done
  printf ''
  return 0
}

print_header() {
  echo "╔═══════════════════════════════════════════════════════════════╗"
  echo "║  Vercel Secrets Setup for GitHub Actions                   ║"
  echo "║  Repository: $REPO_FULL                                    ║"
  echo "╚═══════════════════════════════════════════════════════════════╝"
  echo ""
}

set_secret() {
  local name="$1"
  local value="$2"
  printf '%s' "$value" | gh secret set "$name" --repo "$REPO_FULL"
  echo "   ✅ Set $name"
}

require_cmd gh
require_cmd jq
require_cmd curl

if ! gh auth status >/dev/null 2>&1; then
  echo "❌ ERROR: Not authenticated with GitHub CLI. Run: gh auth login"
  exit 1
fi

if [ -z "${VERCEL_TOKEN:-}" ] && [ -f "$VERCEL_TOKEN_FILE" ]; then
  VERCEL_TOKEN="$(extract_token_from_file "$VERCEL_TOKEN_FILE" || true)"
fi
if [ -z "${VERCEL_TOKEN:-}" ]; then
  read_secret_line "   VERCEL_TOKEN (from https://vercel.com/account/tokens)" VERCEL_TOKEN || true
fi
VERCEL_TOKEN="${VERCEL_TOKEN:-}"

if [ -z "$VERCEL_TOKEN" ]; then
  echo "❌ ERROR: VERCEL_TOKEN not provided."
  exit 1
fi

if ! is_valid_token "$VERCEL_TOKEN"; then
  echo "⚠️  Token has non-standard format. Continuing anyway."
fi
VERCEL_TOKEN="$(normalize "$VERCEL_TOKEN")"

if [ -z "${VERCEL_ORG_ID:-}" ]; then
  VERCEL_ORG_ID="$(resolve_org_id "$VERCEL_TOKEN")"
fi
if [ -z "${VERCEL_ORG_ID:-}" ]; then
  read_secret_line "   VERCEL_ORG_ID (from vercel whoami / token scope)" VERCEL_ORG_ID || true
fi
VERCEL_ORG_ID="${VERCEL_ORG_ID:-}"

if [ -z "${VERCEL_PROJECT_ID:-}" ] && [ -n "$VERCEL_ORG_ID" ]; then
  VERCEL_PROJECT_ID="$(resolve_project_id "$VERCEL_TOKEN" "$VERCEL_ORG_ID" "$REPO_NAME")"
fi
if [ -z "${VERCEL_PROJECT_ID:-}" ] && [ "$CREATE_PROJECT" = true ]; then
  require_cmd vercel
  echo "ℹ️  Creating Vercel project '$REPO_NAME' in scope '$VERCEL_SCOPE'..."
  vercel project add "$REPO_NAME" --scope "$VERCEL_SCOPE" --token "$VERCEL_TOKEN" --non-interactive >/dev/null
  VERCEL_PROJECT_ID="$(resolve_project_id "$VERCEL_TOKEN" "$VERCEL_ORG_ID" "$REPO_NAME")"
fi
if [ -z "${VERCEL_PROJECT_ID:-}" ]; then
  read_secret_line "   VERCEL_PROJECT_ID (from vercel projects)" VERCEL_PROJECT_ID || true
fi
VERCEL_PROJECT_ID="${VERCEL_PROJECT_ID:-}"

if [ -z "$VERCEL_ORG_ID" ] || [ -z "$VERCEL_PROJECT_ID" ]; then
  echo "❌ ERROR: Missing VERCEL_ORG_ID or VERCEL_PROJECT_ID."
  echo "   Current token may not have access to project '$REPO_NAME'."
  exit 1
fi

if [ -z "$(resolve_project_id "$VERCEL_TOKEN" "$VERCEL_ORG_ID" "$REPO_NAME")" ]; then
  echo "⚠️  INFO: project '$REPO_NAME' was not found in scope '$VERCEL_ORG_ID' via API."
fi

mkdir -p .vercel
cat > .vercel/project.json <<EOF
{
  "projectId": "$VERCEL_PROJECT_ID",
  "orgId": "$VERCEL_ORG_ID",
  "projectName": "$REPO_NAME"
}
EOF

print_header
echo "🔧 Setting GitHub Secrets..."
set_secret "VERCEL_TOKEN" "$VERCEL_TOKEN"
set_secret "VERCEL_ORG_ID" "$VERCEL_ORG_ID"
set_secret "VERCEL_PROJECT_ID" "$VERCEL_PROJECT_ID"

echo ""
echo "✅ Done."
echo "Repo: $REPO_FULL"
echo "Resolved project: $REPO_NAME ($VERCEL_PROJECT_ID)"
echo "Scope: $VERCEL_ORG_ID"
echo "Next: gh workflow run 'Flutter CI/CD + Vercel Deploy' -R $REPO_FULL"
echo "Verify: gh secret list --repo $REPO_FULL"
