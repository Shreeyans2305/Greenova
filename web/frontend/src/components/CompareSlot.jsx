import { useState, useEffect, useRef } from "react";
import { Search, X, Package, Loader2 } from "lucide-react";
import { searchProducts } from "../services/api";
import { getTierColor } from "../data/mockData";

export default function CompareSlot({ 
  slotNumber, 
  selectedProduct, 
  onSelectProduct, 
  onClear,
  disabled = false 
}) {
  const [query, setQuery] = useState("");
  const [results, setResults] = useState([]);
  const [loading, setLoading] = useState(false);
  const [showDropdown, setShowDropdown] = useState(false);
  const [searchError, setSearchError] = useState(null);
  const inputRef = useRef(null);
  const dropdownRef = useRef(null);
  const debounceRef = useRef(null);

  useEffect(() => {
    const handleClickOutside = (e) => {
      if (dropdownRef.current && !dropdownRef.current.contains(e.target)) {
        setShowDropdown(false);
      }
    };
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  const handleSearch = async (searchQuery) => {
    if (!searchQuery.trim()) {
      setResults([]);
      setShowDropdown(false);
      return;
    }

    setLoading(true);
    setSearchError(null);

    try {
      const data = await searchProducts(searchQuery);
      setResults(data.results || []);
      setShowDropdown(true);
    } catch {
      setSearchError("Search failed. Please try again.");
      setResults([]);
    } finally {
      setLoading(false);
    }
  };

  const handleInputChange = (e) => {
    const value = e.target.value;
    setQuery(value);

    if (debounceRef.current) {
      clearTimeout(debounceRef.current);
    }

    debounceRef.current = setTimeout(() => {
      handleSearch(value);
    }, 300);
  };

  const handleSelectProduct = (product) => {
    onSelectProduct(product);
    setQuery("");
    setResults([]);
    setShowDropdown(false);
  };

  const handleClear = () => {
    onClear();
    setQuery("");
    setResults([]);
    setShowDropdown(false);
    inputRef.current?.focus();
  };

  if (selectedProduct) {
    const tierColors = getTierColor(selectedProduct.tier);
    return (
      <div className="glass-card p-4 relative">
        <button
          onClick={handleClear}
          className="absolute top-2 right-2 p-1 rounded-lg hover:bg-surface-bg/60 text-text-muted hover:text-text-main transition-colors"
          disabled={disabled}
        >
          <X className="w-4 h-4" />
        </button>
        <div className="flex items-start gap-3">
          <div className={`w-12 h-12 rounded-xl flex items-center justify-center ${tierColors.bg}`}>
            <Package className="w-6 h-6" style={{ color: tierColors.text }} />
          </div>
          <div className="flex-1 min-w-0">
            <h3 className="font-semibold text-text-main truncate">{selectedProduct.name}</h3>
            <p className="text-sm text-text-muted">{selectedProduct.brand || "Unknown Brand"}</p>
            <div className="flex items-center gap-2 mt-1">
              <span 
                className="text-xs font-medium px-2 py-0.5 rounded-full"
                style={{ color: tierColors.text, backgroundColor: tierColors.bg }}
              >
                {selectedProduct.tier}
              </span>
              <span className="text-xs text-text-muted">
                Score: {selectedProduct.score}/100
              </span>
            </div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="glass-card p-4" ref={dropdownRef}>
      <label className="block text-sm font-medium text-text-muted mb-2">
        Product {slotNumber}
      </label>
      <div className="relative">
        <div className="absolute left-3 top-1/2 -translate-y-1/2 text-text-muted">
          {loading ? (
            <Loader2 className="w-4 h-4 animate-spin" />
          ) : (
            <Search className="w-4 h-4" />
          )}
        </div>
        <input
          ref={inputRef}
          type="text"
          value={query}
          onChange={handleInputChange}
          onFocus={() => results.length > 0 && setShowDropdown(true)}
          placeholder={`Search for product ${slotNumber}...`}
          disabled={disabled}
          className="w-full pl-10 pr-4 py-2.5 rounded-xl bg-surface-bg/60 border border-text-muted/20 text-text-main placeholder:text-text-muted/50 focus:outline-none focus:border-accent-emerald/50 focus:ring-2 focus:ring-accent-emerald/20 transition-all disabled:opacity-50"
        />
      </div>

      {searchError && (
        <p className="mt-2 text-xs text-red-400">{searchError}</p>
      )}

      {showDropdown && results.length > 0 && (
        <div className="absolute z-50 mt-2 w-full max-h-64 overflow-y-auto glass-card">
          {results.map((product) => (
            <button
              key={product.id}
              onClick={() => handleSelectProduct(product)}
              disabled={disabled}
              className="w-full px-4 py-3 text-left hover:bg-surface-bg/60 transition-colors border-b border-text-muted/10 last:border-b-0"
            >
              <div className="flex items-center gap-3">
                <Package className="w-5 h-5 text-text-muted shrink-0" />
                <div className="flex-1 min-w-0">
                  <p className="font-medium text-text-main truncate">{product.name}</p>
                  <div className="flex items-center gap-2 mt-0.5">
                    <span className="text-xs text-text-muted">{product.brand}</span>
                    <span 
                      className="text-xs font-medium"
                      style={{ color: getTierColor(product.tier).text }}
                    >
                      {product.score}/100
                    </span>
                  </div>
                </div>
              </div>
            </button>
          ))}
        </div>
      )}

      {showDropdown && results.length === 0 && !loading && query.trim() && (
        <div className="mt-2 px-4 py-3 text-sm text-text-muted glass-card">
          No products found for "{query}"
        </div>
      )}
    </div>
  );
}
