# Product Requirements Document (PRD) - GreenNova

## 1. Vision & Overview
**GreenNova** is a smart, sustainable product recommendation engine designed to help consumers make eco-conscious purchasing decisions. By providing real-time sustainability reports and eco-friendly alternatives, GreenNova aims to reduce the environmental footprint of daily consumption.

## 2. Target Audience
- **Environmentally Conscious Consumers**: Individuals looking to reduce their carbon footprint.
- **Health-Oriented Shoppers**: Users interested in ingredient-level sustainability and health impacts.
- **Eco-Enthusiasts**: Users who want to track their sustainability progress and earn rewards.

## 3. Core Features

### 3.1 Product Input & Sustainability Analysis
- Users can input product names, ingredients, or barcodes.
- **Image Upload**: Upload product labels for AI-powered analysis.
- **Sustainability Report**:
  - **Carbon Footprint Score**: 0–100 scale.
  - **Ingredient Breakdown**: Sustainability analysis of individual components.
  - **Eco-Friendly Alternatives**: Suggestions for better products.

### 3.2 Web Lens-Style Search
- **Category Search**: Get generalized sustainability reports for categories (e.g., "Shampoo").
- **Visual Search**: AI identifies brands from images and provides detailed report cards.
- **UI Indicators**: Green/Amber/Red color coding for fast visual assessment.

### 3.3 Carbon Footprint Tracker
- **Purchase Logging**: Manual entry of purchases, stored locally in the browser.
- **Analytics Dashboard**: Weekly/monthly trend charts using Recharts.
- **Rewards & Gamification**: Earn badges like "Eco Champion 🌱" stored in `localStorage`.
- **Warning Banners**: Alerts for high-footprint shopping habits.

## 4. Non-Functional Requirements
- **Auth-Free Design**: No user accounts or login required. All data stays on the user's device.
- **Performance**: Analysis should be near real-time (mocked or fast AI inference).
- **Usability**: Mobile-friendly, intuitive React-based UI.
- **Privacy**: Local history storage via `localStorage` for complete user privacy.
- **Extensibility**: Backend and dashboard ready for deeper AI models without user-tracking.

## 5. Success Metrics
- Average Sustainability Score of logged purchases in the local device.
- Number of "Eco Champion" badges earned locally.
- User engagement with the "Alternatives" suggestions.
