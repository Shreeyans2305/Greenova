import { useParams, useNavigate } from "react-router-dom";
import { useEffect, useState } from "react";
import { ArrowLeft, AlertTriangle, Plus, CheckCircle } from "lucide-react";
import SustainabilityScoreCard from "../components/SustainabilityScoreCard";
import IngredientBreakdown from "../components/IngredientBreakdown";
import AlternativesList from "../components/AlternativesList";
import NotificationBanner from "../components/NotificationBanner";
import { analyzeProduct } from "../services/api";
import { addToHistory } from "../utils/localStorage";
import useProductContent from "../hooks/useProductContent";

export default function ReportDetail() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [report, setReport] = useState(null);
  const [loading, setLoading] = useState(true);
  const [addedToHistory, setAddedToHistory] = useState(false);

  const pc = useProductContent();

  useEffect(() => {
    async function load() {
      setLoading(true);
      try {
        const result = await analyzeProduct({ text: decodeURIComponent(id) });
        setReport(result);
      } catch (err) {
        console.error("Failed to load report:", err);
      } finally {
        setLoading(false);
      }
    }
    load();
  }, [id]);

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

  if (loading) {
    return (
      <main className="max-w-3xl mx-auto px-4 pt-24 pb-16">
        <div className="flex flex-col items-center justify-center py-20 space-y-4 animate-fade-in-up">
          <div className="w-16 h-16 border-4 border-accent-emerald/20 border-t-accent-emerald rounded-full animate-spin" />
          <p className="text-text-muted text-sm">Loading report...</p>
        </div>
      </main>
    );
  }

  if (!report) {
    return (
      <main className="max-w-3xl mx-auto px-4 pt-24 pb-16 text-center">
        <p className="text-text-muted">Report not found.</p>
        <button
          onClick={() => navigate("/")}
          className="mt-4 text-accent-emerald hover:text-accent-emerald-dark text-sm"
        >
          {pc.backButton}
        </button>
      </main>
    );
  }

  return (
    <main className="max-w-3xl mx-auto px-4 pt-24 pb-16 space-y-6 animate-fade-in-up">
      {/* Nav */}
      <button
        onClick={() => navigate("/")}
        className="flex items-center gap-2 text-sm text-text-muted hover:text-accent-emerald transition-colors"
      >
        <ArrowLeft className="w-4 h-4" />
        {pc.backButton}
      </button>

      {/* Impact warning */}
      {report.tier === "RED" && (
        <NotificationBanner type="warning" message={pc.impactWarning} />
      )}

      {/* Product Header */}
      <div className="glass-card p-6 flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-text-main">{report.product_name}</h1>
          <div className="flex items-center gap-3 mt-1">
            {report.brand && <span className="text-sm text-text-muted">{report.brand}</span>}
            {report.category && (
              <span className="text-xs px-2 py-0.5 rounded-full bg-surface-bg border border-card-bg text-text-muted">
                {report.category}
              </span>
            )}
          </div>
        </div>
        <button
          onClick={handleAddToHistory}
          disabled={addedToHistory}
          className={`flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-medium transition-all duration-300 ${
            addedToHistory
              ? "bg-accent-emerald/20 text-accent-emerald border border-accent-emerald/30"
              : "bg-surface-bg text-text-muted border border-card-bg hover:border-accent-emerald/30 hover:text-accent-emerald"
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

      {/* Back to search */}
      <div className="flex justify-center pt-4">
        <button
          onClick={() => navigate("/")}
          className="px-6 py-2.5 rounded-xl text-sm font-medium bg-surface-bg text-text-muted border border-card-bg hover:border-accent-emerald/30 hover:text-accent-emerald transition-all duration-300"
        >
          {pc.newSearch}
        </button>
      </div>
    </main>
  );
}
