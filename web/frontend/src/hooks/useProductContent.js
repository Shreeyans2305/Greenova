/**
 * useProductContent — Hook for AI-generated product content
 * Wraps the ContentContext for product-specific sections.
 */

import useAIText from "./useAIText";

export default function useProductContent() {
  const tIngredients = useAIText("ingredients");
  const tAlternatives = useAIText("alternatives");
  const tReport = useAIText("report");

  return {
    ingredientsTitle: tIngredients("title", "Ingredient Analysis"),
    sustainabilityLabel: tIngredients("sustainability_label", "Sustainability:"),
    impactLabel: tIngredients("impact_label", "Impact:"),
    alternativesTitle: tAlternatives("title", "Eco-Friendly Alternatives"),
    alternativesEmpty: tAlternatives("empty_state", "✨ This product is already a great eco choice! No better alternatives found."),
    carbonLabel: tReport("carbon_label", "Carbon Footprint"),
    addHistory: tReport("add_history", "Add to History"),
    added: tReport("added", "Added ✓"),
    backButton: tReport("back_button", "Back to search"),
    newSearch: tReport("new_search", "New search"),
    clearResults: tReport("clear_results", "Clear results"),
    impactWarning: tReport("impact_warning", "This product has a high environmental impact. Consider switching to one of the alternatives below."),
  };
}
