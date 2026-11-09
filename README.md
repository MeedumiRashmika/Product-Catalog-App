
# NexCart – Flutter Product Catalog & Shopping Cart

NexCart is a Flutter-based mobile shopping application developed as an internship technical assessment. It allows users to browse products, search for items, view product details, and manage a shopping cart with persistent local storage.

The application integrates the DummyJSON Products API and uses Provider for state management.

## Features

### Product Catalog
- Fetch products from the DummyJSON Products API.
- Display products in a responsive grid layout.
- Load additional products using pagination.
- Search products with debounce to reduce unnecessary API requests.
- View product descriptions, prices, ratings, images, and stock availability.

### Shopping Cart
- Add products to the shopping cart.
- Increase or decrease product quantities.
- Prevent quantities from exceeding available stock.
- Remove products with a confirmation dialog.
- Automatically calculate item totals and cart subtotal.
- Preserve cart data between application sessions using SharedPreferences.

### User Experience
- Consistent purple-themed Material Design interface.
- Loading indicators during API requests.
- Empty states for search results and shopping cart.
- Error messages and retry functionality for failed API requests.
- Responsive layouts and reusable UI components.

## Technology Stack

| Technology | Purpose |
|------------|---------|
| Flutter & Dart | Mobile application development |
| Provider | State management |
| Dio | HTTP requests and API integration |
| SharedPreferencesAsync | Persistent local cart storage |
| DummyJSON API | Product data source |
| flutter_test | Unit and widget testing |

## API

Product information is retrieved from the DummyJSON Products API.

Base URL:

https://dummyjson.com

Endpoints:

- `GET /products` – Retrieve products with pagination.
- `GET /products/search?q={query}` – Search products.

API Documentation: https://dummyjson.com/docs/products

## Project Structure

```text
lib/
├── core/
│   ├── api_constants.dart
│   └── app_theme.dart
├── models/
│   ├── product.dart
│   └── cart_item.dart
├── providers/
│   ├── product_provider.dart
│   └── cart_provider.dart
├── services/
│   ├── product_repository.dart
│   └── cart_storage_service.dart
├── screens/
│   ├── home_screen.dart
│   ├── product_details_screen.dart
│   └── cart_screen.dart
├── widgets/
│   ├── product_card.dart
│   ├── status_view.dart
│   └── cart_order_summary.dart
└── main.dart
```

## State Management

The application uses the Provider package to manage application state and separate UI components from business logic.

### ProductProvider

Responsible for:
- Fetching products from the API.
- Managing loading and error states.
- Handling product pagination.
- Processing search queries.
- Preventing outdated API responses from replacing newer search results.
- Retrying failed requests.

### CartProvider

Responsible for:
- Adding products to the cart.
- Increasing and decreasing quantities.
- Enforcing stock limitations.
- Removing products.
- Calculating cart totals.
- Notifying the UI when cart data changes.
- Saving and restoring cart data.

The application uses ChangeNotifier to update the UI when relevant state changes occur.

## Local Storage

NexCart uses SharedPreferencesAsync to persist shopping cart information locally.

Each saved cart item contains:
- Product information.
- Selected quantity.

Cart data is serialized into JSON before storage and restored when the application starts.

This allows users to close and reopen the application without losing their shopping cart.

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- Android Studio or Visual Studio Code
- Android emulator or physical Android device
- Internet connection for product API requests

### Installation

1. Clone the repository.

```bash
git clone https://github.com/MeedumiRashmika/Product-Catalog-App
```

2. Navigate to the project directory.

```bash
cd Product-Catalog-App
```

3. Install dependencies.

```bash
flutter pub get
```

4. Run the application.

```bash
flutter run
```

## Testing

The project includes automated tests for product models, shopping cart operations, serialization, and persistence.

Run all tests:

```bash
flutter test
```

Run static analysis:

```bash
flutter analyze
```

## Build Android APK

Generate a release APK:

```bash
flutter build apk --release
```

The generated APK is located at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Screenshots



## Author

Developed as a Flutter internship technical assessment.

## License

This project was developed for educational and assessment purposes. No open-source license is granted unless a license file is added.
