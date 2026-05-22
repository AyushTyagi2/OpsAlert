import { AreaChart, Area, XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid } from "recharts";
import { mockErrorRate } from "./MockData";

const CustomTooltip = ({ active, payload, label }: any) => {
  if (!active || !payload?.length) return null;
  return (
    <div className="bg-slate-900 border border-slate-700 rounded-lg p-2 text-xs font-mono shadow-xl">
      <div className="text-slate-400 mb-1">{label}</div>
      <div className="text-amber-400">rate: {payload[0]?.value}%</div>
      <div className="text-red-400">errors: {payload[1]?.value}</div>
    </div>
  );
};

export function ErrorRateChart() {
  return (
    <div className="rounded-xl border border-slate-800 bg-slate-900/50 p-4">
      <div className="flex items-center gap-2 mb-4">
        <div className="w-1 h-4 bg-red-500 rounded-full" />
        <h3 className="text-xs font-mono font-semibold text-slate-400 uppercase tracking-widest">Error Rate %</h3>
      </div>
      <ResponsiveContainer width="100%" height={160}>
        <AreaChart data={mockErrorRate} margin={{ top: 4, right: 8, bottom: 0, left: -20 }}>
          <defs>
            <linearGradient id="errGrad" x1="0" y1="0" x2="0" y2="1">
              <stop offset="5%"  stopColor="#ef4444" stopOpacity={0.3} />
              <stop offset="95%" stopColor="#ef4444" stopOpacity={0} />
            </linearGradient>
          </defs>
          <CartesianGrid strokeDasharray="3 3" stroke="#1e293b" />
          <XAxis dataKey="time" tick={{ fill: "#475569", fontSize: 10, fontFamily: "monospace" }} tickLine={false} axisLine={false} />
          <YAxis tick={{ fill: "#475569", fontSize: 10, fontFamily: "monospace" }} tickLine={false} axisLine={false} />
          <Tooltip content={<CustomTooltip />} />
          <Area type="monotone" dataKey="rate" stroke="#ef4444" strokeWidth={2} fill="url(#errGrad)" dot={false} />
        </AreaChart>
      </ResponsiveContainer>
    </div>
  );
}