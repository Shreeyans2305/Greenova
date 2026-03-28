import { NavLink } from "react-router-dom";
import { Leaf, Search, History, Award, Wifi, WifiOff, Cpu, Moon, Sun } from "lucide-react";
import { useApi } from "../context/ApiContext";
import useAIText from "../hooks/useAIText";
import { useTheme } from "../context/ThemeContext";

function StatusDot({ backend }) {
  const t = useAIText("navbar");
  const isOnline = backend.status === "ok";
  const isMock = backend.status === "mock" || backend.mock_mode;
  const isChecking = backend.status === "checking";

  let dotColor, label, Icon;
  if (isChecking) {
    dotColor = "bg-score-c animate-pulse";
    label = t("status_connecting", "Connecting…");
    Icon = Wifi;
  } else if (isOnline && !isMock) {
    dotColor = "bg-score-a";
    label = t("status_live", "Gemma 3 · Live");
    Icon = Cpu;
  } else if (isOnline && isMock) {
    dotColor = "bg-score-c";
    label = t("status_mock", "Backend Mock");
    Icon = Cpu;
  } else {
    dotColor = "bg-score-f";
    label = t("status_offline", "Offline · Mock");
    Icon = WifiOff;
  }

  return (
    <div className="flex items-center gap-2 px-3 py-1.5 rounded-lg bg-surface-bg/60 border border-text-muted/20 text-xs">
      <span className={`w-2 h-2 rounded-full ${dotColor} shrink-0`} />
      <Icon className="w-3 h-3 text-text-muted/70 shrink-0" />
      <span className="text-text-muted hidden sm:inline whitespace-nowrap">{label}</span>
    </div>
  );
}

export default function Navbar() {
  const { backend } = useApi();
  const t = useAIText("navbar");
  const { isDarkMode, toggleTheme } = useTheme();

  const navItems = [
    { to: "/", label: t("home", "Home"), icon: Search },
    { to: "/calculator", label: t("calculator", "Calculator"), icon: Cpu },
    { to: "/history", label: t("history", "History"), icon: History },
    { to: "/profile", label: t("badges", "Badges"), icon: Award },
  ];

  return (
    <nav className="fixed top-0 left-0 right-0 z-50 glass-card rounded-none">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">
          {/* Logo */}
          <NavLink to="/" className="flex items-center gap-2 group">
            <div className="w-9 h-9 rounded-xl bg-linear-to-br from-accent-emerald to-accent-emerald-dark flex items-center justify-center shadow-lg shadow-accent-emerald/25 group-hover:shadow-accent-emerald/40 transition-shadow">
              <Leaf className="w-5 h-5 text-surface-bg" />
            </div>
            <span className="text-xl font-bold bg-linear-to-r from-accent-emerald to-accent-cyan bg-clip-text text-transparent">
              {t("brand", "GreenNova")}
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
                      ? "bg-accent-emerald/10 text-accent-emerald shadow-lg shadow-accent-emerald/5"
                      : "text-text-muted hover:text-accent-emerald-dark hover:bg-text-muted/5"
                  }`
                }
              >
                <Icon className="w-4 h-4" />
                <span className="hidden sm:inline">{label}</span>
              </NavLink>
            ))}

            {/* Separator */}
            <div className="w-px h-6 bg-text-muted/20 mx-1 hidden sm:block" />

            {/* Theme Toggle */}
            <button
              onClick={toggleTheme}
              className="p-2 rounded-xl text-text-muted hover:text-accent-emerald hover:bg-text-muted/5 transition-colors"
              aria-label="Toggle Dark Mode"
            >
              {isDarkMode ? <Sun className="w-5 h-5" /> : <Moon className="w-5 h-5" />}
            </button>

            {/* Backend status */}
            <StatusDot backend={backend} />
          </div>
        </div>
      </div>
    </nav>
  );
}
