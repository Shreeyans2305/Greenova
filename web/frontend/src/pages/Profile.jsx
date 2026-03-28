import { useEffect, useState } from "react";
import { Award, TrendingUp, Package, Zap } from "lucide-react";
import BadgeCard from "../components/BadgeCard";
import NotificationBanner from "../components/NotificationBanner";
import { getBadges, saveBadges } from "../utils/localStorage";
import { getHistory } from "../utils/localStorage";
import { mockBadges } from "../data/mockData";
import useAIText from "../hooks/useAIText";

export default function Profile() {
  const [badges, setBadges] = useState([]);
  const t = useAIText("profile");

  useEffect(() => {
    let saved = getBadges();
    if (!saved.length) {
      saveBadges(mockBadges);
      saved = mockBadges;
    }
    setBadges(saved);
  }, []);

  const history = getHistory();
  const earned = badges.filter((b) => b.earned);
  const avgScore = history.length
    ? Math.round(history.reduce((sum, h) => sum + (h.score || 0), 0) / history.length)
    : 0;

  return (
    <main className="max-w-4xl mx-auto px-4 pt-24 pb-16 space-y-8 animate-fade-in-up">
      {/* Header */}
      <section className="text-center space-y-2">
        <h1 className="text-3xl font-bold text-text-main">{t("title", "Eco Profile")}</h1>
        <p className="text-text-muted">{t("subtitle", "Your sustainability journey at a glance")}</p>
      </section>

      {/* Stats */}
      <section className="grid grid-cols-2 sm:grid-cols-4 gap-4">
        {[
          { icon: Award, value: earned.length, label: t("badges_earned", "Badges Earned") },
          { icon: TrendingUp, value: avgScore || "—", label: t("avg_score", "Avg Eco Score") },
          { icon: Package, value: history.length, label: t("products_scanned", "Products Scanned") },
          { icon: Zap, value: "7", label: t("day_streak", "Day Streak") },
        ].map(({ icon: Icon, value, label }) => (
          <div key={label} className="glass-card p-4 text-center">
            <Icon className="w-5 h-5 text-accent-emerald mx-auto mb-2" />
            <div className="text-xl font-bold text-text-main">{value}</div>
            <div className="text-xs text-text-muted">{label}</div>
          </div>
        ))}
      </section>

      {/* Notifications */}
      {earned.length >= 3 && (
        <NotificationBanner
          type="success"
          message={t("great_badges_msg", "🏆 Amazing! You've earned {earned} out of {total} badges. Keep going!")
            .replace("{earned}", earned.length)
            .replace("{total}", badges.length)}
        />
      )}
      {avgScore > 0 && avgScore < 50 && (
        <NotificationBanner
          type="warning"
          message={t("low_score_msg", "🌿 Your average eco score is below 50. Try switching to eco-friendly alternatives to boost your score!")}
        />
      )}

      {/* Badges */}
      <section>
        <h2 className="text-xl font-semibold text-text-main mb-4">{t("your_badges", "Your Badges")}</h2>
        <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-4">
          {badges.map((badge, idx) => (
            <BadgeCard key={idx} badge={badge} />
          ))}
        </div>
      </section>

      {/* Progress */}
      <section className="glass-card p-6">
        <h3 className="text-lg font-semibold text-text-main mb-4">{t("progress_title", "Progress to Next Badge")}</h3>
        <div className="space-y-3">
          {badges
            .filter((b) => !b.earned)
            .slice(0, 3)
            .map((badge, idx) => (
              <div key={idx} className="glass-card-light p-4">
                <div className="flex items-center justify-between mb-2">
                  <div className="flex items-center gap-2">
                    <span className="text-xl">{badge.icon || "🏅"}</span>
                    <span className="text-sm font-medium text-text-main">{badge.name}</span>
                  </div>
                  <span className="text-xs text-text-muted">{(badge.progress || 0)}%</span>
                </div>
                <div className="h-1.5 bg-surface-bg border border-card-bg rounded-full overflow-hidden">
                  <div
                    className="h-full bg-linear-to-r from-accent-emerald to-accent-cyan rounded-full transition-all duration-1000"
                    style={{ width: `${badge.progress || 0}%` }}
                  />
                </div>
              </div>
            ))}
        </div>
      </section>
    </main>
  );
}
