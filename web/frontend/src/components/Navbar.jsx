import { useState } from "react";
import { NavLink, useLocation } from "react-router-dom";
import { 
  Leaf, 
  Search, 
  History, 
  Award, 
  Wifi, 
  WifiOff, 
  Cpu, 
  Moon, 
  Sun, 
  ArrowLeftRight, 
  Menu, 
  X,
  ChevronDown 
} from "lucide-react";
import { useApi } from "../context/ApiContext";
import useAIText from "../hooks/useAIText";
import { useTheme } from "../context/ThemeContext";

function StatusIndicator({ backend }) {
  const t = useAIText("navbar");
  const isOnline = backend.status === "ok";
  const isMock = backend.status === "mock" || backend.mock_mode;

  let statusConfig;
  if (!isOnline) {
    statusConfig = { dot: "bg-red-500", text: t("status_offline", "Offline"), icon: WifiOff };
  } else if (isMock) {
    statusConfig = { dot: "bg-yellow-500", text: t("status_mock", "Demo"), icon: Cpu };
  } else {
    statusConfig = { dot: "bg-emerald-500", text: t("status_live", "Live"), icon: Wifi };
  }

  const StatusIcon = statusConfig.icon;

  return (
    <div className="flex items-center gap-1.5">
      <span className={`w-2 h-2 rounded-full ${statusConfig.dot} ${!isOnline ? 'animate-pulse' : ''}`} />
      <StatusIcon className="w-3.5 h-3.5 text-text-secondary" />
      <span className="text-xs font-medium text-text-secondary hidden xl:inline">{statusConfig.text}</span>
    </div>
  );
}

export default function Navbar() {
  const { backend } = useApi();
  const t = useAIText("navbar");
  const { isDarkMode, toggleTheme } = useTheme();
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const location = useLocation();

  const mainNavItems = [
    { to: "/", label: t("home", "Explore Your Impact"), icon: Search },
    { to: "/compare", label: t("compare", "Compare Products"), icon: ArrowLeftRight },
    { to: "/calculator", label: t("calculator", "Calculate Footprint"), icon: Cpu },
  ];

  const secondaryNavItems = [
    { to: "/history", label: t("history", "Track Progress"), icon: History },
    { to: "/profile", label: t("badges", "Sustainability Badges"), icon: Award },
  ];

  const isActive = (path) => location.pathname === path;

  return (
    <nav className="fixed top-0 left-0 right-0 z-50 bg-surface/80 backdrop-blur-xl border-b border-text-muted/10">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">
          {/* Logo Group */}
          <NavLink to="/" className="flex items-center gap-3 group shrink-0">
            <div className="relative">
              <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-accent-emerald to-accent-emerald-dark flex items-center justify-center shadow-lg shadow-accent-emerald/30 group-hover:shadow-accent-emerald/50 transition-all duration-300 group-hover:scale-105">
                <Leaf className="w-5 h-5 text-white" />
              </div>
              <div className="absolute -bottom-0.5 -right-0.5 w-3.5 h-3.5 bg-accent-cyan rounded-full border-2 border-surface animate-pulse" />
            </div>
            <div className="flex flex-col">
              <span className="text-xl font-bold tracking-tight">
                <span className="bg-gradient-to-r from-accent-emerald to-accent-emerald-dark bg-clip-text text-transparent">
                  Green
                </span>
                <span className="text-text-primary">Nova</span>
              </span>
            </div>
          </NavLink>

          {/* Desktop Navigation */}
          <div className="hidden lg:flex items-center gap-1">
            <div className="flex items-center gap-1 pr-4 border-r border-text-muted/15 mr-3">
              {mainNavItems.map(({ to, label, icon: NavIcon }) => (
                <NavLink
                  key={to}
                  to={to}
                  className={`flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-medium transition-all duration-300 group h-10 ${
                    isActive(to)
                      ? "bg-accent-emerald/15 text-accent-emerald shadow-inner"
                      : "text-text-secondary hover:text-accent-emerald hover:bg-text-muted/5"
                  }`}
                >
                  <NavIcon className={`w-4 h-4 transition-transform duration-300 ${!isActive(to) && 'group-hover:scale-110'}`} />
                  <span className="whitespace-nowrap">{label}</span>
                </NavLink>
              ))}
            </div>

            <div className="flex items-center gap-1">
              {secondaryNavItems.map(({ to, label, icon: NavIcon }) => (
                <NavLink
                  key={to}
                  to={to}
                  className={`flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-medium transition-all duration-300 group h-10 ${
                    isActive(to)
                      ? "bg-accent-emerald/15 text-accent-emerald shadow-inner"
                      : "text-text-secondary hover:text-accent-emerald hover:bg-text-muted/5"
                  }`}
                >
                  <NavIcon className={`w-4 h-4 transition-transform duration-300 ${!isActive(to) && 'group-hover:scale-110'}`} />
                  <span className="whitespace-nowrap">{label}</span>
                </NavLink>
              ))}
            </div>
          </div>

          {/* Controls */}
          <div className="flex items-center gap-3">
            {/* Status Pill */}
            <div className="hidden lg:flex items-center px-4 py-2 rounded-full bg-text-muted/5 border border-text-muted/10 shadow-sm transition-all duration-300 hover:border-text-muted/20">
              <StatusIndicator backend={backend} />
            </div>

            {/* Theme Toggle - Styled as Pill Button */}
            <button
              onClick={toggleTheme}
              className="relative w-10 h-10 rounded-full flex items-center justify-center text-text-secondary hover:text-accent-emerald hover:bg-text-muted/5 border border-text-muted/10 transition-all duration-300 group active:scale-90"
              aria-label="Toggle Dark Mode"
            >
              <div className="relative w-5 h-5">
                <Sun className={`w-5 h-5 absolute inset-0 transition-all duration-500 ${isDarkMode ? 'opacity-0 rotate-90 scale-50' : 'opacity-100 rotate-0 scale-100'}`} />
                <Moon className={`w-5 h-5 absolute inset-0 transition-all duration-500 ${isDarkMode ? 'opacity-100 rotate-0 scale-100' : 'opacity-0 -rotate-90 scale-50'}`} />
              </div>
            </button>

            {/* Mobile Menu Button */}
            <button
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
              className="lg:hidden w-10 h-10 rounded-full flex items-center justify-center text-text-secondary hover:text-accent-emerald hover:bg-text-muted/5 border border-text-muted/10 transition-all duration-300 active:scale-95"
              aria-label="Toggle Menu"
            >
              {mobileMenuOpen ? <X className="w-5 h-5" /> : <Menu className="w-5 h-5" />}
            </button>
          </div>
        </div>

        {/* Mobile Menu */}
        <div className={`lg:hidden overflow-hidden transition-all duration-500 ease-in-out ${mobileMenuOpen ? 'max-h-[80vh] opacity-100 mt-4 mb-6' : 'max-h-0 opacity-0'}`}>
          <div className="py-4 border-t border-text-muted/10 space-y-4">
            {/* Mobile Status - Glassmorphism Pill */}
            <div className="flex items-center justify-between px-4 py-3 rounded-2xl bg-text-muted/5 border border-text-muted/10 shadow-sm">
              <span className="text-xs font-semibold uppercase tracking-wider text-text-muted">System Status</span>
              <StatusIndicator backend={backend} />
            </div>

            {/* Mobile Nav Groups */}
            <div className="grid gap-2">
              <div className="text-[10px] font-bold uppercase tracking-[0.2em] text-text-muted/60 px-4 mb-2 italic">Main Navigation</div>
              {mainNavItems.map(({ to, label, icon: NavIcon }) => (
                <NavLink
                  key={to}
                  to={to}
                  onClick={() => setMobileMenuOpen(false)}
                  className={`flex items-center gap-4 px-4 py-4 rounded-2xl text-sm font-semibold transition-all duration-300 ${
                    isActive(to)
                      ? "bg-accent-emerald/15 text-accent-emerald border border-accent-emerald/20 shadow-lg shadow-accent-emerald/5"
                      : "text-text-secondary hover:text-accent-emerald hover:bg-text-muted/5 border border-transparent"
                  }`}
                >
                  <div className={`w-10 h-10 rounded-xl flex items-center justify-center transition-all duration-300 ${isActive(to) ? 'bg-accent-emerald text-white scale-110 shadow-md shadow-accent-emerald/20' : 'bg-text-muted/10 text-text-secondary group-hover:bg-accent-emerald/20 group-hover:text-accent-emerald'}`}>
                    <NavIcon className="w-5 h-5" />
                  </div>
                  <span className="flex-1 tracking-tight">{label}</span>
                  {isActive(to) && (
                    <div className="w-2 h-2 rounded-full bg-accent-emerald animate-pulse" />
                  )}
                </NavLink>
              ))}
            </div>

            <div className="grid gap-2 pt-2">
              <div className="text-[10px] font-bold uppercase tracking-[0.2em] text-text-muted/60 px-4 mb-2 italic">Account & Growth</div>
              {secondaryNavItems.map(({ to, label, icon: NavIcon }) => (
                <NavLink
                  key={to}
                  to={to}
                  onClick={() => setMobileMenuOpen(false)}
                  className={`flex items-center gap-4 px-4 py-4 rounded-2xl text-sm font-semibold transition-all duration-300 ${
                    isActive(to)
                      ? "bg-accent-emerald/15 text-accent-emerald border border-accent-emerald/20 shadow-lg shadow-accent-emerald/5"
                      : "text-text-secondary hover:text-accent-emerald hover:bg-text-muted/5 border border-transparent"
                  }`}
                >
                  <div className={`w-10 h-10 rounded-xl flex items-center justify-center transition-all duration-300 ${isActive(to) ? 'bg-accent-emerald text-white scale-110 shadow-md shadow-accent-emerald/20' : 'bg-text-muted/10 text-text-secondary'}`}>
                    <NavIcon className="w-5 h-5" />
                  </div>
                  <span className="flex-1 tracking-tight">{label}</span>
                  {isActive(to) && (
                    <div className="w-2 h-2 rounded-full bg-accent-emerald animate-pulse" />
                  )}
                </NavLink>
              ))}
            </div>
          </div>
        </div>
      </div>
    </nav>
  );
}
