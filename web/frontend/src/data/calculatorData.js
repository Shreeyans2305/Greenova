export const calculatorQuestions = [
  {
    id: "diet",
    title: "How often do you eat meat?",
    options: [
      { label: "Daily", value: 2.5, icon: "🥩" },
      { label: "A few times a week", value: 1.5, icon: "🍗" },
      { label: "Rarely/Vegetarian", value: 0.8, icon: "🥗" },
      { label: "Never/Vegan", value: 0.5, icon: "🌱" },
    ],
  },
  {
    id: "transport",
    title: "How do you usually commute?",
    options: [
      { label: "Car (alone)", value: 3.0, icon: "🚗" },
      { label: "Carpool/Motorcycle", value: 1.5, icon: "🏍️" },
      { label: "Public Transport", value: 0.8, icon: "🚌" },
      { label: "Bike / Walk", value: 0.0, icon: "🚶" },
    ],
  },
  {
    id: "flights",
    title: "How many flights do you take per year?",
    options: [
      { label: "None", value: 0.0, icon: "🚫" },
      { label: "1-2 short flights", value: 0.6, icon: "✈️" },
      { label: "3-5 flights", value: 2.5, icon: "🌥️" },
      { label: "More than 5", value: 5.0, icon: "🌍" },
    ],
  },
  {
    id: "energy",
    title: "What is your primary home energy source?",
    options: [
      { label: "Fossil Fuels (Coal/Gas)", value: 2.5, icon: "🏭" },
      { label: "Mixed Grid", value: 1.5, icon: "⚡" },
      { label: "Renewable Energy", value: 0.2, icon: "☀️" },
    ],
  },
  {
    id: "shopping",
    title: "How often do you buy new clothes?",
    options: [
      { label: "Weekly", value: 1.5, icon: "🛍️" },
      { label: "Monthly", value: 0.8, icon: "👕" },
      { label: "Rarely / Second-hand", value: 0.2, icon: "♻️" },
    ],
  },
  {
    id: "food_source",
    title: "How much of your food is locally sourced?",
    options: [
      { label: "Very little", value: 1.2, icon: "🛒" },
      { label: "Some", value: 0.6, icon: "🍎" },
      { label: "Most/All", value: 0.1, icon: "🚜" },
    ],
  },
  {
    id: "waste",
    title: "How do you manage waste and recycling?",
    options: [
      { label: "Rarely recycle", value: 1.0, icon: "🗑️" },
      { label: "Recycle some items", value: 0.5, icon: "📦" },
      { label: "Recycle & compost strictly", value: 0.1, icon: "♻️" },
    ],
  },
];

// Average base carbon footprint (e.g. baseline living emissions not captured above)
export const BASE_IMPACT = 2.0;
