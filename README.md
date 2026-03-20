# 💸 Student Debt Manager

> A lightweight Flutter app for university students to track informal debts and shared expenses — no more forgetting who owes what.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat-square&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat-square&logo=dart&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey?style=flat-square)
![Storage](https://img.shields.io/badge/Storage-SharedPreferences-blue?style=flat-square)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen?style=flat-square)

---

## 📌 Overview

In hostel life and university settings, small financial exchanges happen constantly — canteen runs, photocopies, ride shares, hostel groceries. Manual tracking is error-prone and easy to forget.

**Student Debt Manager** is a local-first mobile app that gives every student a centralized ledger — create a profile per person, log transactions, and instantly see who owes what. All data stays on the device. No account. No internet. No privacy concerns.

---

## ✨ Features

### 📒 Dynamic Ledger System
Create individual profiles for different people and maintain a dedicated transaction history for each — every person gets their own clean record.

### 🧮 Automated Balance Calculation
Net balance is computed automatically per person. Color-coded at a glance:
- 🟢 **Green** — they owe you
- 🔴 **Red** — you owe them

### 🕐 Real-time Timestamps
Every transaction is automatically logged with the exact date and time — full transparent audit trail, no manual date entry needed.

### 💾 Data Persistence
Uses `shared_preferences` (local key-value storage) to persist all data across app restarts and device reboots. Nothing is lost when you close the app.

### 🧹 User-Centric UI
- Minimalist dashboard — see all balances at one glance
- **Swipe-to-Delete** for quick removal of transactions
- Confirmation dialogs to prevent accidental data loss

---

## 📱 App Screens

| Screen | Description |
|--------|-------------|
| **Dashboard** | List of all people with their net balance, color-coded |
| **Person Detail** | Full transaction history with one person |
| **Add Transaction** | Log a new debt — amount, direction (you owe / they owe), note |
| **Settings** | App preferences and data management |

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.x |
| Language | Dart |
| Local Storage | `shared_preferences` (key-value) |
| Architecture | Master-Detail Pattern |
| State Management | Stateful Widget Management |
| UI | Material Design |

---

## 📁 Project Structure

```
student-debt-manager/
│
├── lib/
│   ├── main.dart                   # App entry point
│   ├── models/
│   │   ├── person.dart             # Person profile model
│   │   └── transaction.dart        # Transaction model (amount, type, timestamp)
│   ├── screens/
│   │   ├── dashboard_screen.dart   # All contacts + net balances
│   │   ├── detail_screen.dart      # Transaction history per person
│   │   └── add_transaction_screen.dart
│   ├── widgets/
│   │   ├── person_card.dart        # Balance card with color coding
│   │   └── transaction_tile.dart   # Swipeable transaction list item
│   └── services/
│       └── storage_service.dart    # shared_preferences CRUD
│
├── pubspec.yaml
└── README.md
```

> **Note:** Update this structure to match your actual file names before pushing.

---

## ⚙️ Setup & Run

```bash
# Install dependencies
flutter pub get

# Run on connected device or emulator
flutter run

# Build release APK
flutter build apk --release
```

**Requirements:** Flutter SDK 3.x, Dart 3.x, Android Studio or VS Code with Flutter extension.

---

## 📸 Screenshots

> *(Add screenshots here — Dashboard, Detail screen, Add Transaction form)*

---

## 🔮 Planned Features

- [ ] Group expense splitting (split a bill between multiple people)
- [ ] Push notification reminders for unsettled debts
- [ ] Export transaction history as PDF or CSV
- [ ] Cloud sync across devices (Firebase)
- [ ] QR code to quickly add a contact

---

## 💡 Why Local-First?

Most expense apps require account creation and upload your data to a server. This app deliberately keeps everything on your device — no signup, no sync, no data exposure. For informal peer-to-peer tracking among friends, that's the right tradeoff.

---

## 👤 Author

**Abu-Bakar Chaudhary**  
Computer Engineering · NUST · Class of 2027  
[GitHub](https://github.com/abu-bakarchaudhary) · [LinkedIn](https://linkedin.com/in/abubakar-chaudhary-ce45)
