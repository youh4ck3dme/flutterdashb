#!/bin/bash

# =============================================================================
# Vercel Secrets Setup Script for GitHub Actions
# 
# This script helps you set up the required Vercel secrets for automatic deploy
# from GitHub Actions to Vercel.
#
# Requirements:
#   - GitHub CLI (gh) installed and authenticated
#   - Vercel CLI installed and authenticated
#   - Repository: youh4ck3dme/flutterdashb
#
# Usage:
#   bash setup_vercel_secrets.sh
# =============================================================================

set -e

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║  Vercel Secrets Setup for GitHub Actions                   ║"
echo "║  Repository: youh4ck3dme/flutterdashb                     ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ ERROR: GitHub CLI (gh) is not installed!"
    echo "   Install it from: https://cli.github.com/"
    exit 1
fi

# Check if user is authenticated with GitHub
if ! gh auth status &> /dev/null; then
    echo "❌ ERROR: Not authenticated with GitHub CLI!"
    echo "   Run: gh auth login"
    exit 1
fi

echo "✅ GitHub CLI is installed and authenticated"
echo ""

# Get repo info
REPO_OWNER="youh4ck3dme"
REPO_NAME="flutterdashb"
REPO_FULL="$REPO_OWNER/$REPO_NAME"

echo "📦 Repository: $REPO_FULL"
echo ""

# Function to get Vercel info
get_vercel_info() {
    echo "🔍 Getting Vercel information..."
    
    # Try to get token
    if command -v vercel &> /dev/null; then
        if vercel whoami &> /dev/null; then
            VERCEL_ORG_ID=$(vercel whoami 2>&1 | grep -oP '"id":\s*"\K[^"]+' | head -1)
            VERCEL_PROJECTS=$(vercel projects 2>&1)
            
            if echo "$VERCEL_PROJECTS" | grep -q "flutterdashb"; then
                VERCEL_PROJECT_ID=$(echo "$VERCEL_PROJECTS" | grep "flutterdashb" | grep -oP '"id":\s*"\K[^"]+' | head -1)
                echo "   ✅ Found Vercel project: flutterdashb"
                echo "   📝 ORG_ID: $VERCEL_ORG_ID"
                echo "   📝 PROJECT_ID: $VERCEL_PROJECT_ID"
            else
                echo "   ⚠️  Vercel project 'flutterdashb' not found. You'll need to create it."
                VERCEL_ORG_ID=""
                VERCEL_PROJECT_ID=""
            fi
        else
            echo "   ⚠️  Not logged in to Vercel. You'll need to provide values manually."
            VERCEL_ORG_ID=""
            VERCEL_PROJECT_ID=""
        fi
    else
        echo "   ⚠️  Vercel CLI not installed. You'll need to provide values manually."
        VERCEL_ORG_ID=""
        VERCEL_PROJECT_ID=""
    fi
}

# Try to auto-detect Vercel info
get_vercel_info
echo ""

# Ask for VERCEL_TOKEN
echo "🔑 Enter your Vercel Token"
echo "   Get it from: https://vercel.com/account/tokens"
echo "   (Must have Full Access permissions)"
read -p "   VERCEL_TOKEN: " VERCEL_TOKEN

# Validate token format
if [[ ! "$VERCEL_TOKEN" =~ ^gho_ ]]; then
    echo "   ⚠️  Token should start with 'gho_'. Did you copy it correctly?"
    read -p "   VERCEL_TOKEN: " VERCEL_TOKEN
fi

# Ask for ORG_ID if not auto-detected
if [ -z "$VERCEL_ORG_ID" ]; then
    echo ""
    echo "🏢 Enter your Vercel Organization ID"
    echo "   Get it from: vercel whoami"
    read -p "   VERCEL_ORG_ID: " VERCEL_ORG_ID
else
    echo ""
    echo "🏢 Using detected ORG_ID: $VERCEL_ORG_ID"
    read -p "   Press Enter to confirm or type new value: " ORG_INPUT
    if [ -n "$ORG_INPUT" ]; then
        VERCEL_ORG_ID="$ORG_INPUT"
    fi
fi

# Ask for PROJECT_ID if not auto-detected
if [ -z "$VERCEL_PROJECT_ID" ]; then
    echo ""
    echo "📁 Enter your Vercel Project ID"
    echo "   Get it from: vercel projects"
    read -p "   VERCEL_PROJECT_ID: " VERCEL_PROJECT_ID
else
    echo ""
    echo "📁 Using detected PROJECT_ID: $VERCEL_PROJECT_ID"
    read -p "   Press Enter to confirm or type new value: " PROJECT_INPUT
    if [ -n "$PROJECT_INPUT" ]; then
        VERCEL_PROJECT_ID="$PROJECT_INPUT"
    fi
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  Setting up GitHub Secrets for: $REPO_FULL"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Set secrets using GitHub API
set_secret() {
    local secret_name="$1"
    local secret_value="$2"
    
    echo "   Setting secret: $secret_name"
    
    # Use GitHub API to create/update secret
    # The API uses a special endpoint for repository secrets
    GH_RESPONSE=$(gh api \
        --method PUT \
        --header "Accept: application/vnd.github.v3+json" \
        "repos/$REPO_OWNER/$REPO_NAME/actions/secrets/$secret_name" \
        --field encrypted_value="$(echo -n "$secret_value" | base64)" \
        --field key_id="$(gh api repos/$REPO_OWNER/$REPO_NAME/actions/secrets/public-key | jq -r '.key_id')" \
        2>&1)
    
    # Alternative approach using gh secret command
    echo "$secret_value" | gh secret set "$secret_name" --repo "$REPO_FULL" 2>&1
    
    if [ $? -eq 0 ]; then
        echo "   ✅ Successfully set $secret_name"
    else
        echo "   ❌ Failed to set $secret_name"
        return 1
    fi
}

echo "🔧 Setting GitHub Secrets..."
echo ""

# Set each secret
set_secret "VERCEL_TOKEN" "$VERCEL_TOKEN" && \
set_secret "VERCEL_ORG_ID" "$VERCEL_ORG_ID" && \
set_secret "VERCEL_PROJECT_ID" "$VERCEL_PROJECT_ID"

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "✅ All Vercel secrets have been set up!"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "📋 Summary:"
echo "   Repository: $REPO_FULL"
echo "   VERCEL_TOKEN: $(echo $VERCEL_TOKEN | cut -c1-10)..."
echo "   VERCEL_ORG_ID: $VERCEL_ORG_ID"
echo "   VERCEL_PROJECT_ID: $VERCEL_PROJECT_ID"
echo ""
echo "🚀 Next Steps:"
echo "   1. GitHub Actions will automatically run within 5 minutes"
echo "   2. Or manually trigger: https://github.com/$REPO_FULL/actions"
echo "   3. Your dashboard will be deployed to: https://flutterdashb.vercel.app"
echo ""
echo "💡 Verify secrets:"
echo "   gh secret list --repo $REPO_FULL"
echo ""
