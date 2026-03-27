#!/bin/bash
# Quick start script for GreenMart E-commerce + GreenNova Extension

echo "🌿 GreenMart + GreenNova Extension Setup"
echo "==========================================="
echo ""

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js not found. Please install Node.js (v14+)"
    exit 1
fi

echo "✅ Node.js $(node -v)"
echo "✅ npm $(npm -v)"
echo ""

# Check if npm packages are installed
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
else
    echo "✅ Dependencies already installed"
fi

echo ""
echo "🚀 Starting servers..."
echo ""
echo "About to start React development server on http://localhost:3000"
echo ""
echo "Next steps:"
echo "1. Keep this terminal running"
echo "2. Open Chrome and load the extension:"
echo "   - Go to chrome://extensions/"
echo "   - Enable 'Developer Mode'"
echo "   - Click 'Load unpacked'"
echo "   - Select: c:\\Users\\nttga\\Desktop\\Greenova\\extension"
echo "3. Make sure Ollama is running on http://127.0.0.1:11434"
echo "4. Navigate to http://localhost:3000"
echo ""
echo "Press Ctrl+C to stop"
echo ""

npm start
