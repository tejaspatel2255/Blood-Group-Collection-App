# Family Registry System

A production-ready Flutter application for digitizing family records, managing multi-member data, and generating automated reports. Built with a responsive Material 3 design and backed by Firebase.

## Features

*   **Role-Based Access Control**: Secure login portals and dashboards for Admins, Data Entry Operators, and Heads of Family (HOF).
*   **Dynamic Data Entry**: A robust 4-step wizard to collect comprehensive family details, including nested, unlimited family member profiles.
*   **Photo Management**: Integrated camera/gallery uploads for Heads of Family and members, directly stored in Firebase Storage.
*   **Automated ID Generation**: Generates and downloads beautifully formatted, printable A4 PDF ID cards for registered families.
*   **Admin Dashboard**: Real-time statistics, operator management, and single-click full database Excel (.xlsx) export capabilities.
*   **Secure Routing**: Powered by `go_router` with strict authentication guards preventing unauthorized access.

## Tech Stack

*   **Framework**: Flutter (Dart)
*   **Backend**: Firebase (Authentication, Firestore, Storage)
*   **State Management**: Provider
*   **Navigation**: go_router
*   **UI/UX**: Google Fonts (Poppins), Material 3, Shimmer effects, Glassmorphism
*   **Export/Docs**: pdf, printing, excel, share_plus

## Project Structure

```text
lib/
├── core/
│   ├── constants/       # App Colors, Strings, Dropdown data
│   ├── theme/           # Material 3 Theme configurations
│   └── utils/           # Password generators, Age calculators
├── models/              # FamilyModel, MemberModel, OperatorModel
├── providers/           # AuthProvider, FamilyProvider (State Management)
├── screens/
│   ├── admin/           # Admin Dashboard & Add Operator UI
│   ├── form/            # 4-Step Registration Wizard & Details View
│   ├── hof/             # Head of Family Profile Dashboard
│   ├── login/           # Role-based Login Selection & Forms
│   ├── operator/        # Operator Dashboard
│   └── splash/          # Animated Splash Screen
├── services/            # AuthService, FirestoreService, StorageService, PdfService, ExcelExportService
├── widgets/             # Reusable UI components (Custom Dropdowns, Family Cards)
├── app.dart             # Main Router & Auth Guards
└── main.dart            # Entry point & Firebase Initialization
```

## Getting Started

### Prerequisites

*   [Flutter SDK](https://docs.flutter.dev/get-started/install) (version 3.11.0 or higher)
*   [Firebase CLI](https://firebase.google.com/docs/cli) installed and authenticated

### Setup

1.  **Clone the repository**
2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Configure Firebase:**
    This project requires a connected Firebase project with Authentication (Email/Password), Firestore, and Storage enabled.
    Run the FlutterFire CLI to generate your `firebase_options.dart` and `google-services.json` files:
    ```bash
    flutterfire configure
    ```
4.  **Run the app:**
    ```bash
    flutter run
    ```

## Security Notes

For security purposes, the `google-services.json`, `GoogleService-Info.plist`, and `firebase_options.dart` files are added to `.gitignore` and are not committed to version control. You must generate your own using the Firebase CLI when cloning this repository.
