import { motion } from "framer-motion";
import { Server, Database, Globe, Shield } from "lucide-react";

const services = [
  { name: "API Gateway", status: "healthy", uptime: "99.99%", icon: Globe, latency: "12ms" },
  { name: "Auth Service", status: "healthy", uptime: "99.97%", icon: Shield, latency: "8ms" },
  { name: "Database", status: "degraded", uptime: "99.85%", icon: Database, latency: "45ms" },
  { name: "Workers", status: "healthy", uptime: "100%", icon: Server, latency: "3ms" },
];

const statusConfig = {
  healthy: {
    color: "text-emerald-400",
    bg: "bg-emerald-500/10",
    border: "border-emerald-500/30",
    glow: "rgba(52, 211, 153, 0.2)",
  },
  degraded: {
    color: "text-amber-400",
    bg: "bg-amber-500/10",
    border: "border-amber-500/30",
    glow: "rgba(251, 191, 36, 0.2)",
  },
  down: {
    color: "text-red-400",
    bg: "bg-red-500/10",
    border: "border-red-500/30",
    glow: "rgba(239, 68, 68, 0.2)",
  },
};

export function ServiceHealthGrid() {
  return (
    <div className="grid grid-cols-2 gap-4">
      {services.map((service, index) => {
        const Icon = service.icon;
        const config = statusConfig[service.status as keyof typeof statusConfig];

        return (
          <motion.div
            key={service.name}
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.4, delay: index * 0.1 }}
            whileHover={{
              scale: 1.03,
              boxShadow: `0 0 40px ${config.glow}`,
            }}
            className={`relative bg-slate-800/50 backdrop-blur-lg border ${config.border} rounded-xl p-5 cursor-pointer overflow-hidden group`}
          >
            {/* Animated background */}
            <motion.div
              className="absolute inset-0 opacity-0 group-hover:opacity-100"
              style={{
                background: `radial-gradient(circle at center, ${config.glow}, transparent 70%)`,
              }}
              transition={{ duration: 0.3 }}
            />

            {/* Status pulse */}
            {service.status === "healthy" && (
              <motion.div
                className="absolute top-5 right-5 w-2 h-2 bg-emerald-400 rounded-full"
                animate={{ scale: [1, 1.5, 1], opacity: [1, 0.5, 1] }}
                transition={{ duration: 2, repeat: Infinity }}
              />
            )}

            <div className="relative z-10">
              <motion.div
                className={`inline-flex p-2.5 ${config.bg} rounded-lg mb-4`}
                whileHover={{ rotate: 5, scale: 1.1 }}
                transition={{ type: "spring", stiffness: 400, damping: 10 }}
              >
                <Icon className={`w-5 h-5 ${config.color}`} />
              </motion.div>

              <h3 className="text-slate-100 mb-3">{service.name}</h3>

              <div className="space-y-2 text-sm">
                <div className="flex justify-between items-center">
                  <span className="text-slate-400">Uptime</span>
                  <span className="text-slate-200">{service.uptime}</span>
                </div>
                <div className="flex justify-between items-center">
                  <span className="text-slate-400">Latency</span>
                  <span className="text-slate-200">{service.latency}</span>
                </div>
              </div>

              {/* Status badge */}
              <div className={`mt-3 inline-flex items-center gap-2 px-2.5 py-1 ${config.bg} ${config.color} rounded text-xs uppercase tracking-wider`}>
                <motion.div
                  className={`w-1.5 h-1.5 ${config.color.replace('text-', 'bg-')} rounded-full`}
                  animate={service.status === "healthy" ? { opacity: [1, 0.5, 1] } : {}}
                  transition={{ duration: 1.5, repeat: Infinity }}
                />
                {service.status}
              </div>
            </div>
          </motion.div>
        );
      })}
    </div>
  );
}
