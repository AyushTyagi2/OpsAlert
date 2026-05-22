import { ServiceRow } from "./ServiceRow";
import { mockServices } from "./MockData";

export function ServicesStatusTable() {
  return (
    <div className="rounded-xl border border-slate-800 bg-slate-900/50 overflow-hidden">
      <div className="flex items-center justify-between px-4 py-3 border-b border-slate-800 bg-slate-900/80">
        <div className="flex items-center gap-2">
          <div className="w-1 h-4 bg-blue-500 rounded-full" />
          <h2 className="text-xs font-mono font-semibold text-slate-400 uppercase tracking-widest">
            Services Status
          </h2>
          <span className="text-[10px] font-mono px-1.5 py-0.5 rounded bg-slate-800 text-slate-500 border border-slate-700">
            {mockServices.length} total
          </span>
        </div>
        <div className="flex gap-3 text-[10px] font-mono">
          <span className="text-emerald-400">6 healthy</span>
          <span className="text-amber-400">2 degraded</span>
          <span className="text-red-400">1 down</span>
        </div>
      </div>
      <div className="overflow-auto">
        <table className="w-full">
          <thead>
            <tr className="text-[10px] font-mono uppercase tracking-widest text-slate-600 border-b border-slate-800">
              <th className="px-4 py-2 text-left">Service</th>
              <th className="px-4 py-2 text-left">Status</th>
              <th className="px-4 py-2 text-left">Uptime</th>
              <th className="px-4 py-2 text-left">Latency</th>
              <th className="px-4 py-2 text-left">Last Checked</th>
            </tr>
          </thead>
          <tbody>
            {mockServices.map((svc, i) => (
              <ServiceRow key={svc.id} service={svc} isOdd={i % 2 === 1} />
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}