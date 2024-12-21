# Expense Tracker App

## Overview
The **Expense Tracker App** is a Flutter-based application designed to help users manage their expenses. It allows users to add, edit, and delete expenses, with all data persistently stored locally using `shared_preferences`. The app leverages the **Provider** package for state management, ensuring a scalable and maintainable architecture.

---

## Features
- Login screen for user authentication (login with any email and password).
- Add new expenses with title and amount.
- Edit existing expenses.
- Delete unwanted expenses.
- Persist expense data locally using `shared_preferences`.
- View expenses in a pie chart to track expense categories.
- Clean and responsive UI.

---

## Technologies Used
- **Flutter**: Version 3.10.5
- **Dart**: As the programming language.
- **Provider**: For state management.
- **Shared Preferences**: For local data persistence.

---

## Getting Started

### Prerequisites
Ensure you have the following installed:
- Flutter SDK (v3.10.5 or later)
- Dart SDK (included with Flutter)
- An IDE (VS Code/Android Studio/IntelliJ IDEA) with Flutter and Dart plugins

### Installation Steps
1. Clone the repository:
   ```bash
   git clone https://github.com/Zafar-Iqbal-Khan/expense_tracker.git
   ```
2. Navigate to the project directory:
   ```bash
   cd expense-tracker-app
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the application:
   ```bash
   flutter run
   ```

---

## Directory Structure
```
lib/
|
|-- models/          # Data models (e.g., Expense)
|-- providers/       # State management logic
|-- screens/         # UI screens (e.g., HomeScreen,AuthScreen)
|-- widgets/         # Reusable widgets
```

---

## Key Files

### `ExpenseProvider`
Located at `lib/providers/expense_provider.dart`, this class manages all expense-related state and handles interactions with `shared_preferences` for persistent storage.

### `Expense`
Located at `lib/models/expense_model.dart`, this file defines the `Expense` data model and includes methods for JSON serialization and deserialization.

### `HomeScreen`
Located at `lib/screens/home_screen.dart`, this is the main screen of the app. It displays the list of expenses and provides options to add, edit, or delete expenses.

---

## How It Works
1. **State Management**:
   - The app uses the `Provider` package to manage the state of expenses.
   - The `ExpenseProvider` class encapsulates the logic for adding, updating, and deleting expenses and notifies the UI of changes.

2. **Local Storage**:
   - Expenses are saved to local storage using `shared_preferences` in JSON format.
   - On app startup, the `ExpenseProvider` loads saved expenses to restore the user's data.

3. **User Interaction**:
   - Users can interact with the app using the floating action button to add expenses or edit/delete existing ones using the list options.


---

## Contact
For queries or support, please contact:
- **Name**: Zafar Iqbal
- **Email**: zafar1219@gmail.com
- **GitHub**: github.com/zafar-iqbal-khan

---

Happy coding! ❤️

