<div align="center">

# 💰 SpendWise

### Personal Finance & Expense Tracking System

*A smart, all-in-one personal finance assistant that transforms daily money management from a tedious chore into an automated, insightful experience.*

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![ASP.NET Core](https://img.shields.io/badge/ASP.NET_Core-10.0-512BD4?style=for-the-badge&logo=dotnet&logoColor=white)](https://dotnet.microsoft.com)
[![SQL Server](https://img.shields.io/badge/SQL_Server-2022-CC2927?style=for-the-badge&logo=microsoftsqlserver&logoColor=white)](https://www.microsoft.com/sql-server)
[![JWT](https://img.shields.io/badge/JWT-Auth-000000?style=for-the-badge&logo=jsonwebtokens&logoColor=white)](https://jwt.io)

</div>

---

## 📖 Table of Contents

- [About the Project](#about-the-project)
- [Key Features](#key-features)
- [Tech Stack](#tech-stack)
- [System Architecture](#system-architecture)
- [Getting Started](#getting-started)
- [API Documentation](#api-documentation)
- [Team](#team)

---

## 🎯 About the Project

SpendWise is a cross-platform mobile application backed by a RESTful Web API, designed to help individuals — especially students, freelancers, and young employees — take full control of their personal finances.

Most people struggle with financial self-management not due to lack of discipline, but due to the absence of a simple, intelligent tool that fits their daily workflow. SpendWise bridges that gap by combining **automated expense tracking**, **dynamic budget planning**, and **visual analytics** in a single, unified platform.

> *"SpendWise transforms financial management from a daily documentation burden into a smart, automated planning tool."*

---

## ✨ Key Features

### 💼 Income & Budget Management
- Register multiple income sources (salary, freelance, part-time)
- Dynamic budget allocation using percentage-based rules (e.g. the **50/30/20 rule**)
- Automatic deduction of fixed obligations (rent, subscriptions, installments)
- Real-time tracking of consumption rates against planned budgets

### 🧾 Smart Expense Tracking
- Manual expense entry with category tagging
- **OCR-powered receipt scanning** — snap a photo of any receipt to auto-extract amount, date, and merchant name
- Human review step to validate OCR-extracted data before saving
- Expense classification by type (essential, health, entertainment, education) and priority level

### 🎯 Savings Goals
- Create targeted savings goals (e.g. "New Laptop", "Training Course")
- Manually allocate funds to each goal from available balance
- Visual progress indicator showing completion percentage and remaining amount

### 🤝 Shared Expenses & Social Debts
- Log shared expenses between multiple users
- Automatically split costs and track who owes what
- In-app debt status updates with automated payment reminders

### 🏷️ Asset Tags System
- Create custom tags representing assets or projects (car, home, office, etc.)
- Link any expense to a specific tag for operational cost reporting
- Extract per-asset financial reports over any time period

### 📊 Visual Reports & Analytics Dashboard
- Interactive dashboard with monthly and periodic charts
- Spending distribution by category, month-over-month comparisons
- Savings rate tracking relative to total income
- Smart alerts and recommendations based on consumption analysis

### 🔔 Notifications & Reminders
- Instant push notifications when approaching or exceeding budget limits
- Periodic reminders to log expenses and pay scheduled bills
- Automated shared-debt payment notifications

### 🔐 User Authentication & Security
- Secure account registration and login via **JWT (JSON Web Token)**
- Personal profile management with password reset functionality
- Private, isolated financial data per user

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| **Mobile App** | Flutter (Dart) — Cross-platform (Android & iOS) |
| **Backend API** | ASP.NET Core Web API (.NET 10) — C# |
| **Database** | Microsoft SQL Server |
| **Authentication** | JWT Bearer Tokens |
| **OCR Engine** | google_ml_kit |
| **Data Visualization** | fl_chart |
| **State Management** | Provider |
| **HTTP Client** | Dio / http |
| **API Documentation** | Swagger / OpenAPI |
| **ORM** | Entity Framework Core |

---

## 🏗️ System Architecture

SpendWise follows a **Clean Architecture** pattern, separating concerns across four distinct layers:

```
SpendWise/
│
├── SpendWise/                        # Presentation Layer (ASP.NET Core Web API)
│   ├── Controllers/                  # API endpoints
│   ├── Program.cs                    # App entry point & service registration
│   └── appsettings.json
│
├── SpendWise.Application/            # Application Layer (Business Logic)
│   ├── Services/                     # Use cases & service interfaces
│   └── DTOs/                         # Data Transfer Objects
│
├── SpendWise.Domain/                 # Domain Layer (Core Entities)
│   ├── Entities/                     # Domain models (User, Expense, Goal, etc.)
│   └── Interfaces/                   # Repository contracts
│
├── SpendWise.Infrastructure/         # Infrastructure Layer (Data Access)
│   ├── Data/
│   │   └── ApplicationDbContext.cs   # EF Core DB context
│   └── Repositories/                 # Repository implementations
│
└── SpendWiseApp/                     # Flutter Mobile Application
    ├── lib/
    │   ├── screens/                  # UI screens
    │   ├── widgets/                  # Reusable components
    │   ├── models/                   # Data models
    │   └── services/                 # API communication layer
    └── pubspec.yaml
```

**Architecture Flow:**
```
Flutter App  ──────►  ASP.NET Core API  ──────►  Application Layer
                            │                          │
                       JWT Auth                   Domain Logic
                            │                          │
                       SQL Server  ◄──────  Infrastructure Layer
```

---

## 🚀 Getting Started

### Prerequisites

- [.NET 10 SDK](https://dotnet.microsoft.com/download)
- [Flutter SDK 3.x](https://flutter.dev/docs/get-started/install)
- [SQL Server](https://www.microsoft.com/sql-server) (or SQL Server Express)
- [Visual Studio 2022](https://visualstudio.microsoft.com/) or [VS Code](https://code.visualstudio.com/)

---

### Backend Setup (ASP.NET Core API)

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-org/spendwise.git
   cd spendwise
   ```

2. **Configure the database connection** in `SpendWise/appsettings.json`:
   ```json
   {
     "ConnectionStrings": {
       "DefaultConnection": "Server=YOUR_SERVER;Database=SpendWiseDB;Trusted_Connection=True;"
     },
     "Jwt": {
       "Key": "YOUR_SECRET_KEY",
       "Issuer": "SpendWiseAPI",
       "Audience": "SpendWiseApp"
     }
   }
   ```

3. **Apply database migrations**
   ```bash
   cd SpendWise
   dotnet ef database update
   ```

4. **Run the API**
   ```bash
   dotnet run
   ```
   The API will be available at `https://localhost:7XXX`. Swagger UI is accessible in development mode.

---

### Mobile App Setup (Flutter)

1. **Navigate to the Flutter project**
   ```bash
   cd SpendWiseApp
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure the API base URL** in `lib/services/api_service.dart`:
   ```dart
   const String baseUrl = 'https://YOUR_API_URL';
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

---

## 📡 API Documentation

Once the backend is running in development mode, interactive API documentation is available via Swagger UI:

```
https://localhost:PORT/openapi
```

Key API endpoint groups:

| Group | Base Route | Description |
|---|---|---|
| Auth | `/api/auth` | Register, login, refresh token |
| Users | `/api/users` | Profile management |
| Income | `/api/income` | Income sources CRUD |
| Expenses | `/api/expenses` | Expense tracking & OCR |
| Budgets | `/api/budgets` | Budget plans & limits |
| Goals | `/api/goals` | Savings goals tracking |
| Shared | `/api/shared` | Shared expenses & debts |
| Reports | `/api/reports` | Analytics & visual data |
| Tags | `/api/tags` | Asset tags management |

---

## 👥 Team

This project was developed as a graduation-level semester project at **Sham Private University — Faculty of Informatics Engineering** (Academic Year 2025–2026), under the supervision of **Eng. Saeed Al-Nahlawi**.

| Name | Role |
|---|---|
| **Maher Amin** | UI/UX Design
| **Mohammad Hassan Awata** | Backend (ASP.NET Core) — Project Manager |
| **Bishr Arnaut** | Backend (ASP.NET Core) |
| **Hussam Al-Naimi** | Backend (ASP.NET Core) |
| **Muhannad Al-Hujja** | Frontend (Flutter) |

---

## 📋 Project Management

| Tool | Purpose |
|---|---|
| **GitHub** | Source control & code collaboration |
| **Jira** | Task tracking & sprint management |
| **Google Drive** | File sharing & documentation |
| **Discord / WhatsApp** | Team communication |
| **Adobe XD** | UI/UX Design & Prototyping |
| **Postman** | API testing |

**Methodology:** Agile (Scrum) — bi-weekly meetings at the university library.

---

## 📚 References & Inspiration

- [YNAB (You Need A Budget)](https://www.ynab.com) — Budget methodology
- [Splitwise](https://www.splitwise.com) — Shared expense model
- [Mint](https://mint.intuit.com) — Analytics & reporting
- World Bank Global Findex Database — Financial literacy research
- Thaler & Sunstein, *Nudge* (2008) — Behavioral economics foundation

---

<div align="center">

**SpendWise** — *From financial chaos to financial clarity.*

Made with ❤️ by the SpendWise Team · Sham Private University · 2025–2026

</div>
