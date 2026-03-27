import { getTierColor } from "../data/mockData";
import { CheckCircle, AlertTriangle, XCircle } from "lucide-react";

function getImpactIcon(impact) {
  if (impact === "Very Low" || impact === "Low") return <CheckCircle className="w-4 h-4 text-primary-400" />;
  if (impact === "Moderate") return <AlertTriangle className="w-4 h-4 text-warn-400" />;
  return <XCircle className="w-4 h-4 text-danger-400" />;
}

function getScoreBarColor(score) {
  if (score >= 75) return "bg-primary-500";
  if (score >= 50) return "bg-warn-500";
  return "bg-danger-500";
}

export default function IngredientBreakdown({ ingredients }) {
  if (!ingredients || ingredients.length === 0) return null;

  return (
    <div className="glass-card p-6">
      <h3 className="text-lg font-semibold text-surface-100 mb-4">Ingredient Analysis</h3>
      <div className="space-y-3">
        {ingredients.map((ing, idx) => (
          <div
            key={idx}
            className="glass-card-light p-4 flex items-center gap-4 animate-fade-in-up"
            style={{ animationDelay: `${idx * 0.08}s`, opacity: 0 }}
          >
            {/* Impact Icon */}
            <div className="flex-shrink-0">{getImpactIcon(ing.impact)}</div>

            {/* Name + Details */}
            <div className="flex-1 min-w-0">
              <div className="flex items-center justify-between mb-1">
                <span className="text-sm font-medium text-surface-100 truncate">{ing.name}</span>
                <span className="text-xs text-surface-200/50 ml-2 flex-shrink-0">{ing.score}/100</span>
              </div>
              {/* Score Bar */}
              <div className="h-1.5 bg-surface-700/50 rounded-full overflow-hidden">
                <div
                  className={`h-full rounded-full transition-all duration-1000 ease-out ${getScoreBarColor(ing.score)}`}
                  style={{ width: `${ing.score}%` }}
                />
              </div>
              <div className="flex items-center gap-3 mt-1.5">
                <span className="text-xs text-surface-200/40">
                  Sustainability: <span className="text-surface-200/60">{ing.sustainability}</span>
                </span>
                <span className="text-xs text-surface-200/40">
                  Impact: <span className="text-surface-200/60">{ing.impact}</span>
                </span>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
