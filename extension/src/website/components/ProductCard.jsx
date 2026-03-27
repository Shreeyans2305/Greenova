import React, { useMemo, useState } from 'react';

function makeFallbackImage(product) {
  const title = String(product.title || 'Eco Product');
  const brand = String(product.brand || 'GreenMart');
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="600" height="400" viewBox="0 0 600 400"><defs><linearGradient id="g" x1="0" y1="0" x2="1" y2="1"><stop offset="0%" stop-color="#1a472a"/><stop offset="100%" stop-color="#2d6a42"/></linearGradient></defs><rect width="600" height="400" fill="url(#g)"/><circle cx="86" cy="72" r="26" fill="#ffffff22"/><text x="42" y="210" fill="#fff" font-size="30" font-family="Segoe UI, Arial" font-weight="700">${title}</text><text x="42" y="250" fill="#e3f3e8" font-size="20" font-family="Segoe UI, Arial">${brand}</text><text x="42" y="290" fill="#bde0c8" font-size="16" font-family="Segoe UI, Arial">GreenMart Demo</text></svg>`;
  return `data:image/svg+xml;charset=utf-8,${encodeURIComponent(svg)}`;
}

export const ProductCard = ({ product }) => {
  const fallbackImage = useMemo(() => makeFallbackImage(product), [product]);
  const [imgSrc, setImgSrc] = useState(fallbackImage);

  return (
    <div className="gm-product-card" data-product-id={product.id}>
      <div className="gm-product-image-container">
        <img 
          src={imgSrc}
          alt={product.title}
          className="gm-product-image"
          loading="lazy"
          onError={() => setImgSrc(fallbackImage)}
        />
        <div className="gm-discount-badge">{product.discount}% OFF</div>
      </div>
      
      <div className="gm-product-info">
        <div className="gm-brand">{product.brand}</div>
        <h3 className="gm-product-title">{product.title}</h3>
        
        <div className="gm-rating">
          <span className="gm-stars">★ {product.rating}</span>
          <span className="gm-reviews">({product.reviews} reviews)</span>
        </div>
        
        <p className="gm-description">{product.description}</p>
        
        <div className="gm-category">{product.category}</div>
        
        <div className="gm-price-section">
          <span className="gm-price">${product.price.replace('$', '')}</span>
          <span className="gm-original-price">
            <strike>${product.originalPrice.replace('$', '')}</strike>
          </span>
        </div>
        
        <div className="gm-stock-section">
          {product.inStock ? (
            <span className="gm-in-stock">✓ In Stock</span>
          ) : (
            <span className="gm-out-of-stock">Out of Stock</span>
          )}
        </div>
        
        <button className="gm-add-to-cart">Add to Cart</button>
      </div>
    </div>
  );
};

export default ProductCard;
