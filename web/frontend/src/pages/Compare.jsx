import { useState } from "react";
import { ArrowLeftRight, Loader2, RefreshCw, AlertCircle } from "lucide-react";
import CompareSlot from "../components/CompareSlot";
import CompareReport from "../components/CompareReport";
import { compareProducts } from "../services/api";
import useAIText from "../hooks/useAIText";

export default function Compare() {
  const [product1, setProduct1] = useState(null);
  const [product2, setProduct2] = useState(null);
  const [comparison, setComparison] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const t = useAIText("compare");

  const canCompare = product1 && product2 && !loading;

  const handleCompare = async () => {
    if (!canCompare) return;

    setLoading(true);
    setError(null);
    setComparison(null);

    try {
      const result = await compareProducts({
        product1: product1.name,
        product2: product2.name,
        product1_data: product1,
        product2_data: product2,
      });
      setComparison(result);
    } catch (err) {
      setError("Comparison failed. Please try again.");
      console.error("Compare error:", err);
    } finally {
      setLoading(false);
    }
  };

  const handleClearAll = () => {
    setProduct1(null);
    setProduct2(null);
    setComparison(null);
    setError(null);
  };

  const handleClearSlot = (slot) => {
    if (slot === 1) {
      setProduct1(null);
    } else {
      setProduct2(null);
    }
    setComparison(null);
  };

  return (
    <main className="max-w-4xl mx-auto px-4 pt-24 pb-16 animate-fade-in-up">
      {/* Header */}
      <section className="text-center mb-8">
        <h1 className="text-3xl sm:text-4xl font-bold text-text-main mb-2">
          {t("title", "Compare Products")}
        </h1>
        <p className="text-text-muted max-w-xl mx-auto">
          {t("subtitle", "Search and select two products to compare their sustainability scores and environmental impact.")}
        </p>
      </section>

      {/* Product Selection */}
      <section className="grid md:grid-cols-2 gap-4 mb-6">
        <CompareSlot
          slotNumber={1}
          selectedProduct={product1}
          onSelectProduct={setProduct1}
          onClear={() => handleClearSlot(1)}
          disabled={loading}
        />
        <CompareSlot
          slotNumber={2}
          selectedProduct={product2}
          onSelectProduct={setProduct2}
          onClear={() => handleClearSlot(2)}
          disabled={loading}
        />
      </section>

      {/* Compare Button */}
      <section className="flex flex-col sm:flex-row gap-3 justify-center mb-8">
        <button
          onClick={handleCompare}
          disabled={!canCompare}
          className={`inline-flex items-center justify-center gap-2 px-8 py-3 rounded-xl font-medium transition-all duration-300 ${
            canCompare
              ? "bg-accent-emerald text-white hover:bg-accent-emerald-dark shadow-lg shadow-accent-emerald/25"
              : "bg-surface-bg/60 text-text-muted cursor-not-allowed border border-text-muted/20"
          }`}
        >
          {loading ? (
            <>
              <Loader2 className="w-5 h-5 animate-spin" />
              {t("comparing", "Comparing...")}
            </>
          ) : (
            <>
              <ArrowLeftRight className="w-5 h-5" />
              {t("compare_button", "Compare Products")}
            </>
          )}
        </button>

        {comparison && (
          <button
            onClick={handleClearAll}
            className="inline-flex items-center justify-center gap-2 px-6 py-3 rounded-xl font-medium bg-surface-bg/60 text-text-muted border border-text-muted/20 hover:border-accent-emerald/30 hover:text-accent-emerald transition-all duration-300"
          >
            <RefreshCw className="w-4 h-4" />
            {t("new_comparison", "New Comparison")}
          </button>
        )}
      </section>

      {/* Error State */}
      {error && (
        <section className="mb-6 p-4 rounded-xl bg-red-500/10 border border-red-500/30 flex items-center gap-3">
          <AlertCircle className="w-5 h-5 text-red-400 shrink-0" />
          <p className="text-sm text-red-400">{error}</p>
        </section>
      )}

      {/* Empty State */}
      {!comparison && !loading && !error && (
        <section className="text-center py-12">
          <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-surface-bg/60 mb-4">
            <ArrowLeftRight className="w-8 h-8 text-text-muted/50" />
          </div>
          <p className="text-text-muted">
            {t("empty_state", "Search for two products above to see a detailed comparison.")}
          </p>
        </section>
      )}

      {/* Comparison Report */}
      {comparison && !loading && (
        <CompareReport comparison={comparison} />
      )}
    </main>
  );
}
