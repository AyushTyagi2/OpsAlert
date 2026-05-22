import { ServiceStatusBadge } from "./ServiceStatusBadge";
import type { Service } from "../../types/monitoring";

const latencyColor = (ms: number) => {
  if (ms === 0)   return "text-red-400";
  if (ms > 500)   return "text-amber-400";
  if (ms > 100)   return "text-yellow-400";
  return "text-emerald-400";
};

interface ServiceRowProps {
  service: Service;
  isOdd: boolean;
}

export function ServiceRow({ service, isOdd }: ServiceRowProps) {
  return (
    <tr className={`text-xs font-mono border-b border-slate-800/60 hover:bg-slate-800/40 transition-colors ${isOdd ? "bg-slate-900/20" : ""}`}>
      <td className="px-4 py-2.5">
        <div className="flex items-center gap-2">
          <div className="w-1.5 h-1.5 rounded-full bg-slate-600" />
          <span className="text-slate-200 font-medium">{service.name}</span>
          <span className="text-slate-600 text-[9px]">{service.region}</span>
        </div>
      </td>
      <td className="px-4 py-2.5">
        <ServiceStatusBadge status={service.status} />
      </td>
      <td className="px-4 py-2.5">
        <div className="flex items-center gap-2">
          <div className="flex-1 bg-slate-800 rounded-full h-1 w-16">
            <div
              className={`h-1 rounded-full ${service.uptime > 99.9 ? "bg-emerald-500" : service.uptime > 99 ? "bg-amber-500" : "bg-red-500"}`}
              style={{ width: `${Math.min(service.uptime, 100)}%` }}
            />
          </div>
          <span className="text-slate-300">{service.uptime.toFixed(2)}%</span>
        </div>
      </td>
      <td className={`px-4 py-2.5 font-bold ${latencyColor(service.latency)}`}>
        {service.latency === 0 ? "—" : `${service.latency}ms`}
      </td>
      <td className="px-4 py-2.5 text-slate-500">{service.lastChecked}</td>
    </tr>
  );
}