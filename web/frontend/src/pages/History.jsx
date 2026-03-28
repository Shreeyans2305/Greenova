import { useState, useEffect } from "react";
import { Trash2, Package, TrendingUp, BarChart3, Calendar, Tag } from "lucide-react";
import HistoryChart from "../components/HistoryChart";
import NotificationBanner from "../components/NotificationBanner";
import { getHistory, clearHistory } from "../utils/localStorage";
import { getTierColor } from "../data/mockData";
import { mockWeeklyTrend } from "../data/mockData";
import useAIText from "../hooks/useAIText";

export default function History() {
  const [history, setHistory] = useState([]);
  const t = useAIText("history");

  useEffect(() => {
    setHistory(getHistory());
  }, []);

  const handleClear = () => {
    clearHistory();
    setHistory([]);
  };

  const avgScore = history.length
    ? Math.round(history.reduce((sum, h) => sum + (h.score || 0), 0) / history.length)
    : 0;

  const categories = [...new Set(history.map((h) => h.category).filter(Boolean))];
  const thisMonth = history.filter((h) => {
    const d = new Date(h.date);
    const now = new Date();
    return d.getMonth() === now.getMonth() && d.getFullYear() === now.getFullYear();
  });

  return (
    <main className="max-w-4xl mx-auto px-4 pt-24 pb-16 space-y-8 animate-fade-in-up">
      {/* Header */}
      <section className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-surface-100">{t("title", "Purchase History")}</h1>
          <p className="text-surface-200/50 mt-1">{t("subtitle", "Track your environmental footprint over time")}</p>
        </div>
        {history.length > 0 && (
          <button
            onClick={handleClear}
            className="flex items-center gap-2 px-4 py-2 rounded-xl text-sm text-danger-400 border border-danger-500/20 hover:bg-danger-500/10 transition-all"
          >
            <Trash2 className="w-4 h-4" />
            {t("clear_all", "Clear All")}
          </button>
        )}
      </section>

      {/* Stats */}
      <section className="grid grid-cols-2 sm:grid-cols-4 gap-4">
        {[
          { icon: Package, value: history.length, label: t("total_items", "Total Items") },
          { icon: TrendingUp, value: avgScore || "—", label: t("avg_score", "Avg Eco Score") },
          { icon: Tag, value: categories.length, label: t("categories", "Categories") },
          { icon: Calendar, value: thisMonth.length, label: t("this_month", "This Month") },
        ].map(({ icon: Icon, value, label }) => (
          <div key={label} className="glass-card p-4 text-center">
            <Icon className="w-5 h-5 text-accent-emerald mx-auto mb-2" />
            <div className="text-xl font-bold text-surface-100">{value}</div>
            <div className="text-xs text-surface-200/40">{label}</div>
          </div>
        ))}
      </section>

      {/* Notification */}
      {avgScore >= 75 && history.length > 0 && (
        <NotificationBanner type="success" message={t("good_score_msg", "🌱 Great job! Your average eco score is above 75. You're an Eco Champion!")} />
      )}
      {avgScore > 0 && avgScore < 50 && (
        <NotificationBanner type="warning" message={t("bad_score_msg", "⚠️ Some of your recent purchases have high environmental impact. Check the alternatives!")} />
      )}

      {/* Chart */}
      {mockWeeklyTrend?.length > 0 && <HistoryChart data={mockWeeklyTrend} />}

      {/* Category Breakdown */}
      {categories.length > 0 && (
        <div className="glass-card p-6">
          <h3 className="text-lg font-semibold text-surface-100 mb-4 flex items-center gap-2">
            <BarChart3 className="w-5 h-5 text-accent-emerald" />
            {t("category_breakdown", "Category Breakdown")}
          </h3>
          <div className="grid grid-cols-2 sm:grid-cols-3 gap-3">
            {categories.map((cat) => {
              const catItems = history.filter((h) => h.category === cat);
              const catAvg = Math.round(
                catItems.reduce((sum, h) => sum + (h.score || 0), 0) / catItems.length
              );
              return (
                <div key={cat} className="glass-card-light p-3 text-center">
                  <div className="text-sm font-medium text-surface-100">{cat}</div>
                  <div className="text-xs text-surface-200/40 mt-1">
                    {catItems.length} items · Avg {catAvg}
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      )}

      {/* Purchase Log */}
      {history.length > 0 ? (
        <div className="glass-card p-6">
          <h3 className="text-lg font-semibold text-surface-100 mb-4">{t("purchase_log", "Purchase Log")}</h3>
          <div className="space-y-3">
            {history.map((item) => (
              <div
                key={item.id}
                className="glass-card-light p-4 flex items-center justify-between animate-fade-in-up"
              >
                <div className="flex-1 min-w-0">
                  <div className="text-sm font-medium text-surface-100 truncate">{item.name}</div>
                  <div className="flex items-center gap-2 mt-1">
                    {item.brand && <span className="text-xs text-surface-200/40">{item.brand}</span>}
                    {item.category && (
                      <span className="text-xs px-2 py-0.5 rounded-full bg-surface-800/60 border border-surface-700/30 text-surface-200/30">
                        {item.category}
                      </span>
                    )}
                    <span className="text-xs text-surface-200/30">{item.date}</span>
                  </div>
                </div>
                <div className="flex items-center gap-3 shrink-0">
                  <span
                    className="text-sm font-bold"
                    style={{ color: getTierColor(item.tier).text }}
                  >
                    {item.score}
                  </span>
                  <span
                    className="w-2 h-2 rounded-full"
                    style={{ backgroundColor: getTierColor(item.tier).text }}
                  />
                </div>
              </div>
            ))}
          </div>
        </div>
      ) : (
        <div className="glass-card p-12 text-center">
          <Package className="w-12 h-12 text-surface-200/20 mx-auto mb-4" />
          <p className="text-surface-200/40">
            {t("empty_state", "No purchases logged yet. Analyze a product and add it to your history!")}
          </p>
        </div>
      )}
    </main>
  );
}
