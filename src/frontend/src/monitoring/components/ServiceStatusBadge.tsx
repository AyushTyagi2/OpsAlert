import type { ServiceStatus } from "../../types/monitoring";

const styles: Record<ServiceStatus, string> = {
  HEALTHY:  "bg-emerald-500/10 text-emerald-400 border-emerald-500/30",
  DEGRADED: "bg-amber-500/10  text-amber-400  border-amber-500/30",
  DOWN:     "bg-red-500/10    text-red-400    border-red-500/30",
};

const dots: Record<ServiceStatus, string> = {
  HEALTHY:  "bg-emerald-400",
  DEGRADED: "bg-amber-400 animate-pulse",
  DOWN:     "bg-red-400 animate-pulse",
};

interface ServiceStatusBadgeProps {
  status: ServiceStatus;
}

export function ServiceStatusBadge({ status }: ServiceStatusBadgeProps) {
  return (
    <span className={`inline-flex items-center gap-1.5 px-2 py-0.5 rounded-full text-[10px] font-mono font-semibold border ${styles[status]}`}>
      <span className={`w-1.5 h-1.5 rounded-full ${dots[status]}`} />
      {status}
    </span>
  );
}