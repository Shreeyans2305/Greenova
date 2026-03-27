import React, { useState } from 'react';
import Header from './components/Header';
import ProductCard from './components/ProductCard';
import { dummyProducts } from './products';
import './styles.css';

function App() {
  const [selectedCategory, setSelectedCategory] = useState('all');

  const filteredProducts = selectedCategory === 'all' 
    ? dummyProducts 
    : dummyProducts.filter(p => p.category === selectedCategory);

  return (
    <div className="gm-app">
      <Header onCategoryFilter={setSelectedCategory} />
      
      <div className="gm-container">
        <div className="gm-banner">
          <h1>🌱 Welcome to GreenMart</h1>
          <p>Discover eco-friendly products with sustainability scores from GreenNova Extension</p>
        </div>

        <div className="gm-products-grid">
          {filteredProducts.map(product => (
            <ProductCard key={product.id} product={product} />
          ))}
        </div>
      </div>

      <footer className="gm-footer">
        <p>© 2024 GreenMart - Eco-Friendly Shopping</p>
        <p>Powered by GreenNova Sustainability Extension</p>
      </footer>
    </div>
  );
}

export default App;
