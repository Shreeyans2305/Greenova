# API Reference - GreenNova

## 1. Product Analysis (`/api/analyze`)

- **Method**: `POST`
- **Description**: Analyzes product text (e.g., ingredients) or an image label.
- **Request Body**:
  ```json
  {
    "text": "Sodium chloride, Aqua, Fragrance",
    "image_b64": "optional_base64_string",
    "barcode": "optional_barcode_number"
  }
  ```
- **Response** (`200 OK`):
  ```json
  {
    "product_name": "Generic Soap",
    "score": 85,
    "tier": "GREEN",
    "carbon_footprint": "Low",
    "ingredients_analysis": [
      { "name": "Aqua", "sustainability": "High", "impact": "Low" },
      { "name": "Fragrance", "sustainability": "Low", "impact": "Medium" }
    ],
    "alternatives": [
      { "name": "EcoSoap 2.0", "url": "https://example.com/ecosoap" }
    ]
  }
  ```

## 2. Product Search (`/api/search`)

- **Method**: `POST`
- **Description**: Performs a generalized search by text or visual label.
- **Request Body**:
  ```json
  { "query": "Eco Shampoo" }
  ```
- **Response** (`200 OK`):
  ```json
  {
    "type": "GENERALIZED",
    "results": [
      {
        "id": "123",
        "name": "Nature Fresh Shampoo",
        "score": 92,
        "badge": "Eco Champion 🌱"
      }
    ]
  }
  ```

## 3. History Management (Client-Side Only)
- All history is managed via `localStorage` in the browser.
- No backend endpoints are provided for history to maintain privacy and an Auth-free design.

## 4. Error Responses

| Code | Name | Description |
|---|---|---|
| `400` | Bad Request | Missing required fields or invalid payload. |
| `500` | Internal Error | AI model or server-side failure. |
| `503` | Service Unavailable | Ollama instance not reachable or starting up. |
