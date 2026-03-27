import React from 'react';

export const ProductCard = ({ product }) => {
  return (
    <div className="gm-product-card" data-product-id={product.id}>
      <div className="gm-product-image-container">
        <img 
          src={product.image} 
          alt={product.title}
          className="gm-product-image"
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
