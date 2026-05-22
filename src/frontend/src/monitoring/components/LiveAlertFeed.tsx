import { Terminal } from "lucide-react";
import { AlertFeedItem } from "./AlertFeedItem";
import { mockAlerts } from "./MockData";

export function LiveAlertFeed() {
  return (
    <div className="rounded-xl border border-slate-800 bg-slate-900/50 overflow-hidden flex flex-col">
      <div className="flex items-center justify-between px-4 py-3 border-b border-slate-800 bg-black/40 shrink-0">
        <div className="flex items-center gap-2">
          <Terminal className="w-3.5 h-3.5 text-green-500" />
          <h2 className="text-xs font-mono font-semibold text-slate-400 uppercase tracking-widest">
            Alert Feed
          </h2>
          <span className="flex items-center gap-1 text-[10px] font-mono text-green-500">
            <span className="w-1.5 h-1.5 rounded-full bg-green-500 animate-pulse" />
            LIVE
          </span>
        </div>
        <div className="flex gap-1">
          <div className="w-2.5 h-2.5 rounded-full bg-red-500/60" />
          <div className="w-2.5 h-2.5 rounded-full bg-amber-500/60" />
          <div className="w-2.5 h-2.5 rounded-full bg-green-500/60" />
        </div>
      </div>

      <div className="bg-black/60 py-2 overflow-y-auto flex-1 min-h-0" style={{ maxHeight: 280 }}>
        <div className="px-3 py-1 text-[10px] font-mono text-green-600 border-b border-slate-800/60 mb-1">
          $ tail -f /var/log/ops/alerts.log
        </div>
        {mockAlerts.map((alert) => (
          <AlertFeedItem key={alert.id} alert={alert} />
        ))}
        <div className="px-3 py-1 font-mono text-xs text-green-500 animate-pulse">█</div>
      </div>
    </div>
  );
}