import { useState, useEffect } from "react";
import { Sparkles, Leaf, Package, TrendingUp, ArrowRight, Clock, Plus, CheckCircle } from "lucide-react";
import SearchInput from "../components/SearchInput";
import SustainabilityScoreCard from "../components/SustainabilityScoreCard";
import IngredientBreakdown from "../components/IngredientBreakdown";
import AlternativesList from "../components/AlternativesList";
import NotificationBanner from "../components/NotificationBanner";
import { analyzeProduct, fileToBase64 } from "../services/api";
import { addToHistory } from "../utils/localStorage";
import useAIText from "../hooks/useAIText";
import useProductContent from "../hooks/useProductContent";

export default function Home() {
  const [report, setReport] = useState(null);
  const [searchResults, setSearchResults] = useState([]);
  const [loading, setLoading] = useState(false);
  const [recentSearches, setRecentSearches] = useState([]);
  const [addedToHistory, setAddedToHistory] = useState(false);

  const t = useAIText("home");
  const pc = useProductContent();

  useEffect(() => {
    try {
      const saved = JSON.parse(localStorage.getItem("gn_recent_searches") || "[]");
      setRecentSearches(saved.slice(0, 5));
    } catch {
      // ignore
    }
  }, []);

  const saveRecentSearch = (query) => {
    const updated = [query, ...recentSearches.filter((s) => s !== query)].slice(0, 5);
    setRecentSearches(updated);
    localStorage.setItem("gn_recent_searches", JSON.stringify(updated));
  };

  const handleSearch = async (query) => {
    setLoading(true);
    setReport(null);
    setSearchResults([]);
    setAddedToHistory(false);
    saveRecentSearch(query);

    try {
      const result = await analyzeProduct({ text: query });
      setReport(result);
    } catch (err) {
      console.error("Analysis failed:", err);
    } finally {
      setLoading(false);
    }
  };

  const handleImageUpload = async (file) => {
    setLoading(true);
    setReport(null);
    setSearchResults([]);
    setAddedToHistory(false);

    try {
      const b64 = await fileToBase64(file);
      const result = await analyzeProduct({ image_b64: b64 });
      setReport(result);
    } catch (err) {
      console.error("Image analysis failed:", err);
    } finally {
      setLoading(false);
    }
  };

  const handleAddToHistory = () => {
    if (report && !addedToHistory) {
      addToHistory({
        name: report.product_name,
        brand: report.brand,
        category: report.category,
        score: report.score,
        tier: report.tier,
        carbonFootprint: report.carbon_footprint,
      });
      setAddedToHistory(true);
    }
  };

  const clearResults = () => {
    setReport(null);
    setSearchResults([]);
    setAddedToHistory(false);
  };

  return (
    <main className="max-w-4xl mx-auto px-4 pt-24 pb-16 space-y-8 animate-fade-in-up">
      {/* Hero */}
      <section className="text-center space-y-4 pt-8">
        <span className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full text-xs font-medium bg-accent-emerald/10 text-accent-emerald border border-accent-emerald/20">
          <Sparkles className="w-3 h-3" />
          {t("badge_label", "AI-Powered Sustainability")}
        </span>
        <h1 className="text-5xl sm:text-6xl font-bold leading-tight">
          <span className="bg-linear-to-r from-accent-emerald via-accent-cyan to-accent-emerald-dark bg-clip-text text-transparent">
            {t("hero_title_1", "Know Your Impact.")}
          </span>
          <br />
          <span className="text-text-main">{t("hero_title_2", "Choose Better.")}</span>
        </h1>
        <p className="text-text-muted text-lg max-w-2xl mx-auto">
          {t("hero_subtitle", "Paste ingredients, scan barcodes, or upload product labels — get instant sustainability reports powered by AI.")}
        </p>
      </section>

      {/* Stats */}
      <section className="grid grid-cols-3 gap-4">
        {[
          { icon: Package, value: "10K+", label: t("stat_products", "Products Analyzed") },
          { icon: TrendingUp, value: "85%", label: t("stat_score", "Avg Eco Score") },
          { icon: Leaf, value: "2.4K", label: t("stat_alternatives", "Alternatives Found") },
        ].map(({ icon: Icon, value, label }) => (
          <div key={label} className="glass-card p-4 text-center hover:border-accent-emerald/30 transition-all duration-300">
            <Icon className="w-5 h-5 text-accent-emerald mx-auto mb-2" />
            <div className="text-xl font-bold text-text-main">{value}</div>
            <div className="text-xs text-text-muted">{label}</div>
          </div>
        ))}
      </section>

      {/* Search */}
      <SearchInput onSearch={handleSearch} onImageUpload={handleImageUpload} />

      {/* Recent Searches */}
      {recentSearches.length > 0 && !report && !loading && (
        <div className="flex flex-wrap items-center gap-2">
          <Clock className="w-4 h-4 text-text-muted" />
          <span className="text-xs text-text-muted">{t("recent_searches", "Recent Searches")}:</span>
          {recentSearches.map((q) => (
            <button
              key={q}
              onClick={() => handleSearch(q)}
              className="px-3 py-1 rounded-full text-xs bg-card-bg/60 text-text-muted border border-text-muted/20 hover:border-accent-emerald/30 hover:text-accent-emerald transition-all"
            >
              {q}
            </button>
          ))}
        </div>
      )}

      {/* Loading */}
      {loading && (
        <div className="flex flex-col items-center justify-center py-16 space-y-4 animate-fade-in-up">
          <div className="relative">
            <div className="w-16 h-16 border-4 border-accent-emerald/20 border-t-accent-emerald rounded-full animate-spin" />
            <div className="absolute inset-0 w-16 h-16 border-4 border-transparent border-b-accent-cyan/30 rounded-full animate-spin-slow" />
          </div>
          <p className="text-text-muted text-sm">{t("loading_text", "Analyzing with AI...")}</p>
        </div>
      )}

      {/* Report */}
      {report && !loading && (
        <div className="space-y-6 animate-fade-in-up">
          {/* Notification */}
          {report.tier === "RED" && (
            <NotificationBanner
              type="warning"
              message={pc.impactWarning}
            />
          )}
          {report.tier === "GREEN" && report.score >= 85 && (
            <NotificationBanner
              type="success"
              message={t("notification", "🌍 Your average eco score this week is 78 — well above the community average of 62!")}
            />
          )}

          {/* Product Header */}
          <div className="glass-card p-6 flex items-center justify-between">
            <div>
              <h2 className="text-2xl font-bold text-text-main">{report.product_name}</h2>
              <div className="flex items-center gap-3 mt-1">
                {report.brand && <span className="text-sm text-text-muted">{report.brand}</span>}
                {report.category && (
                  <span className="text-xs px-2 py-0.5 rounded-full bg-card-bg/60 border border-text-muted/20 text-text-muted">
                    {report.category}
                  </span>
                )}
              </div>
            </div>
            <div className="flex items-center gap-2">
              <button
                onClick={handleAddToHistory}
                disabled={addedToHistory}
                className={`flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-medium transition-all duration-300 ${
                  addedToHistory
                    ? "bg-accent-emerald/20 text-accent-emerald border border-accent-emerald/30"
                    : "bg-surface-bg/60 text-text-muted border border-text-muted/20 hover:border-accent-emerald/30 hover:text-accent-emerald"
                }`}
              >
                {addedToHistory ? (
                  <>
                    <CheckCircle className="w-4 h-4" />
                    {pc.added}
                  </>
                ) : (
                  <>
                    <Plus className="w-4 h-4" />
                    {pc.addHistory}
                  </>
                )}
              </button>
            </div>
          </div>

          {/* Score Card */}
          <SustainabilityScoreCard
            score={report.score}
            tier={report.tier}
            badge={report.badge}
            carbonFootprint={report.carbon_footprint}
            description={report.description}
          />

          {/* Ingredients */}
          <IngredientBreakdown ingredients={report.ingredients_analysis} />

          {/* Alternatives */}
          <AlternativesList alternatives={report.alternatives} />

          {/* Actions */}
          <div className="flex gap-3 justify-center pt-4">
            <button
              onClick={clearResults}
              className="flex items-center gap-2 px-6 py-2.5 rounded-xl text-sm font-medium bg-surface-bg/60 text-text-muted border border-text-muted/20 hover:border-accent-emerald/30 hover:text-accent-emerald transition-all duration-300"
            >
              {pc.newSearch}
              <ArrowRight className="w-4 h-4" />
            </button>
          </div>
        </div>
      )}
    </main>
  );
}
