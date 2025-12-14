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

echo "Build complete."

# 6. Prepare Publish Directory (public)
# Sometimes build/ folder is ignored or volatile. Copying to a clean 'public' folder.
rm -rf public
mkdir -p public
cp -R build/web/* public/

# 7. Create 404.html for SPA fallback
cp public/index.html public/404.html

echo "Contents of public directory:"
ls -F public/

