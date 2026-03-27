import { NavLink } from "react-router-dom";
import { Leaf, Search, History, Award, Wifi, WifiOff, Cpu } from "lucide-react";
import { useApi } from "../context/ApiContext";

const navItems = [
  { to: "/", label: "Home", icon: Search },
  { to: "/calculator", label: "Calculator", icon: Cpu },
  { to: "/history", label: "History", icon: History },
  { to: "/profile", label: "Badges", icon: Award },
];

function StatusDot({ backend }) {
  const isOnline = backend.status === "ok";
  const isMock = backend.status === "mock" || backend.mock_mode;
  const isChecking = backend.status === "checking";

  let dotColor, label, Icon;
  if (isChecking) {
    dotColor = "bg-warn-400 animate-pulse";
    label = "Connecting…";
    Icon = Wifi;
  } else if (isOnline && !isMock) {
    dotColor = "bg-primary-400";
    label = `Gemma 3 · Live`;
    Icon = Cpu;
  } else if (isOnline && isMock) {
    dotColor = "bg-warn-400";
    label = "Backend Mock";
    Icon = Cpu;
  } else {
    dotColor = "bg-danger-400";
    label = "Offline · Mock";
    Icon = WifiOff;
  }

  return (
    <div className="flex items-center gap-2 px-3 py-1.5 rounded-lg bg-surface-800/60 border border-surface-700/30 text-xs">
      <span className={`w-2 h-2 rounded-full ${dotColor} flex-shrink-0`} />
      <Icon className="w-3 h-3 text-surface-200/50 flex-shrink-0" />
      <span className="text-surface-200/60 hidden sm:inline whitespace-nowrap">{label}</span>
    </div>
  );
}

export default function Navbar() {
  const { backend } = useApi();

  return (
    <nav className="fixed top-0 left-0 right-0 z-50 glass-card border-b border-primary-700/30 rounded-none">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">
          {/* Logo */}
          <NavLink to="/" className="flex items-center gap-2 group">
            <div className="w-9 h-9 rounded-xl bg-gradient-to-br from-primary-400 to-primary-600 flex items-center justify-center shadow-lg shadow-primary-500/25 group-hover:shadow-primary-500/40 transition-shadow">
              <Leaf className="w-5 h-5 text-white" />
            </div>
            <span className="text-xl font-bold bg-gradient-to-r from-primary-300 to-accent-400 bg-clip-text text-transparent">
              GreenNova
            </span>
          </NavLink>

          {/* Nav Links + Status */}
          <div className="flex items-center gap-1">
            {navItems.map(({ to, label, icon: Icon }) => (
              <NavLink
                key={to}
                to={to}
                className={({ isActive }) =>
                  `flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-medium transition-all duration-300 ${
                    isActive
                      ? "bg-primary-500/20 text-primary-300 shadow-lg shadow-primary-500/10"
                      : "text-surface-200/70 hover:text-primary-300 hover:bg-white/5"
                  }`
                }
              >
                <Icon className="w-4 h-4" />
                <span className="hidden sm:inline">{label}</span>
              </NavLink>
            ))}

            {/* Separator */}
            <div className="w-px h-6 bg-surface-700/40 mx-1 hidden sm:block" />

            {/* Backend status */}
            <StatusDot backend={backend} />
          </div>
        </div>
      </div>
    </nav>
  );
}
