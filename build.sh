#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Build configuration
BUILD_DIR="build"

echo -e "${GREEN} ==> Starting noVNC build process...${NC}"

# Clean previous builds
echo -e "${YELLOW} ==> Cleaning previous builds...${NC}"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Copy runtime directories
echo -e "${YELLOW} ==> Copying runtime directories...${NC}"
cp -r app "$BUILD_DIR/"
cp -r core "$BUILD_DIR/"
cp -r vendor "$BUILD_DIR/"
cp -r utils "$BUILD_DIR/"
cp -r include "$BUILD_DIR/"

# Copy main HTML files
echo -e "${YELLOW} ==> Copying HTML files...${NC}"
cp vnc.html "$BUILD_DIR/"
cp vnc_lite.html "$BUILD_DIR/"

# Create symbolic link (like apt package)
echo -e "${YELLOW} ==> Creating symbolic links...${NC}"
cd "$BUILD_DIR"
ln -sf vnc.html vnc_auto.html
cd ..

# Create final distribution
echo -e "${YELLOW} ==> Creating final distribution...${NC}"

# Display build summary
echo -e "${GREEN} ==> Build completed successfully!${NC}"
echo -e "${GREEN} ==> Distribution created in: ${BUILD_DIR}/${NC}"
echo -e "${GREEN} ==> Distribution: $(du -sh $BUILD_DIR | cut -f1)${NC}"
echo -e "${GREEN} ==> Directory structure:${NC}"
ls -la "$BUILD_DIR/"
