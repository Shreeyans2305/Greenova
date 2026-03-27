import { useEffect, useState } from "react";
import { Trash2, ShoppingBag, TrendingUp, BarChart3 } from "lucide-react";
import HistoryChart from "../components/HistoryChart";
import NotificationBanner from "../components/NotificationBanner";
import { mockHistoryEntries, mockWeeklyTrend, mockCategoryBreakdown, getTierLabel, getTierColor } from "../data/mockData";
import { getHistory, seedInitialData, clearHistory } from "../utils/localStorage";

export default function History() {
  const [history, setHistory] = useState([]);

  useEffect(() => {
    seedInitialData(mockHistoryEntries, null);
    setHistory(getHistory());
  }, []);

  const avgScore = history.length > 0
    ? Math.round(history.reduce((sum, h) => sum + h.score, 0) / history.length)
    : 0;

  const totalItems = history.reduce((sum, h) => sum + (h.quantity || 1), 0);

  const handleClear = () => {
    clearHistory();
    setHistory([]);
  };

  return (
    <div className="min-h-screen pt-20 pb-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-5xl mx-auto">
        {/* Header */}
        <div className="flex items-center justify-between mb-8 animate-fade-in-up">
          <div>
            <h1 className="text-3xl font-bold text-surface-100">Purchase History</h1>
            <p className="text-surface-200/50 text-sm mt-1">Track your environmental footprint over time</p>
          </div>
          {history.length > 0 && (
            <button
              onClick={handleClear}
              className="flex items-center gap-2 px-3 py-2 rounded-xl text-xs text-danger-400/70 hover:text-danger-400 hover:bg-danger-500/10 border border-transparent hover:border-danger-500/20 transition-all duration-300"
            >
              <Trash2 className="w-3.5 h-3.5" />
              Clear All
            </button>
          )}
        </div>

        {/* Summary Stats */}
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-4 mb-8 animate-fade-in-up stagger-1" style={{ opacity: 0 }}>
          {[
            { label: "Total Items", value: totalItems, icon: ShoppingBag, color: "text-primary-400" },
            { label: "Avg Eco Score", value: avgScore, icon: TrendingUp, color: avgScore >= 75 ? "text-primary-400" : avgScore >= 50 ? "text-warn-400" : "text-danger-400" },
            { label: "Categories", value: mockCategoryBreakdown.length, icon: BarChart3, color: "text-accent-400" },
            { label: "This Month", value: history.filter(h => h.date?.startsWith("2024-03")).length, icon: ShoppingBag, color: "text-primary-300" },
          ].map(({ label, value, icon: Icon, color }) => (
            <div key={label} className="glass-card p-4 text-center">
              <Icon className={`w-5 h-5 ${color} mx-auto mb-2`} />
              <p className="text-2xl font-bold text-surface-100">{value}</p>
              <p className="text-xs text-surface-200/40">{label}</p>
            </div>
          ))}
        </div>

        {/* Trend Chart */}
        <div className="mb-8 animate-fade-in-up stagger-2" style={{ opacity: 0 }}>
          <HistoryChart data={mockWeeklyTrend} />
        </div>

        {/* Category Breakdown */}
        <div className="glass-card p-6 mb-8 animate-fade-in-up stagger-3" style={{ opacity: 0 }}>
          <h3 className="text-lg font-semibold text-surface-100 mb-4">Category Breakdown</h3>
          <div className="space-y-4">
            {mockCategoryBreakdown.map((cat) => (
              <div key={cat.category} className="flex items-center gap-4">
                <div className="w-24 text-sm text-surface-200/60 flex-shrink-0">{cat.category}</div>
                <div className="flex-1 h-3 bg-surface-700/40 rounded-full overflow-hidden">
                  <div
                    className="h-full rounded-full transition-all duration-1000 ease-out"
                    style={{ width: `${cat.avgScore}%`, backgroundColor: cat.color }}
                  />
                </div>
                <span className="text-sm font-medium text-surface-100 w-12 text-right">{cat.avgScore}</span>
                <span className="text-xs text-surface-200/40 w-16 text-right">{cat.count} items</span>
              </div>
            ))}
          </div>
        </div>

        {/* Notifications */}
        <div className="space-y-3 mb-8">
          {avgScore >= 75 && (
            <NotificationBanner type="success" message="🌱 Great job! Your average eco score is above 75. You're an Eco Champion!" />
          )}
          {history.some(h => h.score < 40) && (
            <NotificationBanner type="warning" message="⚠️ Some of your recent purchases have high environmental impact. Check the alternatives!" />
          )}
        </div>

        {/* History List */}
        <div className="animate-fade-in-up stagger-4" style={{ opacity: 0 }}>
          <h3 className="text-lg font-semibold text-surface-100 mb-4">Purchase Log</h3>
          {history.length === 0 ? (
            <div className="glass-card p-8 text-center">
              <ShoppingBag className="w-12 h-12 text-surface-200/20 mx-auto mb-3" />
              <p className="text-surface-200/40">No purchases logged yet. Analyze a product and add it to your history!</p>
            </div>
          ) : (
            <div className="space-y-2">
              {history.map((item, idx) => {
                const tier = getTierLabel(item.score);
                const tierColor = getTierColor(tier);
                return (
                  <div
                    key={item.id || idx}
                    className="glass-card-light p-4 flex items-center justify-between hover:border-primary-500/20 transition-all duration-300"
                  >
                    <div className="flex items-center gap-3 min-w-0">
                      <div
                        className="w-10 h-10 rounded-xl flex items-center justify-center text-sm font-bold flex-shrink-0"
                        style={{ backgroundColor: tierColor.bg, color: tierColor.text, border: `1px solid ${tierColor.border}` }}
                      >
                        {item.score}
                      </div>
                      <div className="min-w-0">
                        <p className="text-sm font-medium text-surface-100 truncate">{item.productName}</p>
                        <p className="text-xs text-surface-200/40">{item.category} · {item.date}</p>
                      </div>
                    </div>
                    <span className="text-xs text-surface-200/40 flex-shrink-0 ml-2">
                      Qty: {item.quantity || 1}
                    </span>
                  </div>
                );
              })}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
