# Family Registry System

A production-ready Flutter application for digitizing family records, managing multi-member data, and generating automated reports. Built with a responsive Material 3 design and backed by Supabase.

## Features

*   **Role-Based Access Control**: Secure login portals and dashboards for Admins, Data Entry Operators, and Heads of Family (HOF).
*   **Dynamic Data Entry**: A robust 4-step wizard to collect comprehensive family details, including nested, unlimited family member profiles.
*   **Photo Management**: Integrated camera/gallery uploads for Heads of Family and members, stored in Supabase Storage.
*   **Admin Dashboard**: Real-time statistics, operator management, and single-click full database Excel (.xlsx) export capabilities.
*   **Secure Routing**: Powered by `go_router` with strict authentication guards preventing unauthorized access.
*   **Visual Excellence**: Modern UI with glassmorphism, smooth animations (flutter_animate), and Poppins/Inter typography.

## Tech Stack

*   **Framework**: Flutter (Dart)
*   **Backend**: Supabase (Authentication, PostgreSQL Database, Storage)
*   **State Management**: Provider
*   **Navigation**: go_router
*   **UI/UX**: Google Fonts (Poppins/Inter), Material 3, Shimmer effects, Glassmorphism, flutter_animate
*   **Export/Docs**: excel, share_plus, path_provider

## Project Structure

```text
lib/
├── core/
│   ├── constants/       # App Colors, Strings, Dropdown data
│   ├── theme/           # Material 3 Theme configurations
│   └── utils/           # Password generators, Age calculators
├── models/              # FamilyModel, MemberModel
├── providers/           # AuthProvider, FamilyProvider (State Management)
├── screens/
│   ├── admin/           # Admin Dashboard & Add Operator UI
│   ├── form/            # 4-Step Registration Wizard & Details View
│   ├── hof/             # Head of Family Profile Dashboard
│   ├── login/           # Role-based Login Selection & Forms
│   ├── operator/        # Operator Dashboard
│   └── splash/          # Animated Splash Screen
├── services/            # AuthService, SupabaseService, ExcelExportService
├── widgets/             # Reusable UI components (Custom Dropdowns, Family Cards)
├── app.dart             # Main Router & Auth Guards
└── main.dart            # Entry point & Supabase Initialization
```

## Getting Started

### Prerequisites

*   [Flutter SDK](https://docs.flutter.dev/get-started/install) (version 3.11.0 or higher)
*   [Supabase Project](https://supabase.com/) created and configured

### Setup

1.  **Clone the repository**
2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Configure Supabase:**
    *   Create a new project on Supabase.
    *   Run the SQL found in `supabase_schema.sql` in your Supabase SQL Editor.
    *   Create a public bucket named `photos` in Supabase Storage.
    *   Update the `url` and `anonKey` in `lib/main.dart` with your project's API credentials.
4.  **Run the app:**
    ```bash
    flutter run
    ```

## Security Notes

For security purposes, ensure that your Supabase `anonKey` and `url` are handled securely in production. Row Level Security (RLS) should be enabled and properly configured on your Supabase tables before deploying to a live environment.
