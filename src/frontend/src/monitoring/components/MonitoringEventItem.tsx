import { RefreshCw, Rocket, AlertTriangle, ArrowUpCircle, CheckCircle2 } from "lucide-react";
import type { MonitoringEvent } from "../../types/monitoring";

const eventConfig: Record<MonitoringEvent["type"], { icon: React.ElementType; color: string; bg: string }> = {
  restart:  { icon: RefreshCw,       color: "text-red-400",     bg: "bg-red-500/10 border-red-500/20" },
  deploy:   { icon: Rocket,          color: "text-blue-400",    bg: "bg-blue-500/10 border-blue-500/20" },
  warning:  { icon: AlertTriangle,   color: "text-amber-400",   bg: "bg-amber-500/10 border-amber-500/20" },
  scale:    { icon: ArrowUpCircle,   color: "text-purple-400",  bg: "bg-purple-500/10 border-purple-500/20" },
  recovery: { icon: CheckCircle2,    color: "text-emerald-400", bg: "bg-emerald-500/10 border-emerald-500/20" },
};

interface MonitoringEventItemProps {
  event: MonitoringEvent;
}

export function MonitoringEventItem({ event }: MonitoringEventItemProps) {
  const cfg = eventConfig[event.type];
  const Icon = cfg.icon;
  return (
    <div className="flex gap-3 py-2 px-3 rounded-lg hover:bg-slate-800/40 transition-colors group border border-transparent hover:border-slate-800">
      <div className={`w-7 h-7 rounded-md border ${cfg.bg} flex items-center justify-center shrink-0 mt-0.5`}>
        <Icon className={`w-3.5 h-3.5 ${cfg.color}`} />
      </div>
      <div className="flex-1 min-w-0">
        <div className="flex items-baseline justify-between gap-2">
          <span className="text-xs font-mono font-semibold text-slate-200 group-hover:text-white transition-colors">{event.title}</span>
          <span className="text-[10px] font-mono text-slate-600 shrink-0">{event.timestamp}</span>
        </div>
        <p className="text-[11px] font-mono text-slate-500 mt-0.5 leading-relaxed">{event.description}</p>
        <span className="text-[9px] font-mono text-slate-700 mt-0.5 block">{event.service}</span>
      </div>
    </div>
  );
}