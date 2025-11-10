#!/bin/bash
#
# Sync plugin from WordPress to Git repo
# Run this after making changes in WordPress
#

SOURCE="/Users/cristian/GitHub/Media-WP/wp-content/plugins/imgpro-cdn"
DEST="/Users/cristian/GitHub/wp-image-cdn"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Syncing from WordPress to Git repo...${NC}"

# Sync files
rsync -av --delete \
  --exclude='.git/' \
  --exclude='node_modules/' \
  --exclude='.DS_Store' \
  --exclude='*.log' \
  "$SOURCE/" "$DEST/"

echo -e "${GREEN}✓ Sync complete!${NC}"
echo ""
echo "Next steps:"
echo "  cd $DEST"
echo "  git status"
echo "  git add ."
echo "  git commit -m 'Your message'"
echo "  git push"
