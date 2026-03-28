import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
  Area,
  AreaChart,
} from "recharts";
import useAIText from "../hooks/useAIText";

export default function HistoryChart({ data = [], title }) {
  const t = useAIText("chart");
  const chartTitle = title || t("default_title", "Carbon Footprint Trend");

  if (!data.length) return null;

  // Normalize data shape
  const chartData = data.map((d) => ({
    label: d.month || d.label || d.date || "",
    score: d.score ?? d.eco ?? 0,
    purchases: d.purchases ?? d.count ?? 0,
  }));

  return (
    <div className="glass-card p-6">
      <h3 className="text-lg font-semibold text-surface-100 mb-4">{chartTitle}</h3>
      <ResponsiveContainer width="100%" height={280}>
        <AreaChart data={chartData} margin={{ top: 5, right: 20, left: 0, bottom: 5 }}>
          <defs>
            <linearGradient id="scoreGradient" x1="0" y1="0" x2="0" y2="1">
              <stop offset="5%" stopColor="rgba(0, 210, 127, 0.3)" />
              <stop offset="95%" stopColor="rgba(0, 210, 127, 0)" />
            </linearGradient>
            <linearGradient id="purchasesGradient" x1="0" y1="0" x2="0" y2="1">
              <stop offset="5%" stopColor="rgba(0, 188, 212, 0.2)" />
              <stop offset="95%" stopColor="rgba(0, 188, 212, 0)" />
            </linearGradient>
          </defs>
          <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.03)" />
          <XAxis
            dataKey="label"
            tick={{ fill: "rgba(255,255,255,0.3)", fontSize: 11 }}
            axisLine={{ stroke: "rgba(255,255,255,0.05)" }}
            tickLine={false}
          />
          <YAxis
            tick={{ fill: "rgba(255,255,255,0.3)", fontSize: 11 }}
            axisLine={{ stroke: "rgba(255,255,255,0.05)" }}
            tickLine={false}
          />
          <Tooltip
            contentStyle={{
              backgroundColor: "rgba(26,26,46, 0.95)",
              border: "1px solid rgba(0,210,127,0.2)",
              borderRadius: 12,
              color: "rgba(255,255,255,0.8)",
              fontSize: 12,
            }}
            labelStyle={{ color: "rgba(255,255,255,0.5)" }}
          />
          <Legend
            wrapperStyle={{ color: "rgba(255,255,255,0.5)", fontSize: 11 }}
          />
          <Area
            type="monotone"
            dataKey="score"
            name={t("score_legend", "Eco Score")}
            stroke="rgba(0, 210, 127, 0.8)"
            fill="url(#scoreGradient)"
            strokeWidth={2}
            dot={{ fill: "rgba(0, 210, 127, 1)", r: 4 }}
            activeDot={{ r: 6 }}
          />
          <Area
            type="monotone"
            dataKey="purchases"
            name={t("purchases_legend", "Purchases")}
            stroke="rgba(0, 188, 212, 0.6)"
            fill="url(#purchasesGradient)"
            strokeWidth={1.5}
            dot={{ fill: "rgba(0, 188, 212, 0.8)", r: 3 }}
            activeDot={{ r: 5 }}
          />
        </AreaChart>
      </ResponsiveContainer>
    </div>
  );
}
