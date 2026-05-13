# 🩸 Family Registry System

A comprehensive **Flutter** application for digitising and managing family blood group records, built with **Supabase** as the backend.

---

## 📱 Overview

The **Family Registry System** is a multi-role data collection and management app designed to register families along with their complete details — including blood groups, photos, addresses, education, occupation, and more. It supports three user roles with different access levels and a guided 4-step registration form.

---

## ✨ Features

### 👥 Multi-Role Access
| Role | Capabilities |
|------|-------------|
| **Admin** | Full access — create/edit/delete families, manage operators |
| **Operator** | Create & edit family records |
| **Head of Family (HOF)** | View and update their own family record |

### 📋 4-Step Family Registration Form
1. **Basic Info** — HOF name, father/mother name, DOB (auto-calculates age), gender, blood group, marital status, photo upload
2. **Address & Contact** — Full address, native place, city, PIN, state (default: Gujarat), mobile & WhatsApp with **international country code picker** (160+ countries), email
3. **Education & Occupation** — Education level, occupation, annual income with "Other" specification
4. **Family Members** — Add unlimited members with photo, all details, and country code mobile picker

### 🌍 International Support
- Country code picker with **160+ countries** (flag + name + dial code)
- Searchable by country name or dial code
- Applied to both HOF and family member mobile numbers

### 📸 Photo Management
- HOF photo + individual member photos
- Size-validated (10 KB – 100 KB)
- Stored in **Supabase Storage**
- Persistent across sessions

### 🔐 Authentication
- Supabase Auth (email/password)
- Auto-generated login credentials for HOF accounts
- Secure password generation

### 💾 Data Persistence
- Real-time sync with **Supabase PostgreSQL**
- Draft auto-save via `SharedPreferences`
- Offline-resilient session continuity

### ✅ Form Validation
- Required field enforcement across all 4 steps
- Regex validation for names, addresses, mobiles, emails
- DOB date picker with age auto-calculation
- Photo size guards with user-friendly SnackBar messages

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.x (Dart) |
| Backend | Supabase (PostgreSQL + Auth + Storage) |
| State Management | Provider |
| Navigation | GoRouter |
| Image Picking | image_picker |
| Local Storage | SharedPreferences |
| Date Formatting | intl |
| Fonts | google_fonts |
| Animations | flutter_animate, lottie |
| Env Config | flutter_dotenv |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `^3.11.0`
- Dart SDK
- A [Supabase](https://supabase.com) project

### 1. Clone the repository
```bash
git clone https://github.com/tejaspatel2255/Blood-Group-Collection-App.git
cd Blood-Group-Collection-App/blood_group_collection_app
```

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Configure environment variables
```bash
cp .env.example .env
```
Then open `.env` and fill in your Supabase credentials:
```env
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your_supabase_anon_key_here
```

### 4. Set up Supabase Database
Run the schema SQL file against your Supabase project:
```bash
# In the Supabase SQL Editor, run:
supabase_schema.sql
```
Then run the RPC functions:
```bash
supabase_rpc_setup.sql
```

### 5. Run the app
```bash
# Web (Chrome)
flutter run -d chrome

# Android
flutter run -d android

# iOS
flutter run -d ios
```

---

## 📁 Project Structure

```
lib/
├── core/
│   ├── constants/          # App colors, dropdown data
│   ├── theme/              # App theme
│   └── utils/              # Age calculator, password generator
├── models/
│   ├── family_model.dart   # Family data model
│   └── member_model.dart   # Member data model
├── providers/
│   ├── auth_provider.dart  # Authentication state
│   └── family_provider.dart
├── screens/
│   ├── admin/              # Admin dashboard
│   ├── auth/               # Login screens
│   ├── form/               # 4-step registration form
│   │   ├── step1_basic_info.dart
│   │   ├── step2_address_contact.dart
│   │   ├── step3_education_occupation.dart
│   │   └── step4_family_composition.dart
│   ├── hof/                # Head of Family screens
│   └── operator/           # Operator screens
├── services/
│   ├── supabase_service.dart   # DB + Storage operations
│   └── draft_service.dart      # Local draft persistence
└── widgets/
    ├── custom_text_field.dart
    ├── custom_dropdown.dart
    └── photo_picker_widget.dart
```

---

## 🗄️ Database Schema

The app uses two primary tables:

- **`families`** — HOF details, address, contact, education, occupation
- **`family_members`** — Individual member details linked by `family_id`

Photos are stored in **Supabase Storage** buckets:
- `family-photos` — HOF profile photos
- `member-photos` — Individual member photos

---

## 🔒 Security

- `.env` is **git-ignored** — never committed
- Supabase Row Level Security (RLS) policies control data access per role
- Passwords are auto-generated and hashed

---

## 📄 Environment Variables

| Variable | Description |
|----------|-------------|
| `SUPABASE_URL` | Your Supabase project URL |
| `SUPABASE_ANON_KEY` | Your Supabase anonymous (public) API key |

> ⚠️ Never commit your real `.env` file. Use `.env.example` as a template.

---

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 👨‍💻 Author

**Tejas Patel**
- GitHub: [@tejaspatel2255](https://github.com/tejaspatel2255)

---

## 📜 License

This project is private and not licensed for public distribution.
