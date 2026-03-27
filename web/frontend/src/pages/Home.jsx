import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { Leaf, TrendingUp, Sparkles, Clock, Loader2 } from "lucide-react";
import SearchInput from "../components/SearchInput";
import SustainabilityScoreCard from "../components/SustainabilityScoreCard";
import IngredientBreakdown from "../components/IngredientBreakdown";
import AlternativesList from "../components/AlternativesList";
import NotificationBanner from "../components/NotificationBanner";
import { mockRecentSearches } from "../data/mockData";
import { analyzeProduct, searchProducts, fileToBase64 } from "../services/api";
import { addToHistory } from "../utils/localStorage";

export default function Home() {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [report, setReport] = useState(null);         // full analyze result
  const [searchResults, setSearchResults] = useState(null); // search results list

  const handleSearch = async (query) => {
    if (!query.trim()) return;
    setLoading(true);
    setError(null);
    setReport(null);
    setSearchResults(null);

    try {
      // First try to get a full analyze report from the backend
      const result = await analyzeProduct({ text: query });
      setReport(result);

      // Auto-add to local history
      addToHistory({
        productName: result.product_name,
        category: result.category || "General",
        score: result.score,
        quantity: 1,
      });
    } catch (err) {
      console.error("Analyze failed, trying search:", err);
      try {
        // Fallback: try search endpoint
        const searchResult = await searchProducts(query);
        setSearchResults(searchResult.results || []);
      } catch (searchErr) {
        setError(searchErr.message || "Something went wrong. Please try again.");
      }
    } finally {
      setLoading(false);
    }
  };

  const handleImageUpload = async (file) => {
    setLoading(true);
    setError(null);
    setReport(null);
    setSearchResults(null);

    try {
      const base64 = await fileToBase64(file);
      const result = await analyzeProduct({ image_b64: base64 });
      setReport(result);

      addToHistory({
        productName: result.product_name,
        category: result.category || "General",
        score: result.score,
        quantity: 1,
      });
    } catch (err) {
      setError(err.message || "Image analysis failed. Please try again.");
    } finally {
      setLoading(false);
    }
  };

  const clearResults = () => {
    setReport(null);
    setSearchResults(null);
    setError(null);
  };

  return (
    <div className="min-h-screen pt-20 pb-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-4xl mx-auto">
        {/* Hero Section */}
        <div className="text-center mb-10 animate-fade-in-up">
          <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-primary-500/10 border border-primary-500/20 mb-6">
            <Sparkles className="w-4 h-4 text-primary-400" />
            <span className="text-sm text-primary-300">AI-Powered Sustainability</span>
          </div>
          <h1 className="text-4xl sm:text-5xl font-bold mb-4">
            <span className="bg-gradient-to-r from-primary-300 via-primary-400 to-accent-400 bg-clip-text text-transparent">
              Know Your Impact.
            </span>
            <br />
            <span className="text-surface-100">Choose Better.</span>
          </h1>
          <p className="text-surface-200/50 text-lg max-w-2xl mx-auto">
            Paste ingredients, scan barcodes, or upload product labels — get instant sustainability reports powered by AI.
          </p>
        </div>

        {/* Search */}
        <div className="animate-fade-in-up stagger-1" style={{ opacity: 0 }}>
          <SearchInput onSearch={handleSearch} onImageUpload={handleImageUpload} />
        </div>

        {/* Stats Bar */}
        <div className="grid grid-cols-3 gap-4 mt-8 animate-fade-in-up stagger-2" style={{ opacity: 0 }}>
          {[
            { icon: Leaf, label: "Products Analyzed", value: "2,847" },
            { icon: TrendingUp, label: "Avg Eco Score", value: "74" },
            { icon: Sparkles, label: "Alternatives Found", value: "1,203" },
          ].map(({ icon: Icon, label, value }) => (
            <div key={label} className="glass-card-light p-4 text-center">
              <Icon className="w-5 h-5 text-primary-400 mx-auto mb-1" />
              <p className="text-xl font-bold text-surface-100">{value}</p>
              <p className="text-xs text-surface-200/40">{label}</p>
            </div>
          ))}
        </div>

        {/* Loading State */}
        {loading && (
          <div className="mt-12 text-center">
            <div className="inline-flex items-center gap-3 px-6 py-4 rounded-2xl bg-primary-500/10 border border-primary-500/20">
              <Loader2 className="w-5 h-5 text-primary-400 animate-spin" />
              <span className="text-primary-300 font-medium">Analyzing with AI...</span>
            </div>
          </div>
        )}

        {/* Error */}
        {error && (
          <div className="mt-6">
            <NotificationBanner type="warning" message={`❌ ${error}`} />
          </div>
        )}

        {/* Full Analysis Report */}
        {report && !loading && (
          <div className="mt-8 space-y-6">
            <div className="flex items-center justify-between">
              <h2 className="text-lg font-semibold text-surface-100">
                Analysis Report: {report.product_name}
              </h2>
              <button
                onClick={clearResults}
                className="text-sm text-surface-200/50 hover:text-primary-300 transition-colors"
              >
                New search
              </button>
            </div>

            {/* Score Card */}
            <SustainabilityScoreCard
              score={report.score}
              tier={report.tier}
              badge={report.badge}
              productName={`${report.product_name}${report.brand ? ` — ${report.brand}` : ""}`}
            />

            {/* Carbon Footprint */}
            <div className="glass-card p-5">
              <p className="text-xs text-surface-200/40 uppercase tracking-wider mb-1">Carbon Footprint</p>
              <p className="text-lg font-semibold text-surface-100">{report.carbon_footprint}</p>
              {report.description && (
                <p className="text-sm text-surface-200/50 mt-2">{report.description}</p>
              )}
            </div>

            {/* Ingredient Breakdown */}
            {report.ingredients_analysis && report.ingredients_analysis.length > 0 && (
              <IngredientBreakdown
                ingredients={report.ingredients_analysis.map((ing) => ({
                  name: ing.name,
                  score: ing.score,
                  impact: ing.impact,
                  sustainability: ing.sustainability,
                }))}
              />
            )}

            {/* Alternatives */}
            {report.alternatives && report.alternatives.length > 0 && (
              <AlternativesList
                alternatives={report.alternatives.map((alt) => ({
                  name: alt.name,
                  score: alt.score,
                  price: alt.price,
                  reason: alt.reason,
                }))}
              />
            )}
          </div>
        )}

        {/* Search Results (fallback if analyze returned multiple) */}
        {searchResults && !loading && (
          <div className="mt-8 space-y-4">
            <div className="flex items-center justify-between">
              <h2 className="text-lg font-semibold text-surface-100">
                Results ({searchResults.length})
              </h2>
              <button
                onClick={clearResults}
                className="text-sm text-surface-200/50 hover:text-primary-300 transition-colors"
              >
                Clear results
              </button>
            </div>
            {searchResults.map((product) => (
              <div
                key={product.id}
                onClick={() => handleSearch(product.name)}
                className="cursor-pointer hover:scale-[1.01] transition-transform duration-300"
              >
                <SustainabilityScoreCard
                  score={product.score}
                  tier={product.tier}
                  badge={product.badge}
                  productName={`${product.name}${product.brand ? ` — ${product.brand}` : ""}`}
                  compact
                />
              </div>
            ))}
          </div>
        )}

        {/* Recent Searches — only when no results */}
        {!searchResults && !report && !loading && (
          <div className="mt-8 animate-fade-in-up stagger-3" style={{ opacity: 0 }}>
            <div className="flex items-center gap-2 mb-3">
              <Clock className="w-4 h-4 text-surface-200/40" />
              <span className="text-sm text-surface-200/40">Recent Searches</span>
            </div>
            <div className="flex flex-wrap gap-2">
              {mockRecentSearches.map((term) => (
                <button
                  key={term}
                  onClick={() => handleSearch(term)}
                  className="px-4 py-2 rounded-xl bg-surface-800/50 border border-surface-700/30 text-sm text-surface-200/60 hover:text-primary-300 hover:border-primary-500/30 transition-all duration-300"
                >
                  {term}
                </button>
              ))}
            </div>
          </div>
        )}

        {/* Notification */}
        {!loading && !report && (
          <div className="mt-8 animate-fade-in-up stagger-4" style={{ opacity: 0 }}>
            <NotificationBanner
              type="success"
              message="🌍 Your average eco score this week is 78 — well above the community average of 62!"
            />
          </div>
        )}
      </div>
    </div>
  );
}
