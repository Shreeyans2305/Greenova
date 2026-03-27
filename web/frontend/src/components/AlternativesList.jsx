import { ArrowRight, Star } from "lucide-react";

export default function AlternativesList({ alternatives }) {
  if (!alternatives || alternatives.length === 0) {
    return (
      <div className="glass-card p-6">
        <h3 className="text-lg font-semibold text-surface-100 mb-3">Eco-Friendly Alternatives</h3>
        <p className="text-sm text-primary-300/70">
          ✨ This product is already a great eco choice! No better alternatives found.
        </p>
      </div>
    );
  }

  return (
    <div className="glass-card p-6">
      <h3 className="text-lg font-semibold text-surface-100 mb-4">Eco-Friendly Alternatives</h3>
      <div className="grid gap-3">
        {alternatives.map((alt, idx) => (
          <div
            key={idx}
            className="glass-card-light p-4 flex items-center justify-between group hover:border-primary-500/30 transition-all duration-300 cursor-pointer animate-fade-in-up"
            style={{ animationDelay: `${idx * 0.1}s`, opacity: 0 }}
          >
            <div className="flex-1">
              <div className="flex items-center gap-2">
                <span className="text-sm font-medium text-surface-100">{alt.name}</span>
                <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-xs font-medium bg-primary-500/15 text-primary-300 border border-primary-500/20">
                  <Star className="w-3 h-3" />
                  {alt.score}
                </span>
              </div>
              <p className="text-xs text-surface-200/50 mt-1">{alt.reason}</p>
              {alt.price && (
                <span className="text-xs text-accent-400 mt-1 inline-block">{alt.price}</span>
              )}
            </div>
            <ArrowRight className="w-4 h-4 text-surface-200/30 group-hover:text-primary-400 group-hover:translate-x-1 transition-all duration-300" />
          </div>
        ))}
      </div>
    </div>
  );
}
