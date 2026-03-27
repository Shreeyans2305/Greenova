# 🌿 GreenMart E-Commerce + GreenNova Extension

## Quick Summary
A complete, production-ready **React-based e-commerce website** (like Amazon/Flipkart) integrated with the **GreenNova sustainability browser extension**. The extension analyzes products and adds AI-powered sustainability scores using local Ollama.

## ⚡ Quick Start (3 steps)

### 1. Install Dependencies
```bash
npm install
```

### 2. Start the Website
```bash
# Windows
start.bat

# Mac/Linux  
chmod +x start.sh
./start.sh
# or
npm start
```

### 3. Load Extension in Chrome
1. Go to `chrome://extensions/`
2. Enable **Developer Mode** (top-right)
3. Click **Load unpacked**
4. Select: `c:\Users\nttga\Desktop\Greenova\extension`
5. Open http://localhost:3000 in Chrome

✅ **Done!** You should see green sustainability badges appearing on products!

## 🌟 What's New

✨ **Complete React E-Commerce Website** - 12 dummy eco-friendly products with full product details
✨ **GreenMart Support** - Extension now detects and scores products on `http://localhost:3000`
✨ **Quick Start Scripts** - `start.bat` and `start.sh` for easy setup
✨ **Category Filtering** - Filter products by Personal Care, Kitchen, Apparel, etc.
✨ **Responsive Design** - Works on desktop, tablet, and mobile
✨ **Comprehensive Documentation** - See [SETUP_GUIDE.md](./SETUP_GUIDE.md) for detailed customization

## 📋 Features

### E-Commerce Website
- ✅ 12 dummy eco-friendly products
- ✅ Product ratings, reviews, and descriptions
- ✅ Category filtering
- ✅ Search bar (demo)
- ✅ Responsive grid layout
- ✅ Discount badges
- ✅ In-stock indicators
- ✅ Modern dark-green branding

### GreenNova Extension
- ✅ Auto-detects products on e-commerce sites (Amazon, Flipkart, GreenMart)
- ✅ AI-powered sustainability scoring (0-100 with A-E grades)
- ✅ Green badges on product cards
- ✅ Click for detailed sustainability reports
- ✅ Local Ollama inference (no cloud calls)
- ✅ Intelligent caching
- ✅ Domain-specific settings

```
extension/
	public/
		index.html                # React entry point
		manifest.webmanifest
	src/
		website/                  # React e-commerce website
			App.js               # Main component
			index.js             # React render
			styles.css           # Website styles
			products.js          # 12 dummy products
			components/
				Header.js        # Search & categories
				ProductCard.js   # Product display
		background.js            # Extension background worker
		content.js               # Extension content script (with GreenMart support)
		styles.css               # Extension badge/panel styles
		options.html             # Settings page
		options.js               # Settings logic
	manifest.json               # Extension manifest (supports localhost)
	package.json                # Node dependencies
	.gitignore
	start.bat / start.sh         # Quick start scripts
	SETUP_GUIDE.md              # Detailed setup guide
	README.md                   # This file
```

## 🚀 Getting Started

### Prerequisites

1. **Node.js** (v14+) and npm
2. **Chrome/Chromium** browser  
3. **Ollama** with `gemma3:12b` model

### Installation Steps

**Step 1: Install Ollama**

Download from https://ollama.com/ and run:
```bash
ollama pull gemma3:12b
ollama serve
```

Or with Docker:
```bash
docker run -d -p 11434:11434 --name ollama ollama/ollama
docker exec ollama ollama pull gemma3:12b
```

**Step 2: Install Dependencies**
```bash
cd extension
npm install
```

**Step 3: Start the Website**
```bash
# Windows (easiest)
start.bat

# Mac/Linux
./start.sh

# Or manually
npm start
```

**Step 4: Load Extension**
1. Go to `chrome://extensions/`
2. Enable **Developer Mode**
3. Click **Load unpacked**
4. Select your `extension` folder
5. Open http://localhost:3000

**Step 5: See It In Action**
- Green sustainability badges should appear on product cards
- Click any badge to see the full sustainability report
- Scores come from local Ollama AI (gemma3:12b model)

## 📦 Included Products

| # | Product | Brand | Price | Category | Rating |
|---|---------|-------|-------|----------|--------|
| 1 | Bamboo Toothbrush Set | EcoDaily | $12.99 | Personal Care | 4.5 ⭐ |
| 2 | Stainless Steel Water Bottle | HydroLife | $25.99 | Hydration | 4.7 ⭐ |
| 3 | Organic Cotton T-Shirt | GreenThread | $18.50 | Apparel | 4.6 ⭐ |
| 4 | Bamboo Cutting Board Set | NaturalHome | $22.99 | Kitchen | 4.4 ⭐ |
| 5 | Biodegradable Phone Case | EcoShield | $15.99 | Electronics | 4.3 ⭐ |
| 6 | Bamboo Desk Organizer | WorkSmart | $19.99 | Office | 4.5 ⭐ |
| 7 | Reusable Lunch Container | FreshKeep | $21.99 | Kitchen | 4.6 ⭐ |
| 8 | Eco-Friendly Yoga Mat | ZenFlow | $39.99 | Fitness | 4.7 ⭐ |
| 9 | Bamboo Hair Brush | NaturalBeauty | $9.99 | Beauty | 4.4 ⭐ |
| 10 | Plant-Based Soap Collection | PureEarth | $16.99 | Personal Care | 4.5 ⭐ |
| 11 | Sustainable Backpack | AdventureGear | $49.99 | Travel | 4.6 ⭐ |
| 12 | Bamboo Toothpick Dispenser | EcoDaily | $7.99 | Kitchen | 4.2 ⭐ |

## 🔧 How It Works

1. **Website Detection**: When you visit `http://localhost:3000`, the extension's content script recognizes it
2. **Product Scanning**: Finds product cards using selectors like `.gm-product-card`
3. **Data Extraction**: Pulls title, price, brand from the product card
4. **AI Analysis**: Sends data to local Ollama (gemma3:12b model)
5. **Badge Creation**: Adds green sustainability badge to each product card
6. **Report Generation**: Click badge for detailed environmental impact analysis

## 🎨 Customization

### Add More Products
Edit `src/website/products.js`:
```javascript
{
  id: 13,
  title: "Your Product",
  brand: "Brand Name",
  price: "$XX.XX",
  originalPrice: "$XX.XX",
  rating: 4.5,
  reviews: 100,
  image: "https://image-url.jpg",
  description: "Description",
  category: "Category",
  inStock: true,
  discount: 20
}
```

### Add Categories
1. Add button in `src/website/components/Header.js`
2. Products automatically filter by matching category name

### Change Colors
- Website: Edit `src/website/styles.css`
- Extension: Edit `src/styles.css`
- Primary color: `#1a472a` (dark green)
- Accent color: `#ff9900` (orange)

### Modify Product Cards
Edit `src/website/components/ProductCard.js` to show/hide fields or change layout

## 🐛 Troubleshooting

### Badges Not Appearing
```bash
# 1. Check if Ollama is running
curl http://127.0.0.1:11434/api/tags

# 2. Make sure model is installed
ollama pull gemma3:12b

# 3. Reload extension
# Go to chrome://extensions → Reload button
# Refresh http://localhost:3000 (Ctrl+F5)
```

### React App Won't Start
```bash
# Clear cache and reinstall
rm -r node_modules package-lock.json
npm install
npm start

# Use different port if 3000 busy
PORT=3001 npm start
```

### Extension Won't Load
- Verify path is correct: `c:\Users\nttga\Desktop\Greenova\extension`
- Check manifest.json exists and is valid JSON
- Look for red errors in `chrome://extensions/`
- Try: Reload → Disable → Enable

### CORS/403 Errors from Ollama
On Windows PowerShell:
```powershell
taskkill /IM ollama.exe /F
$env:OLLAMA_ORIGINS="chrome-extension://*,http://localhost,http://127.0.0.1"
ollama serve
```
Then reload extension in Chrome and refresh the page.

## 📚 More Information

- **[SETUP_GUIDE.md](./SETUP_GUIDE.md)** - Complete setup and customization guide