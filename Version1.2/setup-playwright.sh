#!/bin/bash
# ====================================================
# Setup Playwright for OpenWebUI Testing
# ====================================================

set -e

echo "======================================================"
echo "Installing Playwright Testing Framework"
echo "======================================================"
echo ""

# Check Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is required but not installed"
    exit 1
fi

echo "📦 Installing Python dependencies..."
pip3 install playwright pytest pytest-playwright python-dotenv

echo ""
echo "🌐 Installing Playwright browsers..."
playwright install chromium

echo ""
echo "✅ Playwright installed successfully!"
echo ""
echo "To run tests:"
echo "  pytest test-playwright.py --headed  # With visible browser"
echo "  pytest test-playwright.py           # Headless mode"
echo ""
