import { MonitoringEventItem } from "./MonitoringEventItem";
import { mockEvents } from "./MockData";

export function MonitoringEventList() {
  return (
    <div className="rounded-xl border border-slate-800 bg-slate-900/50 overflow-hidden">
      <div className="flex items-center justify-between px-4 py-3 border-b border-slate-800 bg-slate-900/80">
        <div className="flex items-center gap-2">
          <div className="w-1 h-4 bg-amber-500 rounded-full" />
          <h2 className="text-xs font-mono font-semibold text-slate-400 uppercase tracking-widest">
            Ops Events
          </h2>
          <span className="text-[10px] font-mono px-1.5 py-0.5 rounded bg-slate-800 text-slate-500 border border-slate-700">
            last 30min
          </span>
        </div>
        <button className="text-[10px] font-mono text-slate-600 hover:text-slate-400 transition-colors">
          View all →
        </button>
      </div>
      <div className="p-2 space-y-0.5">
        {mockEvents.map((event) => (
          <MonitoringEventItem key={event.id} event={event} />
        ))}
      </div>
    </div>
  );
}