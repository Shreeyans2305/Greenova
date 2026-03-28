import { CheckCircle, AlertTriangle, XCircle } from "lucide-react";
import useAIText from "../hooks/useAIText";

function getImpactIcon(impact) {
  if (impact === "Very Low" || impact === "Low") return <CheckCircle className="w-4 h-4 text-accent-emerald" />;
  if (impact === "Moderate") return <AlertTriangle className="w-4 h-4 text-warn-400" />;
  return <XCircle className="w-4 h-4 text-danger-400" />;
}

function getScoreBarColor(score) {
  if (score >= 75) return "bg-accent-emerald";
  if (score >= 50) return "bg-warn-500";
  return "bg-danger-500";
}

export default function IngredientBreakdown({ ingredients }) {
  const t = useAIText("ingredients");

  if (!ingredients || ingredients.length === 0) return null;

  return (
    <div className="glass-card p-6">
      <h3 className="text-lg font-semibold text-text-main mb-4">{t("title", "Ingredient Analysis")}</h3>
      <div className="space-y-3">
        {ingredients.map((ing, idx) => (
          <div
            key={idx}
            className="glass-card-light p-4 flex items-center gap-4 animate-fade-in-up"
            style={{ animationDelay: `${idx * 0.08}s`, opacity: 0 }}
          >
            {/* Impact Icon */}
            <div className="shrink-0">{getImpactIcon(ing.impact)}</div>

            {/* Name + Details */}
            <div className="flex-1 min-w-0">
              <div className="flex items-center justify-between mb-1">
                <span className="text-sm font-medium text-text-main truncate">{ing.name}</span>
                <span className="text-xs text-text-muted ml-2 shrink-0">{ing.score}/100</span>
              </div>
              {/* Score Bar */}
              <div className="h-1.5 bg-surface-bg rounded-full overflow-hidden">
                <div
                  className={`h-full rounded-full transition-all duration-1000 ease-out ${getScoreBarColor(ing.score)}`}
                  style={{ width: `${ing.score}%` }}
                />
              </div>
              <div className="flex items-center gap-3 mt-1.5">
                <span className="text-xs text-text-muted">
                  {t("sustainability_label", "Sustainability:")} <span className="text-text-main">{ing.sustainability}</span>
                </span>
                <span className="text-xs text-text-muted">
                  {t("impact_label", "Impact:")} <span className="text-text-main">{ing.impact}</span>
                </span>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
