# GreenMart E-Commerce Demo - Complete Setup Guide

## Overview
This is a complete React-based e-commerce website (like Amazon/Flipkart) integrated with the GreenNova browser extension. The extension adds sustainability scores to products using local Ollama AI.

## Project Structure
```
extension/
├── public/
│   └── index.html                 # React entry point
├── src/
│   ├── website/                   # React app source
│   │   ├── App.js                # Main React component
│   │   ├── index.js              # React DOM render
│   │   ├── styles.css            # Website styles
│   │   ├── products.js           # Dummy product data (12 products)
│   │   └── components/
│   │       ├── Header.js         # Header component with search & categories
│   │       └── ProductCard.js    # Individual product card component
│   ├── background.js             # Extension background service worker
│   ├── content.js                # Extension content script (modified for GreenMart)
│   ├── options.html              # Extension options page
│   ├── options.js                # Extension options script
│   └── styles.css                # Extension badge & panel styles
├── manifest.json                 # Extension manifest (updated for localhost)
├── package.json                  # Node dependencies
└── README.md                      # This file
```

## What's Included

### E-Commerce Website Features
- **Product Grid**: Responsive grid layout with 12 dummy eco-friendly products
- **Product Cards**: Detailed product information including:
  - Product images, description, brand, category
  - Price with discount percentage
  - Star ratings and review counts
  - In-stock status
  - Add to cart button
- **Header**: 
  - Search bar (demo only)
  - Category filters (Personal Care, Kitchen, Apparel, Electronics, Fitness, Travel)
  - Shopping cart and account buttons
- **Responsive Design**: Works on desktop, tablet, and mobile

### Dummy Products (12 eco-friendly products across various categories):
1. Bamboo Toothbrush Set - $12.99
2. Stainless Steel Water Bottle - $25.99
3. Organic Cotton T-Shirt - $18.50
4. Bamboo Cutting Board Set - $22.99
5. Biodegradable Phone Case - $15.99
6. Bamboo Desk Organizer - $19.99
7. Reusable Lunch Container Set - $21.99
8. Eco-Friendly Yoga Mat - $39.99
9. Bamboo Hair Brush - $9.99
10. Plant-Based Soap Collection - $16.99
11. Sustainable Backpack - $49.99
12. Bamboo Toothpick Dispenser - $7.99

### GreenNova Extension Features
- **Sustainability Scoring**: AI-powered sustainability analysis for each product
- **Score Badges**: Green badges appear on product cards showing:
  - Sustainability score (0-100)
  - Grade (A, B, C, D, E)
- **Detailed Reports**: Click badge to see:
  - Detailed sustainability analysis
  - Environmental impact assessment
  - Positive and negative impacts
  - Recommendations for eco-friendly consumption

## Prerequisites
- **Node.js** (v14+) and npm
- **Chrome/Chromium browser**
- **Ollama** (installed and running locally on http://127.0.0.1:11434)
- **Gemma3:12b model** in Ollama (for AI sustainability scoring)

### Optional: Using Ollama with Docker
```bash
docker run -d -p 11434:11434 --name ollama ollama/ollama
docker exec ollama ollama pull gemma3:12b
```

## Installation & Setup

### 1. Install Dependencies
```bash
cd c:/Users/nttga/Desktop/Greenova/extension
npm install
```

### 2. Build the React Website (Development Mode)
```bash
npm start
```
This starts the development server at `http://localhost:3000`

The React website will be served at:
- **Development**: http://localhost:3000
- **Production (after build)**: http://localhost:3000 (with `npm run serve`)

### 3. Load Extension in Chrome
1. Open Chrome and go to `chrome://extensions/`
2. Enable **Developer Mode** (top-right toggle)
3. Click **Load unpacked**
4. Navigate to `c:\Users\nttga\Desktop\Greenova\extension`
5. Select the **extension** folder and click Open
6. The GreenNova extension should now appear in your extensions list

### 4. Start Ollama (if not already running)
```bash
# Install Ollama from https://ollama.ai
# Run Ollama (stays in foreground)
ollama serve

# In another terminal, pull the model
ollama pull gemma3:12b
```

### 5. Access the Website
- Open Chrome and navigate to **http://localhost:3000**
- You should see the GreenMart e-commerce website
- Scroll through products and watch for green **GreenNova badges** appearing on product cards
- Click any badge to see the full sustainability report

## Running Different Scenarios

### Scenario 1: Full Development Mode
```bash
# Terminal 1: Start Ollama
ollama serve

# Terminal 2: Run React dev server
cd extension
npm start

# Terminal 3: Keep browser open to http://localhost:3000
# Extension automatically reloads when manifest.json changes
```

### Scenario 2: Production Build
```bash
# Build the React app for production
npm run build

# Serve the build locally
npm run serve
```

### Scenario 3: Extension Only Testing
If you want to test the extension without rebuilding React:
1. The React app will stay at http://localhost:3000
2. Just reload the extension in `chrome://extensions`
3. Refresh http://localhost:3000 in the browser

## How the Extension Works

### Content Script Injection
- The extension matches `http://localhost/*` and `http://127.0.0.1/*` URLs
- When you view http://localhost:3000, the extension's `content.js` runs
- It detects product cards using CSS selectors: `.gm-product-card`

### Product Detection
The content script looks for:
- Product cards: `.gm-product-card`
- Product title: `.gm-product-title`
- Price: `.gm-price`
- Brand: `.gm-brand`

These selectors match the GreenMart website structure perfectly.

### Sustainability Scoring
1. Extension sends product data to background service worker
2. Service worker calls local Ollama API
3. Gemma3 model generates sustainability score and grade
4. Results are cached and displayed as badges
5. Click badge to view detailed sustainability report

## Customization Guide

### Adding More Products
Edit `src/website/products.js`:
```javascript
export const dummyProducts = [
  {
    id: 13,
    title: "Your Product Title",
    brand: "Brand Name",
    price: "$XX.XX",
    originalPrice: "$XX.XX",
    rating: 4.5,
    reviews: 100,
    image: "https://image-url.com/image.jpg",
    description: "Product description",
    category: "Category Name",
    inStock: true,
    discount: 20
  },
  // ... more products
];
```

### Adding New Categories
1. Edit `src/website/components/Header.js` - add new category button
2. Category name must match the `category` field in products.js
3. Filtering happens automatically

### Changing Website Colors/Styles
- Update `src/website/styles.css` for website styling
- Update `src/styles.css` for extension badge and panel styling

### Modifying Product Card Layout
Edit `src/website/components/ProductCard.js` to change:
- Card structure
- Displayed product information
- Button labels
- Price display format

### Extending Extension Features
1. Modify `src/content.js` to add new functionality
2. Update `src/background.js` for new processing logic
3. Edit `src/options.html` and `src/options.js` for settings
4. Reload extension after changes

## Troubleshooting

### Extension not detecting products
- Check Chrome console (F12 → Console tab)
- Verify extension is loaded in `chrome://extensions`
- Ensure CSS selectors haven't changed (check HTML structure)
- Check manifest.json includes localhost patterns

### Sustainability badges not appearing
- Make sure Ollama is running (`ollama serve`)
- Verify model is installed (`ollama pull gemma3:12b`)
- Check background service worker in extension
- Look for errors in Chrome's Service Worker Console

### React app not starting
```bash
# Clear node modules and reinstall
rm -r node_modules
npm install
npm start
```

### Port 3000 already in use
```bash
# Use a different port
PORT=3001 npm start
```

### Extension not reloading
- Go to `chrome://extensions/`
- Click the reload icon on GreenNova extension
- Refresh the website tab (F5)

## Performance Tips

1. **Caching**: Sustainability scores are cached locally to avoid repeated API calls
2. **Batch Processing**: Products are processed as they become visible
3. **Lazy Loading**: Extension scores products on demand, not all at once

## API Integration Points

### Ollama API
- Endpoint: `http://127.0.0.1:11434/api/generate`
- Model: `gemma3:12b`
- Timeout: 60 seconds per request
- Temperature: 0.2 (consistent results)

### Local Storage
The extension stores:
- User preferences
- Sustainability score cache
- Domain allowlist settings

## Next Steps

1. ✅ Website is built and products are displayed
2. ✅ Extension is detecting and analyzing products
3. 🔄 Customize product data and categories to your needs
4. 📊 Add product filters or sorting
5. 🎨 Customize colors and branding
6. 🔗 Integrate with real backend API (optional)

## File Modifications Made

The following files were created/modified to enable GreenMart integration:

**Created:**
- `package.json` - React dependencies
- `public/index.html` - React entry point
- `src/website/App.js` - Main React component
- `src/website/index.js` - React DOM render
- `src/website/styles.css` - Website styles
- `src/website/products.js` - Dummy products (12 products)
- `src/website/components/Header.js` - Header component
- `src/website/components/ProductCard.js` - Product card component

**Modified:**
- `manifest.json` - Added localhost content script matching
- `src/content.js` - Added GreenMart domain detection and selectors
- `src/styles.css` - Already included, no changes needed (used for extension badges)

## Browser Compatibility
- Chrome 88+
- Chromium 88+
- Edge 88+
- Opera 74+

## License
This project is provided as-is for demonstration purposes.

## Support
For issues or questions:
1. Check the troubleshooting section above
2. Review Chrome console for error messages
3. Verify Ollama is running and accessible
4. Check extension permissions in `chrome://extensions/`

---

**Happy sustainable shopping! 🌿**
