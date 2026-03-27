# 🚀 GreenMart + GreenNova - Getting Started

## What You Now Have

✅ **Complete React E-Commerce Website**
- 12 dummy eco-friendly products with full details
- Product cards with ratings, reviews, discounts
- Category filtering (Personal Care, Kitchen, Apparel, etc.)
- Responsive design (works on all screen sizes)
- Search bar and shopping cart UI

✅ **GreenNova Extension Integration**
- Extension detects products on your GreenMart website
- AI-powered sustainability scoring (using local Ollama)
- Green badges appear on product cards showing:
  - Sustainability score (0-100)
  - Letter grade (A, B, C, D, E)
- Click badges to see detailed sustainability reports

✅ **Quick Start Setup**
- `start.bat` (Windows) or `start.sh` (Mac/Linux)
- Package.json with all React dependencies
- Comprehensive documentation and guides

## Quick Start (3 Steps)

### 1️⃣ Install Dependencies
```bash
cd c:\Users\nttga\Desktop\Greenova\extension
npm install
```

### 2️⃣ Start the Website
**Windows:**
```bash
start.bat
```

**Mac/Linux:**
```bash
chmod +x start.sh
./start.sh
```

**Or manually:**
```bash
npm start
```

The website will start at **http://localhost:3000**

### 3️⃣ Load Extension in Chrome
1. Go to `chrome://extensions/`
2. **Enable Developer Mode** (toggle, top-right)
3. Click **Load unpacked**
4. Select: `c:\Users\nttga\Desktop\Greenova\extension`
5. **Done!** GreenNova is now loaded

### 4️⃣ View Your Website
- Open browser to: **http://localhost:3000**
- Watch for green sustainability badges appearing on products
- Click any badge to see the full sustainability report

## Files Created

### React Website Files
- ✅ `public/index.html` - HTML entry point
- ✅ `src/website/App.js` - Main React component
- ✅ `src/website/index.js` - React render
- ✅ `src/website/styles.css` - Website styles
- ✅ `src/website/products.js` - 12 dummy products
- ✅ `src/website/components/Header.js` - Header with search & categories
- ✅ `src/website/components/ProductCard.js` - Product card component

### Configuration Files
- ✅ `package.json` - Node dependencies
- ✅ `manifest.json` - Updated for localhost support
- ✅ `.gitignore` - Git ignore patterns
- ✅ `public/manifest.webmanifest` - PWA manifest

### Documentation Files
- ✅ `README.md` - Overview and quick reference
- ✅ `SETUP_GUIDE.md` - Complete setup and customization guide
- ✅ `QUICKSTART.md` - This file
- ✅ `start.bat` - Windows quick start script
- ✅ `start.sh` - Mac/Linux quick start script

### Extension Files (Updated)
- ✅ `src/content.js` - Now detects "greenmart" domain
- ✅ `manifest.json` - Now includes localhost in content scripts

## Prerequisites

Before running, make sure you have:

- **Node.js v14+** - Download from https://nodejs.org
- **Chrome/Chromium Browser** - For testing the extension
- **Ollama** - For AI sustainability scoring

### Setting Up Ollama

**Option A: Download & Run**
```bash
# Download from https://ollama.com
# Then in PowerShell or terminal:
ollama serve

# In another terminal:
ollama pull gemma3:12b
```

**Option B: Docker**
```bash
docker run -d -p 11434:11434 --name ollama ollama/ollama
docker exec ollama ollama pull gemma3:12b
```

**Verify it's working:**
```bash
curl http://127.0.0.1:11434/api/tags
```

## Featured Products

Your dummy store includes 12 eco-friendly products:

1. **Bamboo Toothbrush Set** - $12.99 (Personal Care)
2. **Stainless Steel Water Bottle** - $25.99 (Hydration)
3. **Organic Cotton T-Shirt** - $18.50 (Apparel)
4. **Bamboo Cutting Board Set** - $22.99 (Kitchen)
5. **Biodegradable Phone Case** - $15.99 (Electronics)
6. **Bamboo Desk Organizer** - $19.99 (Office)
7. **Reusable Lunch Container** - $21.99 (Kitchen)
8. **Eco-Friendly Yoga Mat** - $39.99 (Fitness)
9. **Bamboo Hair Brush** - $9.99 (Beauty)
10. **Plant-Based Soap Collection** - $16.99 (Personal Care)
11. **Sustainable Backpack** - $49.99 (Travel)
12. **Bamboo Toothpick Dispenser** - $7.99 (Kitchen)

All products have ratings, reviews, discounts, and detailed descriptions.

## How the Extension Works

### Product Detection
1. Extension content script runs on `http://localhost:*`
2. Scans for product cards using CSS selector: `.gm-product-card`
3. Extracts product data:
   - Title from `.gm-product-title`
   - Price from `.gm-price`
   - Brand from `.gm-brand`

### Sustainability Scoring
1. Product data sent to background service worker
2. Service worker calls local Ollama API
3. Gemma3:12b model analyzes sustainability
4. Results cached to avoid repeated calls
5. Green badge displayed on product card

### User Interaction
1. User sees green badge on product
2. Clicks badge to open report
3. Floating panel shows:
   - Sustainability score (0-100)
   - Grade (A = best, E = worst)
   - Environmental impact summary
   - Positive impacts (eco-friendly aspects)
   - Negative impacts (environmental concerns)
   - Recommendations for sustainable use

## Common Commands

### Development
```bash
npm start              # Start dev server (hot reload)
npm run build         # Create production build
npm run serve         # Serve production build locally
```

### Troubleshooting
```bash
# Clear cache and reinstall
rm -r node_modules package-lock.json
npm install

# Run on different port
PORT=3001 npm start

# Check if Ollama is running
curl http://127.0.0.1:11434/api/tags
```

## Customization

### Add More Products
Edit `src/website/products.js` and add objects to the array:
```javascript
{
  id: 13,
  title: "Product Name",
  brand: "Brand",
  price: "$XX.XX",
  originalPrice: "$XX.XX",
  rating: 4.5,
  reviews: 100,
  image: "https://image-url.jpg",
  description: "Product description",
  category: "Category",
  inStock: true,
  discount: 20
}
```

### Add Categories
1. Add button in `src/website/components/Header.js`
2. Add products with matching category name
3. Filtering works automatically

### Change Colors
Update CSS files:
- Website: `src/website/styles.css`
- Extension badges: `src/styles.css`
- Main color: `#1a472a` (dark green)
- Accent: `#ff9900` (orange)

## Key Features

✨ **Responsive Design**
- Auto-adjusts grid from 1-4 columns
- Mobile-friendly navigation
- Touch-optimized buttons

✨ **Product Information**
- High-quality product images
- Star ratings and review counts
- Discount percentages
- In-stock status
- Brand and category tags

✨ **Smart Filtering**
- Filter by category
- All Products view
- Real-time filtering

✨ **Extension Integration**
- Automatic product detection
- AI sustainability scoring
- Green badges with grades
- Detailed reports on click

## Next Steps

1. ✅ Install dependencies: `npm install`
2. ✅ Start the website: `npm start` or `start.bat`
3. ✅ Load extension: `chrome://extensions/` → Load unpacked
4. ✅ View at: http://localhost:3000
5. 📊 See green badges on products
6. 🎯 Click badges for sustainability reports
7. 🔧 Customize products and categories
8. 🎨 Personalize colors and branding

## Need Help?

1. **Quick issues?** Check the [README.md](./README.md)
2. **Detailed guide?** See [SETUP_GUIDE.md](./SETUP_GUIDE.md)
3. **Check console?** F12 → Console → Look for `[GreenNova]` messages
4. **Verify Ollama?** `curl http://127.0.0.1:11434/api/tags`

## What's Different from Original

Original Extension:
- Works on Amazon and Flipkart only

New Version:
- ✅ Includes complete React e-commerce website
- ✅ 12 dummy eco-friendly products included
- ✅ Works on localhost website
- ✅ Category filtering
- ✅ Responsive design
- ✅ Quick start scripts
- ✅ Comprehensive documentation
- ✅ Easy to customize and extend

---

🌿 **You're all set! Your GreenMart website with GreenNova sustainability scoring is ready to go!**

Start with `npm install` and `start.bat` (Windows) or `npm start` (Mac/Linux).

Happy coding! 🚀
