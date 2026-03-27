import { getTierColor } from "../data/mockData";

export default function SustainabilityScoreCard({ score, tier, badge, productName, compact = false }) {
  const tierColor = getTierColor(tier);
  const radius = compact ? 36 : 54;
  const stroke = compact ? 5 : 7;
  const circumference = 2 * Math.PI * radius;
  const offset = circumference - (score / 100) * circumference;

  return (
    <div
      className={`glass-card p-6 flex items-center gap-6 transition-all duration-300 hover:border-primary-500/30 ${
        compact ? "p-4 gap-4" : ""
      }`}
      style={{ borderColor: tierColor.border }}
    >
      {/* Circular Score */}
      <div className="score-circle flex-shrink-0">
        <svg width={(radius + stroke) * 2} height={(radius + stroke) * 2}>
          {/* Background circle */}
          <circle
            cx={radius + stroke}
            cy={radius + stroke}
            r={radius}
            fill="none"
            stroke="rgba(255,255,255,0.06)"
            strokeWidth={stroke}
          />
          {/* Score arc */}
          <circle
            cx={radius + stroke}
            cy={radius + stroke}
            r={radius}
            fill="none"
            stroke={tierColor.text}
            strokeWidth={stroke}
            strokeLinecap="round"
            strokeDasharray={circumference}
            strokeDashoffset={offset}
            style={{ transition: "stroke-dashoffset 1s ease-out" }}
          />
        </svg>
        <div className="absolute inset-0 flex flex-col items-center justify-center">
          <span className={`font-bold ${compact ? "text-xl" : "text-3xl"}`} style={{ color: tierColor.text }}>
            {score}
          </span>
          <span className="text-[10px] text-surface-200/50 uppercase tracking-wider">score</span>
        </div>
      </div>

      {/* Info */}
      <div className="flex-1 min-w-0">
        {productName && (
          <h3 className={`font-semibold text-surface-100 truncate ${compact ? "text-sm" : "text-lg"}`}>
            {productName}
          </h3>
        )}
        <div className="flex items-center gap-2 mt-1">
          <span
            className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium border"
            style={{ backgroundColor: tierColor.bg, borderColor: tierColor.border, color: tierColor.text }}
          >
            {tier}
          </span>
          {badge && (
            <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-primary-500/10 text-primary-300 border border-primary-500/20">
              {badge}
            </span>
          )}
        </div>
      </div>
    </div>
  );
}
