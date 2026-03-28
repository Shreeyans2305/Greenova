import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import { ThemeProvider } from "./context/ThemeContext";
import { ApiProvider } from "./context/ApiContext";
import { ContentProvider } from "./context/ContentContext";
import Navbar from "./components/Navbar";
import Home from "./pages/Home";
import ReportDetail from "./pages/ReportDetail";
import History from "./pages/History";
import Profile from "./pages/Profile";
import Calculator from "./pages/Calculator";
import useAIText from "./hooks/useAIText";

function AppFooter() {
  const t = useAIText("footer");
  return (
    <footer className="py-8 text-center border-t border-text-muted/10">
      <p className="text-xs text-text-muted/60">
        {t("branding", "🌱 GreenNova — Making sustainability accessible, one product at a time.")}
      </p>
    </footer>
  );
}

export default function App() {
  return (
    <ThemeProvider>
      <ApiProvider>
        <ContentProvider>
          <Router>
            <div className="min-h-screen">
              <Navbar />
              <Routes>
                <Route path="/" element={<Home />} />
                <Route path="/report/:id" element={<ReportDetail />} />
                <Route path="/history" element={<History />} />
                <Route path="/profile" element={<Profile />} />
                <Route path="/calculator" element={<Calculator />} />
              </Routes>
              <AppFooter />
            </div>
          </Router>
        </ContentProvider>
      </ApiProvider>
    </ThemeProvider>
  );
}
