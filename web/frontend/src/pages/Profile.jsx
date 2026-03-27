import { useEffect, useState } from "react";
import { Award, TrendingUp, Target, Flame } from "lucide-react";
import BadgeCard from "../components/BadgeCard";
import NotificationBanner from "../components/NotificationBanner";
import { mockBadges, mockHistoryEntries } from "../data/mockData";
import { getHistory, seedInitialData } from "../utils/localStorage";

export default function Profile() {
  const [history, setHistory] = useState([]);

  useEffect(() => {
    seedInitialData(mockHistoryEntries, null);
    setHistory(getHistory());
  }, []);

  const earnedCount = mockBadges.filter((b) => b.earned).length;
  const totalBadges = mockBadges.length;
  const avgScore = history.length > 0
    ? Math.round(history.reduce((s, h) => s + h.score, 0) / history.length)
    : 0;

  const streak = 12; // mock streak days

  return (
    <div className="min-h-screen pt-20 pb-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-5xl mx-auto">
        {/* Header */}
        <div className="text-center mb-10 animate-fade-in-up">
          <div className="w-20 h-20 rounded-full bg-gradient-to-br from-primary-400 to-accent-400 flex items-center justify-center mx-auto mb-4 shadow-2xl shadow-primary-500/30">
            <Award className="w-10 h-10 text-white" />
          </div>
          <h1 className="text-3xl font-bold text-surface-100">Eco Profile</h1>
          <p className="text-surface-200/50 text-sm mt-1">Your sustainability journey at a glance</p>
        </div>

        {/* Stats Row */}
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-4 mb-10 animate-fade-in-up stagger-1" style={{ opacity: 0 }}>
          {[
            { icon: Award, label: "Badges Earned", value: `${earnedCount}/${totalBadges}`, color: "text-primary-400" },
            { icon: TrendingUp, label: "Avg Eco Score", value: avgScore, color: avgScore >= 75 ? "text-primary-400" : "text-warn-400" },
            { icon: Target, label: "Products Scanned", value: history.length, color: "text-accent-400" },
            { icon: Flame, label: "Day Streak", value: streak, color: "text-warn-400" },
          ].map(({ icon: Icon, label, value, color }) => (
            <div key={label} className="glass-card p-5 text-center">
              <Icon className={`w-6 h-6 ${color} mx-auto mb-2`} />
              <p className="text-2xl font-bold text-surface-100">{value}</p>
              <p className="text-xs text-surface-200/40 mt-1">{label}</p>
            </div>
          ))}
        </div>

        {/* Notifications */}
        <div className="space-y-3 mb-8 animate-fade-in-up stagger-2" style={{ opacity: 0 }}>
          {earnedCount >= 3 && (
            <NotificationBanner type="success" message={`🏆 Amazing! You've earned ${earnedCount} out of ${totalBadges} badges. Keep going!`} />
          )}
          {avgScore < 50 && (
            <NotificationBanner type="warning" message="🌿 Your average eco score is below 50. Try switching to eco-friendly alternatives to boost your score!" />
          )}
        </div>

        {/* Badges Grid */}
        <div className="animate-fade-in-up stagger-3" style={{ opacity: 0 }}>
          <h2 className="text-xl font-semibold text-surface-100 mb-6 flex items-center gap-2">
            <Award className="w-5 h-5 text-primary-400" />
            Your Badges
          </h2>
          <div className="grid grid-cols-2 sm:grid-cols-3 gap-4">
            {mockBadges.map((badge) => (
              <BadgeCard key={badge.id} badge={badge} />
            ))}
          </div>
        </div>

        {/* Progress Section */}
        <div className="mt-10 glass-card p-6 animate-fade-in-up stagger-4" style={{ opacity: 0 }}>
          <h3 className="text-lg font-semibold text-surface-100 mb-4">Progress to Next Badge</h3>
          <div className="space-y-4">
            {mockBadges
              .filter((b) => !b.earned)
              .map((badge) => {
                const progress = Math.floor(Math.random() * 70) + 10; // mock progress
                return (
                  <div key={badge.id} className="flex items-center gap-4">
                    <span className="text-2xl flex-shrink-0">{badge.icon}</span>
                    <div className="flex-1">
                      <div className="flex items-center justify-between mb-1">
                        <span className="text-sm text-surface-100 font-medium">{badge.name}</span>
                        <span className="text-xs text-surface-200/40">{progress}%</span>
                      </div>
                      <div className="h-2 bg-surface-700/40 rounded-full overflow-hidden">
                        <div
                          className="h-full rounded-full bg-gradient-to-r from-primary-500 to-accent-400 transition-all duration-1000"
                          style={{ width: `${progress}%` }}
                        />
                      </div>
                    </div>
                  </div>
                );
              })}
          </div>
        </div>
      </div>
    </div>
  );
}
