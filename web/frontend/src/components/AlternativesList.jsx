import { ArrowRight, Star } from "lucide-react";
import useAIText from "../hooks/useAIText";

export default function AlternativesList({ alternatives }) {
  const t = useAIText("alternatives");

  if (!alternatives || alternatives.length === 0) {
    return (
      <div className="glass-card p-6">
        <h3 className="text-lg font-semibold text-text-main mb-3">{t("title", "Eco-Friendly Alternatives")}</h3>
        <p className="text-sm text-accent-emerald">
          {t("empty_state", "✨ This product is already a great eco choice! No better alternatives found.")}
        </p>
      </div>
    );
  }

  return (
    <div className="glass-card p-6">
      <h3 className="text-lg font-semibold text-text-main mb-4">{t("title", "Eco-Friendly Alternatives")}</h3>
      <div className="grid gap-3">
        {alternatives.map((alt, idx) => (
          <div
            key={idx}
            className="glass-card-light p-4 flex items-center justify-between group hover:border-accent-emerald/30 transition-all duration-300 cursor-pointer animate-fade-in-up"
            style={{ animationDelay: `${idx * 0.1}s`, opacity: 0 }}
          >
            <div className="flex-1">
              <div className="flex items-center gap-2">
                <span className="text-sm font-medium text-text-main">{alt.name}</span>
                <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-xs font-medium bg-accent-emerald/15 text-accent-emerald border border-accent-emerald/20">
                  <Star className="w-3 h-3" />
                  {alt.score}
                </span>
              </div>
              <p className="text-xs text-text-muted mt-1">{alt.reason}</p>
              {alt.price && (
                <span className="text-xs text-accent-cyan mt-1 inline-block">{alt.price}</span>
              )}
            </div>
            <ArrowRight className="w-4 h-4 text-text-muted group-hover:text-accent-emerald group-hover:translate-x-1 transition-all duration-300" />
          </div>
        ))}
      </div>
    </div>
  );
}
