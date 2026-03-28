export const calculatorQuestions = [
  {
    id: "diet",
    question: "How often do you eat meat?",
    options: [
      { label: "Daily", value: 2.5 },
      { label: "A few times a week", value: 1.5 },
      { label: "Rarely/Vegetarian", value: 0.8 },
      { label: "Never/Vegan", value: 0.5 },
    ],
  },
  {
    id: "transport",
    question: "How do you usually commute?",
    options: [
      { label: "Car (alone)", value: 3.0 },
      { label: "Carpool/Motorcycle", value: 1.5 },
      { label: "Public Transport", value: 0.8 },
      { label: "Bike/Walk", value: 0.0 },
    ],
  },
  {
    id: "vehicle_km",
    question: "How many kilometers do you drive per week?",
    options: [
      { label: "None", value: 0.0 },
      { label: "Under 100 km", value: 0.5 },
      { label: "100-300 km", value: 1.2 },
      { label: "Over 300 km", value: 2.5 },
    ],
  },
  {
    id: "flights",
    question: "How many flights do you take per year?",
    options: [
      { label: "None", value: 0.0 },
      { label: "1-2 short flights", value: 0.6 },
      { label: "3-5 flights", value: 2.5 },
      { label: "More than 5", value: 5.0 },
    ],
  },
  {
    id: "energy",
    question: "What is your primary home energy source?",
    options: [
      { label: "Fossil Fuels (Coal/Gas)", value: 2.5 },
      { label: "Mixed Grid", value: 1.5 },
      { label: "Renewable Energy", value: 0.2 },
    ],
  },
  {
    id: "energy_usage",
    question: "How would you describe your home energy usage?",
    options: [
      { label: "Very high (AC always on)", value: 1.5 },
      { label: "Moderate", value: 0.8 },
      { label: "Conscious/Saving", value: 0.3 },
    ],
  },
  {
    id: "appliances",
    question: "How many large appliances do you use daily?",
    options: [
      { label: "More than 5", value: 1.2 },
      { label: "3-5 appliances", value: 0.6 },
      { label: "Less than 3", value: 0.2 },
    ],
  },
  {
    id: "shopping",
    question: "How often do you buy new clothes?",
    options: [
      { label: "Weekly", value: 1.5 },
      { label: "Monthly", value: 0.8 },
      { label: "Rarely/Second-hand", value: 0.2 },
    ],
  },
  {
    id: "electronics",
    question: "How often do you upgrade electronics?",
    options: [
      { label: "Every year", value: 1.0 },
      { label: "Every 2-3 years", value: 0.5 },
      { label: "When broken", value: 0.1 },
    ],
  },
  {
    id: "food_source",
    question: "How much of your food is locally sourced?",
    options: [
      { label: "Very little", value: 1.2 },
      { label: "Some", value: 0.6 },
      { label: "Most/All", value: 0.1 },
    ],
  },
  {
    id: "food_waste",
    question: "How much food do you waste weekly?",
    options: [
      { label: "A lot", value: 0.8 },
      { label: "Some", value: 0.4 },
      { label: "Minimal", value: 0.1 },
    ],
  },
  {
    id: "waste",
    question: "How do you manage waste and recycling?",
    options: [
      { label: "Rarely recycle", value: 1.0 },
      { label: "Recycle some items", value: 0.5 },
      { label: "Recycle & compost", value: 0.1 },
    ],
  },
  {
    id: "water",
    question: "How would you describe your water usage?",
    options: [
      { label: "Very high", value: 0.5 },
      { label: "Moderate", value: 0.2 },
      { label: "Conservative", value: 0.05 },
    ],
  },
];

export const BASE_IMPACT = 2.0;
