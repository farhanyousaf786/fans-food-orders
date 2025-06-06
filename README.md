# Fans Food Order App

A modern Flutter application for food ordering with Firebase integration.

## Features

- 🔐 User Authentication (Sign In/Sign Up)
- 🍽️ Food Ordering System
- 🌙 Dark/Light Theme Support
- 🔄 Real-time Order Status Updates
- 📱 Responsive Design
- 🔥 Firebase Backend Integration

## Tech Stack

- **Framework**: Flutter (SDK ^3.7.2)
- **State Management**: Provider
- **Backend**: Firebase
  - Authentication
  - Cloud Firestore
  - Firebase Storage
- **UI Components**:
  - Material Design
  - Google Fonts
  - Flutter SVG

## Getting Started

### Prerequisites

- Flutter SDK (^3.7.2)
- Dart SDK
- Firebase Project Setup

### Installation

1. Clone the repository:
   ```bash
   git clone [repository-url]
   cd fans_food_order
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure Firebase:
   - Create a new Firebase project
   - Add your Firebase configuration files
   - Enable Authentication and Firestore

4. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── models/         # Data models
├── providers/      # State management
├── screens/        # UI screens
│   ├── auth/       # Authentication screens
│   └── home/       # Main app screens
└── main.dart       # App entry point
```

## Dependencies

- `provider: ^6.1.1` - State management
- `firebase_core: ^2.24.2` - Firebase core functionality
- `firebase_auth: ^4.15.3` - Authentication
- `cloud_firestore: ^4.13.6` - Database
- `firebase_storage: ^11.5.6` - Storage
- `google_fonts: ^6.1.0` - Custom fonts
- `flutter_svg: ^2.0.9` - SVG support

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.