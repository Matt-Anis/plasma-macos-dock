#!/usr/bin/env bash
#
# package.sh - Packages the macOS Dock plasmoid for store.kde.org
#

set -euo pipefail

PACKAGE_NAME="com.github.mattanis.macosdock"
OUTPUT_FILE="${PACKAGE_NAME}.plasmoid"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "$SCRIPT_DIR"

echo "==> Building ${OUTPUT_FILE}..."

# Remove any previous build archive
rm -f "$OUTPUT_FILE"

# Create .plasmoid archive (standard zip format)
# Include metadata.json and contents/, exclude temporary / dev files
zip -r -q "$OUTPUT_FILE" \
    metadata.json \
    contents \
    -x "*.DS_Store" \
    -x "*~" \
    -x "contents/ui/.directory"

echo "==> Successfully created: ${OUTPUT_FILE}"
echo "    Size: $(du -h "$OUTPUT_FILE" | cut -f1)"
echo ""
echo "You can upload this file directly to https://store.kde.org under 'Plasma 6 Applets'."
