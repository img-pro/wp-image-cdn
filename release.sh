#!/bin/bash

##
# Release Script for Bandwidth Saver: Image CDN
# Creates a clean WordPress.org-ready zip file
##

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the plugin directory (where this script is located)
PLUGIN_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PLUGIN_SLUG="bandwidth-saver"  # WordPress.org slug (for zip naming)
FOLDER_NAME=$(basename "${PLUGIN_DIR}")  # Current folder name (for build structure)
BUILD_DIR="/tmp/${FOLDER_NAME}"
OUTPUT_DIR="$(dirname "${PLUGIN_DIR}")"

echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  Bandwidth Saver: Image CDN - Release Build${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Extract version from main plugin file
VERSION=$(grep "^ \* Version:" "${PLUGIN_DIR}/imgpro-cdn.php" | head -1 | awk '{print $3}' | tr -d '\r\n ')
echo -e "Plugin Version: ${YELLOW}${VERSION}${NC}"
echo ""

# Clean up previous build
echo -e "${YELLOW}→${NC} Cleaning up previous build..."
rm -rf "${BUILD_DIR}"
rm -f "${OUTPUT_DIR}/${PLUGIN_SLUG}.zip"
rm -f "${OUTPUT_DIR}/${PLUGIN_SLUG}-${VERSION}.zip"

# Create fresh build directory
echo -e "${YELLOW}→${NC} Creating build directory..."
mkdir -p "${BUILD_DIR}"

# Build rsync exclusions from .distignore file
RSYNC_EXCLUDES=""
EXCLUSION_COUNT=0
if [ -f "${PLUGIN_DIR}/.distignore" ]; then
  echo -e "${YELLOW}→${NC} Reading exclusions from .distignore..."
  while IFS= read -r line || [ -n "$line" ]; do
    # Skip empty lines and comments
    if [[ ! "$line" =~ ^[[:space:]]*$ ]] && [[ ! "$line" =~ ^[[:space:]]*# ]]; then
      # Trim whitespace
      pattern=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
      RSYNC_EXCLUDES="${RSYNC_EXCLUDES} --exclude=${pattern}"
      ((EXCLUSION_COUNT++))
    fi
  done < "${PLUGIN_DIR}/.distignore"
  echo -e "  ${GREEN}✓${NC} Loaded ${EXCLUSION_COUNT} exclusion patterns"
else
  echo -e "${RED}Warning: .distignore file not found${NC}"
  echo -e "${YELLOW}→${NC} Using default exclusions..."
  RSYNC_EXCLUDES="--exclude=.git --exclude=.gitignore --exclude=.DS_Store --exclude=release.sh --exclude=*.zip"
fi

# Copy files using rsync with exclusions
echo -e "${YELLOW}→${NC} Copying plugin files..."
eval rsync -av ${RSYNC_EXCLUDES} "${PLUGIN_DIR}/" "${BUILD_DIR}/" > /dev/null

# Show what's included
echo -e "${YELLOW}→${NC} Files included in build:"
find "${BUILD_DIR}" -type f | sed "s|${BUILD_DIR}/|  • |" | sort

# Create zip file
echo ""
echo -e "${YELLOW}→${NC} Creating zip archive..."
cd /tmp
zip -r "${PLUGIN_SLUG}.zip" "${FOLDER_NAME}" > /dev/null

# Move to output directory with version
mv "/tmp/${PLUGIN_SLUG}.zip" "${OUTPUT_DIR}/${PLUGIN_SLUG}.zip"
cp "${OUTPUT_DIR}/${PLUGIN_SLUG}.zip" "${OUTPUT_DIR}/${PLUGIN_SLUG}-${VERSION}.zip"

# Get file size
FILE_SIZE=$(ls -lh "${OUTPUT_DIR}/${PLUGIN_SLUG}.zip" | awk '{print $5}')

# Clean up temp directory
rm -rf "${BUILD_DIR}"

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✓ Build complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "📦 Package: ${YELLOW}${PLUGIN_SLUG}.zip${NC}"
echo -e "📦 Versioned: ${YELLOW}${PLUGIN_SLUG}-${VERSION}.zip${NC}"
echo -e "📏 Size: ${YELLOW}${FILE_SIZE}${NC}"
echo -e "📍 Location: ${YELLOW}${OUTPUT_DIR}/${NC}"
echo ""
echo -e "${GREEN}Ready for WordPress.org submission!${NC}"
echo ""
