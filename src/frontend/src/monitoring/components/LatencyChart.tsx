import { LineChart, Line, XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid, Legend } from "recharts";
import { mockLatency } from "./MockData";

const CustomTooltip = ({ active, payload, label }: any) => {
  if (!active || !payload?.length) return null;
  return (
    <div className="bg-slate-900 border border-slate-700 rounded-lg p-2 text-xs font-mono shadow-xl">
      <div className="text-slate-400 mb-1">{label}</div>
      {payload.map((p: any) => (
        <div key={p.dataKey} style={{ color: p.color }}>{p.name}: {p.value}ms</div>
      ))}
    </div>
  );
};

export function LatencyChart() {
  return (
    <div className="rounded-xl border border-slate-800 bg-slate-900/50 p-4">
      <div className="flex items-center gap-2 mb-4">
        <div className="w-1 h-4 bg-cyan-500 rounded-full" />
        <h3 className="text-xs font-mono font-semibold text-slate-400 uppercase tracking-widest">Latency Percentiles</h3>
      </div>
      <ResponsiveContainer width="100%" height={160}>
        <LineChart data={mockLatency} margin={{ top: 4, right: 8, bottom: 0, left: -20 }}>
          <CartesianGrid strokeDasharray="3 3" stroke="#1e293b" />
          <XAxis dataKey="time" tick={{ fill: "#475569", fontSize: 10, fontFamily: "monospace" }} tickLine={false} axisLine={false} />
          <YAxis tick={{ fill: "#475569", fontSize: 10, fontFamily: "monospace" }} tickLine={false} axisLine={false} />
          <Tooltip content={<CustomTooltip />} />
          <Legend wrapperStyle={{ fontSize: 10, fontFamily: "monospace", color: "#64748b" }} />
          <Line type="monotone" dataKey="p50" name="p50" stroke="#06b6d4" strokeWidth={2} dot={false} />
          <Line type="monotone" dataKey="p95" name="p95" stroke="#f59e0b" strokeWidth={2} dot={false} />
          <Line type="monotone" dataKey="p99" name="p99" stroke="#ef4444" strokeWidth={2} dot={false} />
        </LineChart>
      </ResponsiveContainer>
    </div>
  );
}