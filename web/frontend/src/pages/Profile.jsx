import { useEffect, useState } from "react";
import { Award, TrendingUp, Package, Zap, RefreshCw } from "lucide-react";
import BadgeCard from "../components/BadgeCard";
import NotificationBanner from "../components/BadgeCard";
import { getAllBadgesWithProgress, getUserStatsDisplay, resetAllBadges } from "../services/badgeService";
import useAIText from "../hooks/useAIText";

export default function Profile() {
  const [badges, setBadges] = useState([]);
  const [stats, setStats] = useState(null);
  const [newBadges, setNewBadges] = useState([]);
  const t = useAIText("profile");

  useEffect(() => {
    loadData();
  }, []);

  const loadData = () => {
    const allBadges = getAllBadgesWithProgress();
    const userStats = getUserStatsDisplay();
    setBadges(allBadges);
    setStats(userStats);
  };

  const handleResetBadges = () => {
    resetAllBadges();
    loadData();
  };

  const earned = badges.filter((b) => b.earned);
  const inProgress = badges.filter((b) => !b.earned);

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
          { 
            icon: Award, 
            value: earned.length, 
            label: t("badges_earned", "Badges Earned"),
            color: "text-yellow-500"
          },
          { 
            icon: TrendingUp, 
            value: stats?.avgScore || "—", 
            label: t("avg_score", "Avg Eco Score"),
            color: stats?.avgScore >= 75 ? "text-accent-emerald" : stats?.avgScore >= 50 ? "text-yellow-500" : "text-red-400"
          },
          { 
            icon: Package, 
            value: stats?.totalAnalyzed || 0, 
            label: t("products_scanned", "Products Scanned"),
            color: "text-accent-cyan"
          },
          { 
            icon: Zap, 
            value: earned.length > 0 ? Math.max(...earned.map(b => b.progress || 0)) : 0, 
            label: "Top Progress",
            color: "text-purple-400"
          },
        ].map(({ icon: Icon, value, label, color }) => (
          <div key={label} className="glass-card p-4 text-center">
            <Icon className={`w-5 h-5 mx-auto mb-2 ${color}`} />
            <div className="text-xl font-bold text-text-main">{value}</div>
            <div className="text-xs text-text-muted">{label}</div>
          </div>
        ))}
      </section>

      {/* Notifications */}
      {earned.length >= 3 && (
        <NotificationBanner
          type="success"
          message={`🏆 Amazing! You've earned ${earned.length} out of ${badges.length} badges. Keep going!`}
        />
      )}
      {stats?.avgScore > 0 && stats.avgScore < 50 && (
        <NotificationBanner
          type="warning"
          message="🌿 Your average eco score is below 50. Try switching to eco-friendly alternatives!"
        />
      )}
      {stats?.avgScore >= 85 && earned.length >= 5 && (
        <NotificationBanner
          type="success"
          message="🌟 You're a sustainability hero! Keep making eco-conscious choices!"
        />
      )}

      {/* Earned Badges */}
      {earned.length > 0 && (
        <section>
          <h2 className="text-xl font-semibold text-text-main mb-4 flex items-center gap-2">
            <Award className="w-5 h-5 text-yellow-500" />
            Earned Badges ({earned.length})
          </h2>
          <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-4">
            {earned.map((badge) => (
              <BadgeCard key={badge.id} badge={badge} />
            ))}
          </div>
        </section>
      )}

      {/* Badges In Progress */}
      {inProgress.length > 0 && (
        <section>
          <h2 className="text-xl font-semibold text-text-main mb-4 flex items-center gap-2">
            <TrendingUp className="w-5 h-5 text-accent-cyan" />
            In Progress ({inProgress.length})
          </h2>
          <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-4">
            {inProgress.map((badge) => (
              <BadgeCard key={badge.id} badge={badge} />
            ))}
          </div>
        </section>
      )}

      {/* Progress Section */}
      <section className="glass-card p-6">
        <h3 className="text-lg font-semibold text-text-main mb-4">{t("progress_title", "Progress to Next Badge")}</h3>
        <div className="space-y-3">
          {inProgress
            .sort((a, b) => (b.progress || 0) - (a.progress || 0))
            .slice(0, 4)
            .map((badge) => (
              <div key={badge.id} className="glass-card-light p-4">
                <div className="flex items-center justify-between mb-2">
                  <div className="flex items-center gap-3">
                    <span className="text-2xl">{badge.emoji}</span>
                    <div>
                      <span className="text-sm font-medium text-text-main">{badge.name}</span>
                      <p className="text-xs text-text-muted">{badge.description}</p>
                    </div>
                  </div>
                  <span className="text-sm font-medium text-accent-emerald">
                    {Math.round(badge.progress || 0)}%
                  </span>
                </div>
                <div className="h-2 bg-surface-bg rounded-full overflow-hidden">
                  <div
                    className="h-full bg-gradient-to-r from-accent-emerald to-accent-cyan rounded-full transition-all duration-1000"
                    style={{ width: `${badge.progress || 0}%` }}
                  />
                </div>
              </div>
            ))}
        </div>
      </section>

      {/* Reset Button (for testing) */}
      <div className="text-center">
        <button
          onClick={handleResetBadges}
          className="inline-flex items-center gap-2 px-4 py-2 rounded-lg text-sm text-text-muted hover:text-accent-emerald hover:bg-text-muted/5 transition-colors"
        >
          <RefreshCw className="w-4 h-4" />
          Reset Badges (Debug)
        </button>
      </div>
    </main>
  );
}
