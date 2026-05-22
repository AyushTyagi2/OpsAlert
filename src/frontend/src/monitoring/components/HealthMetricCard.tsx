import { Activity, AlertTriangle, Timer, XCircle, Cpu, MemoryStick, TrendingUp, TrendingDown, Minus } from "lucide-react";
import type { HealthMetric } from "../../types/monitoring";

const iconMap: Record<string, React.ElementType> = {
  Activity, AlertTriangle, Timer, XCircle, Cpu, MemoryStick,
};

const statusStyles: Record<string, { border: string; glow: string; icon: string; value: string }> = {
  ok:       { border: "border-emerald-500/20", glow: "shadow-emerald-500/5",  icon: "text-emerald-400", value: "text-emerald-300" },
  warn:     { border: "border-amber-500/20",   glow: "shadow-amber-500/5",    icon: "text-amber-400",   value: "text-amber-300"   },
  critical: { border: "border-red-500/30",     glow: "shadow-red-500/10",     icon: "text-red-400",     value: "text-red-300"     },
};

const TrendIcon = ({ trend }: { trend: HealthMetric["trend"] }) => {
  if (trend === "up")     return <TrendingUp className="w-3 h-3 text-red-400" />;
  if (trend === "down")   return <TrendingDown className="w-3 h-3 text-emerald-400" />;
  return <Minus className="w-3 h-3 text-slate-500" />;
};

interface HealthMetricCardProps {
  metric: HealthMetric;
}

export function HealthMetricCard({ metric }: HealthMetricCardProps) {
  const Icon = iconMap[metric.icon] ?? Activity;
  const s = statusStyles[metric.status];

  return (
    <div
      className={`
        relative group rounded-xl p-4 border ${s.border}
        bg-gradient-to-br from-slate-900 to-slate-800/60
        shadow-lg ${s.glow}
        hover:scale-[1.02] hover:shadow-xl transition-all duration-200
        cursor-default overflow-hidden
      `}
    >
      <div className="absolute inset-0 bg-gradient-to-br from-white/[0.02] to-transparent pointer-events-none" />
      <div className="flex items-start justify-between mb-3">
        <div className={`w-8 h-8 rounded-lg bg-slate-800 flex items-center justify-center border border-slate-700/50`}>
          <Icon className={`w-4 h-4 ${s.icon}`} />
        </div>
        <TrendIcon trend={metric.trend} />
      </div>
      <div className={`text-2xl font-bold font-mono ${s.value} leading-none mb-1`}>
        {metric.value}
      </div>
      <div className="text-xs font-mono text-slate-400 mb-1">{metric.label}</div>
      <div className="text-[10px] font-mono text-slate-600">{metric.subvalue}</div>
    </div>
  );
}