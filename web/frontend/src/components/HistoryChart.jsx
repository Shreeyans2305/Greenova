import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Area, AreaChart } from "recharts";

const CustomTooltip = ({ active, payload, label }) => {
  if (active && payload && payload.length) {
    return (
      <div className="glass-card p-3 !rounded-xl text-sm">
        <p className="text-surface-200/60 text-xs mb-1">{label}</p>
        <p className="text-primary-300 font-semibold">Score: {payload[0].value}</p>
        {payload[1] && (
          <p className="text-accent-400 text-xs">Purchases: {payload[1].value}</p>
        )}
      </div>
    );
  }
  return null;
};

export default function HistoryChart({ data, title = "Carbon Footprint Trend" }) {
  return (
    <div className="glass-card p-6">
      <h3 className="text-lg font-semibold text-surface-100 mb-6">{title}</h3>
      <div className="h-64">
        <ResponsiveContainer width="100%" height="100%">
          <AreaChart data={data} margin={{ top: 5, right: 10, left: -20, bottom: 5 }}>
            <defs>
              <linearGradient id="scoreGradient" x1="0" y1="0" x2="0" y2="1">
                <stop offset="5%" stopColor="#10b981" stopOpacity={0.3} />
                <stop offset="95%" stopColor="#10b981" stopOpacity={0} />
              </linearGradient>
            </defs>
            <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.05)" />
            <XAxis
              dataKey="week"
              tick={{ fill: "rgba(241,245,249,0.4)", fontSize: 12 }}
              axisLine={{ stroke: "rgba(255,255,255,0.08)" }}
              tickLine={false}
            />
            <YAxis
              domain={[0, 100]}
              tick={{ fill: "rgba(241,245,249,0.4)", fontSize: 12 }}
              axisLine={{ stroke: "rgba(255,255,255,0.08)" }}
              tickLine={false}
            />
            <Tooltip content={<CustomTooltip />} />
            <Area
              type="monotone"
              dataKey="score"
              stroke="#10b981"
              strokeWidth={2.5}
              fill="url(#scoreGradient)"
              dot={{ r: 4, fill: "#10b981", strokeWidth: 2, stroke: "#064e3b" }}
              activeDot={{ r: 6, fill: "#34d399", stroke: "#10b981", strokeWidth: 2 }}
            />
            <Line
              type="monotone"
              dataKey="purchases"
              stroke="#a3e635"
              strokeWidth={1.5}
              strokeDasharray="5 5"
              dot={false}
            />
          </AreaChart>
        </ResponsiveContainer>
      </div>
      <div className="flex items-center justify-center gap-6 mt-4">
        <div className="flex items-center gap-2">
          <div className="w-3 h-3 rounded-full bg-primary-500" />
          <span className="text-xs text-surface-200/50">Eco Score</span>
        </div>
        <div className="flex items-center gap-2">
          <div className="w-3 h-0.5 bg-accent-400" style={{ borderTop: "2px dashed #a3e635" }} />
          <span className="text-xs text-surface-200/50">Purchases</span>
        </div>
      </div>
    </div>
  );
}
