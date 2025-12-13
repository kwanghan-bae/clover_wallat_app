#!/bin/bash
# Render Build Script for Flutter Web
set -e # Exit immediately if a command exits with a non-zero status

# 1. Install Flutter
echo "Downloading Flutter SDK..."
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# 2. Check version
echo "Flutter version:"
flutter --version

# 3. Enable Web
flutter config --enable-web

# 4. Install dependencies
echo "Installing dependencies..."
flutter pub get

# 5. Build Web
echo "Building Flutter Web..."
# --base-href is usually / if serving from root of custom domain or standard render subdomain
flutter build web --release

echo "Build complete. Checking output directory:"
ls -F build/web

# 6. Create 404.html for SPA fallback (copies index.html)
echo "Creating 404.html for SPA routing..."
cp build/web/index.html build/web/404.html

