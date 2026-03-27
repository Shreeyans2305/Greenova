import { useParams, useNavigate, Link } from "react-router-dom";
import { ArrowLeft, Plus, Share2, Package } from "lucide-react";
import SustainabilityScoreCard from "../components/SustainabilityScoreCard";
import IngredientBreakdown from "../components/IngredientBreakdown";
import AlternativesList from "../components/AlternativesList";
import NotificationBanner from "../components/NotificationBanner";
import { mockProducts } from "../data/mockData";
import { addToHistory } from "../utils/localStorage";
import { useState } from "react";

export default function ReportDetail() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [added, setAdded] = useState(false);

  const product = mockProducts.find((p) => p.id === id) || mockProducts[0];

  const handleAddToHistory = () => {
    addToHistory({
      productName: product.name,
      category: product.category,
      score: product.score,
      quantity: 1,
    });
    setAdded(true);
    setTimeout(() => setAdded(false), 3000);
  };

  return (
    <div className="min-h-screen pt-20 pb-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-4xl mx-auto">
        {/* Back Button */}
        <button
          onClick={() => navigate(-1)}
          className="flex items-center gap-2 text-sm text-surface-200/50 hover:text-primary-300 transition-colors mb-6"
        >
          <ArrowLeft className="w-4 h-4" />
          Back to search
        </button>

        {/* Product Header */}
        <div className="animate-fade-in-up">
          <div className="flex items-center gap-3 mb-2">
            <div className="w-10 h-10 rounded-xl bg-primary-500/15 flex items-center justify-center">
              <Package className="w-5 h-5 text-primary-400" />
            </div>
            <div>
              <h1 className="text-2xl font-bold text-surface-100">{product.name}</h1>
              <p className="text-sm text-surface-200/50">{product.brand} · {product.category}</p>
            </div>
          </div>
          <p className="text-surface-200/60 text-sm mt-3 leading-relaxed">{product.description}</p>
        </div>

        {/* Score Card */}
        <div className="mt-6 animate-fade-in-up stagger-1" style={{ opacity: 0 }}>
          <SustainabilityScoreCard
            score={product.score}
            tier={product.tier}
            badge={product.badge}
            productName={product.name}
          />
        </div>

        {/* Warning for red products */}
        {product.tier === "RED" && (
          <div className="mt-4 animate-fade-in-up stagger-2" style={{ opacity: 0 }}>
            <NotificationBanner
              type="warning"
              message={`⚠️ This product has a high environmental impact (score: ${product.score}/100). Consider switching to one of the alternatives below.`}
            />
          </div>
        )}

        {/* Carbon Footprint */}
        <div className="mt-6 glass-card p-5 animate-fade-in-up stagger-2" style={{ opacity: 0 }}>
          <div className="flex items-center justify-between">
            <div>
              <p className="text-xs text-surface-200/40 uppercase tracking-wider mb-1">Carbon Footprint</p>
              <p className="text-lg font-semibold text-surface-100">{product.carbonFootprint}</p>
            </div>
            <div className="flex gap-2">
              <button
                onClick={handleAddToHistory}
                disabled={added}
                className={`flex items-center gap-2 px-4 py-2.5 rounded-xl text-sm font-medium transition-all duration-300 ${
                  added
                    ? "bg-primary-500/20 text-primary-300 border border-primary-500/30"
                    : "bg-gradient-to-r from-primary-500 to-primary-600 text-white shadow-lg shadow-primary-500/20 hover:shadow-primary-500/40 hover:from-primary-400 hover:to-primary-500"
                }`}
              >
                <Plus className="w-4 h-4" />
                {added ? "Added ✓" : "Add to History"}
              </button>
              <button className="p-2.5 rounded-xl bg-surface-800/60 border border-surface-700/30 text-surface-200/50 hover:text-primary-300 hover:border-primary-500/30 transition-all duration-300">
                <Share2 className="w-4 h-4" />
              </button>
            </div>
          </div>
        </div>

        {/* Ingredient Breakdown */}
        <div className="mt-6 animate-fade-in-up stagger-3" style={{ opacity: 0 }}>
          <IngredientBreakdown ingredients={product.ingredients} />
        </div>

        {/* Alternatives */}
        <div className="mt-6 animate-fade-in-up stagger-4" style={{ opacity: 0 }}>
          <AlternativesList alternatives={product.alternatives} />
        </div>
      </div>
    </div>
  );
}
