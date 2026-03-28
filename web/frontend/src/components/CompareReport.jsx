import { Package, Leaf, TrendingUp, TrendingDown, Minus } from "lucide-react";
import { getTierColor } from "../data/mockData";
import FactorBar from "./FactorBar";
import WinnerBanner from "./WinnerBanner";

function ProductCard({ product, label, isWinner }) {
  const tierColors = getTierColor(product.tier);
  const ScoreIcon = product.score >= 75 ? TrendingUp : product.score >= 50 ? Minus : TrendingDown;

  return (
    <div className={`glass-card p-4 relative ${
      isWinner ? "ring-2 ring-accent-emerald/50" : ""
    }`}>
      {isWinner && (
        <div className="absolute -top-2 -right-2 px-2 py-0.5 rounded-full bg-accent-emerald text-white text-xs font-medium">
          Winner
        </div>
      )}
      
      <div className="text-center mb-4">
        <span className="text-xs text-text-muted">{label}</span>
      </div>

      <div className="flex items-center gap-3 mb-4">
        <div className={`w-14 h-14 rounded-xl flex items-center justify-center ${tierColors.bg}`}>
          <Package className="w-7 h-7" style={{ color: tierColors.text }} />
        </div>
        <div className="flex-1 min-w-0 text-left">
          <h3 className="font-semibold text-text-main truncate">{product.name}</h3>
          <p className="text-sm text-text-muted">{product.brand || "Unknown Brand"}</p>
        </div>
      </div>

      <div className="grid grid-cols-2 gap-3 mb-4">
        <div className="text-center p-3 rounded-xl bg-surface-bg/40">
          <div className="text-2xl font-bold text-text-main">{product.score}</div>
          <div className="text-xs text-text-muted">Eco Score</div>
        </div>
        <div className="text-center p-3 rounded-xl bg-surface-bg/40">
          <div className="flex items-center justify-center gap-1">
            <ScoreIcon className="w-4 h-4" style={{ color: tierColors.text }} />
            <span className="text-sm font-medium" style={{ color: tierColors.text }}>
              {product.tier}
            </span>
          </div>
          <div className="text-xs text-text-muted">Tier</div>
        </div>
      </div>

      <div className="flex items-center justify-between text-sm">
        <span className="text-text-muted">Carbon Footprint</span>
        <span className="font-medium text-text-main">{product.carbon_footprint}</span>
      </div>

      {product.badge && (
        <div className="mt-3 flex justify-center">
          <span className="inline-flex items-center gap-1 px-3 py-1 rounded-full text-xs font-medium bg-accent-emerald/15 text-accent-emerald border border-accent-emerald/20">
            <Leaf className="w-3 h-3" />
            {product.badge}
          </span>
        </div>
      )}
    </div>
  );
}

export default function CompareReport({ comparison }) {
  const { winner, winnerName, summary, product1, product2, comparisonFactors } = comparison;

  const p1Wins = winner === "product1";
  const p2Wins = winner === "product2";

  return (
    <div className="space-y-6 animate-fade-in-up">
      <WinnerBanner 
        winner={winner} 
        winnerName={winnerName} 
        summary={summary} 
      />

      {/* Product Cards */}
      <div className="grid md:grid-cols-2 gap-4">
        <ProductCard 
          product={product1} 
          label="Product 1" 
          isWinner={p1Wins}
        />
        <ProductCard 
          product={product2} 
          label="Product 2" 
          isWinner={p2Wins}
        />
      </div>

      {/* Factor Comparison */}
      <div className="glass-card p-4">
        <h3 className="text-lg font-semibold text-text-main mb-4">Detailed Comparison</h3>
        <div className="space-y-1">
          {comparisonFactors?.map((factor, index) => (
            <FactorBar key={index} factor={factor} />
          ))}
        </div>
        
        {(!comparisonFactors || comparisonFactors.length === 0) && (
          <p className="text-sm text-text-muted text-center py-4">
            No detailed factors available for comparison.
          </p>
        )}
      </div>
    </div>
  );
}
