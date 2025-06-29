#!/bin/bash

# Deploy Storybook to GitHub Pages
# This script builds the example app for web and prepares it for GitHub Pages deployment

set -e

echo "🚀 Building Storybook for web deployment..."

# Navigate to example directory
cd example

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf build/web

# Build for web with HTML renderer for better compatibility
echo "🔨 Building web version..."
flutter build web --web-renderer html --release

# Create a .nojekyll file to prevent GitHub Pages from ignoring files starting with _
echo "📝 Creating .nojekyll file..."
touch build/web/.nojekyll

# Add a simple index redirect if needed
echo "✅ Build complete!"

echo ""
echo "📋 Next steps for GitHub Pages deployment:"
echo "1. Create a gh-pages branch if it doesn't exist:"
echo "   git checkout --orphan gh-pages"
echo "   git rm -rf ."
echo "   "
echo "2. Copy the built files:"
echo "   cp -r example/build/web/* ."
echo "   "
echo "3. Commit and push:"
echo "   git add ."
echo "   git commit -m 'Deploy Storybook to GitHub Pages'"
echo "   git push origin gh-pages"
echo "   "
echo "4. Enable GitHub Pages in your repository settings:"
echo "   - Go to Settings > Pages"
echo "   - Set source to 'Deploy from a branch'"
echo "   - Select 'gh-pages' branch and '/ (root)' folder"
echo "   "
echo "5. Your Storybook will be available at:"
echo "   https://<username>.github.io/<repository>/"