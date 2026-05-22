import type { Alert } from "../../types/monitoring";

const severityStyles: Record<Alert["severity"], { prefix: string; text: string; dot: string }> = {
  critical: { prefix: "CRIT", text: "text-red-400",     dot: "bg-red-500" },
  warning:  { prefix: "WARN", text: "text-amber-400",   dot: "bg-amber-500" },
  info:     { prefix: "INFO", text: "text-blue-400",    dot: "bg-blue-500" },
  resolved: { prefix: "RSLV", text: "text-emerald-400", dot: "bg-emerald-500" },
};

interface AlertFeedItemProps {
  alert: Alert;
}

export function AlertFeedItem({ alert }: AlertFeedItemProps) {
  const s = severityStyles[alert.severity];
  return (
    <div className="flex gap-2 py-1 font-mono text-xs hover:bg-slate-800/30 px-3 transition-colors group">
      <span className="text-slate-600 shrink-0 w-16">[{alert.timestamp}]</span>
      <span className={`shrink-0 font-bold text-[10px] ${s.text} w-8`}>{s.prefix}</span>
      <span className="text-slate-300 break-all leading-relaxed group-hover:text-slate-200 transition-colors">
        {alert.message}
      </span>
    </div>
  );
}