# VaultAI 🔐

> **The World's Smartest AI-Powered Document Wallet**

VaultAI is a production-grade, world-class mobile application for Android and iOS built with **Flutter** and **Supabase**. It helps users securely scan, store, organize, search, summarize, and manage all their important documents using AI.

---

## ✨ Features

### 🔐 Authentication
- Email & Password login
- Google Sign In
- Apple Sign In
- Forgot Password / Reset
- Email Verification
- Biometric lock (fingerprint/face)
- PIN lock
- Session persistence

### 🏠 Home Dashboard
- Welcome message with greeting
- Document statistics
- Expiring documents alerts
- Storage usage indicator
- AI insights
- Quick actions (Scan, Upload, AI Search, AI Chat)

### 📄 Document Management
- Upload PDF, JPG, PNG, HEIC files
- Document categorization (18+ categories)
- Favorites, Archive
- Notes and tags
- Expiry date tracking
- Bulk operations

### 📷 Document Scanner
- Camera-based scanning
- Multi-page support
- Edge detection & auto-crop (via edge_detection package)

### 🤖 AI Features
- **AI Search**: Natural language document search
- **AI Chat Assistant**: Ask questions about your documents
- **OCR**: Automatic text extraction
- **AI Summaries**: Document summarization
- Smart categorization
- Metadata extraction

### ⏰ Smart Reminders
- Automatic expiry reminders at 90, 30, 7, 1 day intervals
- Custom reminders
- Overdue tracking

### 👨‍👩‍👧‍👦 Family Vault
- Invite family members
- Shared document access
- Permission management

### ⚙️ Settings
- Dark/Light/System theme
- Biometric lock toggle
- PIN lock
- Notification preferences
- Auto backup

### 💳 Subscriptions
- Free tier (100 documents)
- Pro ($4.99/month - unlimited + AI)
- Family ($9.99/month - 6 members)
- Enterprise (team vault)

---

## 🏗️ Architecture

```
lib/
├── core/
│   ├── constants/         # App colors, constants
│   ├── theme/             # Material 3 theme (light + dark)
│   ├── router/            # GoRouter navigation
│   ├── di/                # Dependency injection
│   ├── error/             # Failures, exceptions
│   └── utils/             # Date, file, string utilities
├── features/
│   ├── auth/              # Authentication
│   ├── home/              # Home dashboard
│   ├── documents/         # Document management
│   ├── scanner/           # Document scanner
│   ├── ai/                # AI assistant & search
│   ├── reminders/         # Smart reminders
│   ├── family/            # Family vault
│   ├── profile/           # User profile
│   ├── settings/          # App settings
│   ├── subscription/      # Subscription plans
│   └── onboarding/        # Onboarding screens
└── shared/
    └── widgets/           # Shared UI components
```

**Architecture Pattern**: Clean Architecture + Repository Pattern  
**State Management**: Riverpod  
**Navigation**: GoRouter  
**Backend**: Supabase (Auth + Storage + PostgreSQL + RLS)

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK >= 3.3.0
- Dart >= 3.3.0
- Supabase account
- Firebase project (for FCM)

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/kalyanirohit23-rgb/VaultAI.git
   cd VaultAI
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment**
   ```bash
   cp .env.example .env
   # Edit .env with your Supabase credentials
   ```

4. **Run database migrations**
   - Copy `supabase/migrations/001_initial_schema.sql`
   - Run in your Supabase SQL editor

5. **Run the app**
   ```bash
   flutter run
   ```

---

## 🗄️ Database Schema

| Table | Description |
|-------|-------------|
| `profiles` | User profile data |
| `documents` | Document metadata |
| `categories` | Custom document categories |
| `folders` | Document folders |
| `tags` | Document tags |
| `document_tags` | Many-to-many document-tag relation |
| `reminders` | Expiry reminders |
| `ai_metadata` | AI processing results + embeddings |
| `subscriptions` | User subscription status |
| `activity_logs` | Audit log |
| `shared_documents` | Document sharing |
| `family_groups` | Family vault groups |
| `notifications` | In-app notifications |
| `devices` | Registered devices for FCM |

---

## 🔒 Security

- **Supabase RLS**: Row-level security on all tables
- **Encrypted storage**: Flutter secure storage for sensitive data
- **Biometric auth**: Local authentication
- **PIN lock**: 6-digit PIN protection
- **Input validation**: All user inputs validated
- **HTTPS only**: No cleartext traffic allowed
- **End-to-end encryption**: Documents encrypted in transit and at rest

---

## 📱 Supported Platforms

- ✅ Android (API 21+)
- ✅ iOS (13.0+)

---

## 🧪 Testing

```bash
flutter test
```

Tests cover:
- Domain entities
- Utility functions
- Data models (JSON serialization)

---

## 📦 Key Dependencies

| Package | Purpose |
|---------|---------|
| `supabase_flutter` | Backend (auth, storage, database) |
| `flutter_riverpod` | State management |
| `go_router` | Navigation |
| `hive_flutter` | Local caching |
| `flutter_secure_storage` | Secure key-value storage |
| `local_auth` | Biometric authentication |
| `image_picker` | Image/document selection |
| `file_picker` | File selection |
| `pin_code_fields` | PIN input UI |
| `fl_chart` | Analytics charts |
| `lottie` | Animations |
| `shimmer` | Loading skeletons |

---

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.
