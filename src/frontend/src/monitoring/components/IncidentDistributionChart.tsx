import { PieChart, Pie, Cell, Tooltip, ResponsiveContainer } from "recharts";
import { mockIncidentDist } from "./MockData";

const CustomTooltip = ({ active, payload }: any) => {
  if (!active || !payload?.length) return null;
  return (
    <div className="bg-slate-900 border border-slate-700 rounded-lg p-2 text-xs font-mono shadow-xl">
      <div style={{ color: payload[0]?.payload?.color }}>{payload[0]?.name}: {payload[0]?.value}</div>
    </div>
  );
};

export function IncidentDistributionChart() {
  const total = mockIncidentDist.reduce((sum, d) => sum + d.value, 0);
  return (
    <div className="rounded-xl border border-slate-800 bg-slate-900/50 p-4">
      <div className="flex items-center gap-2 mb-4">
        <div className="w-1 h-4 bg-purple-500 rounded-full" />
        <h3 className="text-xs font-mono font-semibold text-slate-400 uppercase tracking-widest">Incident Severity</h3>
      </div>
      <div className="flex items-center gap-4">
        <ResponsiveContainer width={120} height={120}>
          <PieChart>
            <Pie data={mockIncidentDist} cx="50%" cy="50%" innerRadius={32} outerRadius={52} dataKey="value" strokeWidth={0}>
              {mockIncidentDist.map((entry, i) => (
                <Cell key={i} fill={entry.color} opacity={0.85} />
              ))}
            </Pie>
            <Tooltip content={<CustomTooltip />} />
          </PieChart>
        </ResponsiveContainer>
        <div className="flex flex-col gap-1.5 flex-1">
          {mockIncidentDist.map((d) => (
            <div key={d.name} className="flex items-center justify-between">
              <div className="flex items-center gap-1.5">
                <div className="w-2 h-2 rounded-full" style={{ background: d.color }} />
                <span className="text-[10px] font-mono text-slate-400">{d.name}</span>
              </div>
              <div className="flex items-center gap-1.5">
                <span className="text-xs font-mono font-bold" style={{ color: d.color }}>{d.value}</span>
                <span className="text-[10px] font-mono text-slate-600">{Math.round((d.value / total) * 100)}%</span>
              </div>
            </div>
          ))}
          <div className="mt-1 pt-1 border-t border-slate-800 text-[10px] font-mono text-slate-500">
            {total} total incidents (30d)
          </div>
        </div>
      </div>
    </div>
  );
}