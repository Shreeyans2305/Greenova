import { Award, Lock } from "lucide-react";
import useAIText from "../hooks/useAIText";

export default function BadgeCard({ badge }) {
  const t = useAIText("profile");
  const earned = badge?.earned ?? false;

  return (
    <div
      className={`glass-card p-4 flex flex-col items-center text-center transition-all duration-300 ${
        earned
          ? "border-accent-emerald/30 hover:border-accent-emerald/50 hover:shadow-lg hover:shadow-accent-emerald/10"
          : "opacity-40 grayscale hover:opacity-60 hover:grayscale-0"
      }`}
    >
      {/* Icon */}
      <div className="relative mb-3">
        <span className="text-3xl">{badge?.icon || "🏅"}</span>
        {!earned && (
          <div className="absolute -bottom-1 -right-1 w-5 h-5 bg-surface-bg rounded-full flex items-center justify-center border border-card-bg">
            <Lock className="w-2.5 h-2.5 text-text-muted" />
          </div>
        )}
      </div>

      {/* Name */}
      <h4 className="text-sm font-medium text-text-main mb-1">{badge?.name || "Badge"}</h4>

      {/* Status */}
      <span
        className={`inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-xs font-medium ${
          earned
            ? "bg-accent-emerald/15 text-accent-emerald border border-accent-emerald/20"
            : "bg-surface-bg text-text-muted border border-card-bg"
        }`}
      >
        {earned ? (
          <>
            <Award className="w-3 h-3" />
            {t("earned_label", "Earned")}
          </>
        ) : (
          t("locked_label", "Locked")
        )}
      </span>
    </div>
  );
}
