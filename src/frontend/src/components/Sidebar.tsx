import { motion } from "framer-motion";
import {
  LayoutDashboard,
  AlertTriangle,
  Activity,
  Users,
  Settings,
  BarChart3,
  Bell,
} from "lucide-react";
import { NavLink } from "react-router-dom";

const navItems = [
  { icon: LayoutDashboard, label: "Dashboard", to: "/" },
  { icon: AlertTriangle, label: "Incidents", to: "/incidents" },
  { icon: Activity, label: "Monitoring", to: "/monitoring" },
  { icon: Bell, label: "Alerts", to: "/alerts" },
  { icon: BarChart3, label: "Analytics", to: "/analytics" },
  { icon: Users, label: "On-Call", to: "/on-call" },
  { icon: Settings, label: "Settings", to: "/settings" },
];

export function Sidebar() {
  return (
    <motion.div
      initial={{ x: -20, opacity: 0 }}
      animate={{ x: 0, opacity: 1 }}
      transition={{ duration: 0.5 }}
      className="w-64 h-full bg-slate-900/60 backdrop-blur-2xl border-r border-slate-700/50 flex flex-col relative overflow-hidden shrink-0"
    >
      {/* Ambient glow */}
      <div className="absolute top-0 left-0 right-0 h-48 bg-gradient-radial from-blue-500/10 via-transparent to-transparent blur-3xl" />

      <div className="relative z-10 p-6">
        {/* Logo */}
        <motion.div
          className="flex items-center gap-3 mb-8"
          whileHover={{ scale: 1.02 }}
        >
          <div className="w-10 h-10 bg-gradient-to-br from-blue-500 to-cyan-500 rounded-lg flex items-center justify-center">
            <Activity className="w-6 h-6 text-white" />
          </div>
          <div>
            <div className="bg-gradient-to-r from-white to-slate-300 bg-clip-text text-transparent tracking-tight font-semibold">
              OpsPulse
            </div>
            <div className="text-xs text-slate-500">Incident Command</div>
          </div>
        </motion.div>

        {/* Navigation */}
        <nav className="space-y-1">
          {navItems.map((item) => {
            const Icon = item.icon;

            return (
              <NavLink
                key={item.label}
                to={item.to}
                end={item.to === "/"}
              >
                {({ isActive }) => (
                  <motion.div
                    className={`relative w-full flex items-center gap-3 px-4 py-3 rounded-lg transition-colors cursor-pointer ${
                      isActive
                        ? "text-white"
                        : "text-slate-400 hover:text-slate-200"
                    }`}
                    whileHover={{ x: 4 }}
                    whileTap={{ scale: 0.98 }}
                  >
                    {/* Active background */}
                    {isActive && (
                      <motion.div
                        layoutId="activeTab"
                        className="absolute inset-0 rounded-lg bg-gradient-to-r from-blue-500/20 to-cyan-500/20 border border-blue-500/30"
                        initial={false}
                        transition={{ type: "spring", stiffness: 400, damping: 30 }}
                      />
                    )}

                    {/* Hover background */}
                    {!isActive && (
                      <motion.div
                        className="absolute inset-0 rounded-lg bg-slate-800/50 opacity-0 hover:opacity-100"
                        transition={{ duration: 0.15 }}
                      />
                    )}

                    {/* Glow for active */}
                    {isActive && (
                      <motion.div
                        className="absolute inset-0 rounded-lg"
                        animate={{
                          boxShadow: [
                            "0 0 20px rgba(59, 130, 246, 0.3)",
                            "0 0 30px rgba(59, 130, 246, 0.5)",
                            "0 0 20px rgba(59, 130, 246, 0.3)",
                          ],
                        }}
                        transition={{ duration: 2, repeat: Infinity }}
                      />
                    )}

                    <Icon className="w-5 h-5 relative z-10" />
                    <span className="relative z-10">{item.label}</span>

                    {/* Active dot */}
                    {isActive && (
                      <motion.div
                        layoutId="activeIndicator"
                        className="absolute right-2 w-1.5 h-1.5 bg-blue-400 rounded-full"
                        initial={false}
                        transition={{ type: "spring", stiffness: 400, damping: 30 }}
                      />
                    )}
                  </motion.div>
                )}
              </NavLink>
            );
          })}
        </nav>
      </div>

      {/* Status indicator */}
      <div className="mt-auto p-6 relative z-10">
        <motion.div
          className="bg-slate-800/60 backdrop-blur-sm border border-slate-700/50 rounded-lg p-4"
          whileHover={{ scale: 1.02 }}
        >
          <div className="flex items-center gap-3 mb-2">
            <motion.div
              className="w-2 h-2 bg-emerald-400 rounded-full"
              animate={{ opacity: [1, 0.5, 1] }}
              transition={{ duration: 2, repeat: Infinity }}
            />
            <span className="text-sm text-slate-300">All Systems Operational</span>
          </div>
          <div className="text-xs text-slate-500">Last check: 2s ago</div>
        </motion.div>
      </div>
    </motion.div>
  );
}