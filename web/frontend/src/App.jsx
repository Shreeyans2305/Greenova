import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import { ApiProvider } from "./context/ApiContext";
import Navbar from "./components/Navbar";
import Home from "./pages/Home";
import ReportDetail from "./pages/ReportDetail";
import History from "./pages/History";
import Profile from "./pages/Profile";
import Calculator from "./pages/Calculator";

export default function App() {
  return (
    <ApiProvider>
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

          {/* Footer */}
          <footer className="py-8 text-center border-t border-surface-700/20">
            <p className="text-xs text-surface-200/30">
              🌱 GreenNova — Making sustainability accessible, one product at a time.
            </p>
          </footer>
        </div>
      </Router>
    </ApiProvider>
  );
}
