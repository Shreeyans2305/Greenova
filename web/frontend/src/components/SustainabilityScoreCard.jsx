import { getTierColor, getTierLabel } from "../data/mockData";
import { Leaf, TrendingUp, TrendingDown, Minus } from "lucide-react";

export default function SustainabilityScoreCard({ score, tier, badge, carbonFootprint, description }) {
  const tierColors = getTierColor(tier);
  const tierColor = tierColors.text;
  const tierLabel = getTierLabel(tier);

  const ScoreIcon = score >= 75 ? TrendingUp : score >= 50 ? Minus : TrendingDown;

  return (
    <div className="glass-card p-6">
      {/* Score Circle */}
      <div className="flex items-center gap-6 mb-4">
        <div className="relative w-24 h-24 shrink-0">
          <svg viewBox="0 0 100 100" className="w-full h-full -rotate-90">
            <circle cx="50" cy="50" r="42" fill="none" stroke="rgba(255,255,255,0.05)" strokeWidth="8" />
            <circle
              cx="50"
              cy="50"
              r="42"
              fill="none"
              stroke={tierColor}
              strokeWidth="8"
              strokeLinecap="round"
              strokeDasharray={`${score * 2.64} 264`}
              className="transition-all duration-1000 ease-out"
            />
          </svg>
          <div className="absolute inset-0 flex items-center justify-center">
            <div className="text-center">
              <span className="text-2xl font-bold text-text-main">{score}</span>
              <span className="text-xs text-text-muted block">/100</span>
            </div>
          </div>
        </div>

        <div className="flex-1 min-w-0">
          {badge && (
            <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-medium bg-accent-emerald/15 text-accent-emerald border border-accent-emerald/20 mb-2">
              <Leaf className="w-3 h-3" />
              {badge}
            </span>
          )}
          <div className="flex items-center gap-2 mb-1">
            <span className="text-sm font-medium" style={{ color: tierColor }}>
              {tierLabel}
            </span>
            <ScoreIcon className="w-4 h-4" style={{ color: tierColor }} />
          </div>
          <p className="text-sm text-text-muted line-clamp-2">{description}</p>
        </div>
      </div>

      {/* Carbon Footprint */}
      {carbonFootprint && (
        <div className="glass-card-light p-3 flex items-center justify-between">
          <span className="text-xs text-text-muted">Carbon Footprint</span>
          <span className="text-sm font-medium text-text-main">{carbonFootprint}</span>
        </div>
      )}
    </div>
  );
}
