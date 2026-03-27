import React from 'react';

export const Header = ({ onCategoryFilter }) => {
  return (
    <header className="gm-header">
      <div className="gm-header-top">
        <div className="gm-logo">
          🌿 GreenMart
        </div>
        <div className="gm-search-bar">
          <input 
            type="text" 
            placeholder="Search eco-friendly products..." 
            className="gm-search-input"
          />
          <button className="gm-search-btn">Search</button>
        </div>
        <div className="gm-header-actions">
          <button className="gm-cart-btn">🛒 Cart (0)</button>
          <button className="gm-account-btn">👤 Account</button>
        </div>
      </div>
      
      <div className="gm-header-bottom">
        <div className="gm-categories">
          <button className="gm-category-btn active" onClick={() => onCategoryFilter('all')}>
            All Products
          </button>
          <button className="gm-category-btn" onClick={() => onCategoryFilter('Personal Care')}>
            Personal Care
          </button>
          <button className="gm-category-btn" onClick={() => onCategoryFilter('Kitchen')}>
            Kitchen
          </button>
          <button className="gm-category-btn" onClick={() => onCategoryFilter('Apparel')}>
            Apparel
          </button>
          <button className="gm-category-btn" onClick={() => onCategoryFilter('Electronics')}>
            Electronics
          </button>
          <button className="gm-category-btn" onClick={() => onCategoryFilter('Fitness')}>
            Fitness
          </button>
        </div>
      </div>
    </header>
  );
};

export default Header;
