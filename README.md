# AI Onboarding Assistant

An AI-powered business onboarding assistant built with Flutter, Node.js, Supabase, and the Claude API. Businesses configure a custom AI assistant that walks new users through onboarding in natural conversation, then automatically extracts a structured profile from the session.

> Built as a portfolio project demonstrating agentic AI design patterns — specifically the **two-call Claude pattern** for conversation + structured data extraction.

---

## Demo

*(Add your Loom or YouTube demo link here)*

---

## How it works

The assistant guides users through a configurable set of onboarding questions in natural conversation. When all steps are complete, a second Claude API call extracts structured data from the conversation into a clean JSON profile — without the user ever filling out a form.

```
User types message
      ↓
Flutter app → POST /api/chat → Node.js backend (Replit)
                                      ↓
                              Fetch business config from Supabase
                                      ↓
                              Build dynamic system prompt
                                      ↓
                        Claude API call 1 — conversation turn
                                      ↓
                        Detect [ONBOARDING_COMPLETE] token
                                      ↓ (on completion)
                        Claude API call 2 — JSON profile extraction
                                      ↓
                              Save profile to Supabase
                                      ↓
                        Flutter app shows summary screen
```

---

## Stack

| Layer | Technology |
|-------|-----------|
| Mobile frontend | Flutter (Riverpod, Material 3) |
| Backend API | Node.js + Express (hosted on Replit) |
| Database | Supabase (PostgreSQL + RLS) |
| AI | Anthropic Claude API |
| Auth | API key middleware on all protected routes |

---

## Key technical patterns

### Two-call Claude pattern
The core technique of this project. The first Claude call handles the live conversation — it asks questions, adapts to answers, and detects when onboarding is complete via a hidden `[ONBOARDING_COMPLETE]` token. The second Claude call receives the full conversation transcript and extracts structured JSON (`name`, `team_type`, `use_case`, `pain_point`) without the user ever seeing a form.

### Dynamic system prompt
The system prompt is built at runtime from the business config stored in Supabase. Changing a business's tone, assistant name, or onboarding steps in the database instantly changes the assistant's behaviour — no code deployment needed.

### Multi-tenant architecture
One backend serves multiple businesses. Each business has its own `business_configs` row with a unique `business_id`. The Flutter app uses this ID to load the right assistant config, making the system fully white-labelable.

---

## Project structure

```
onboarding-assistant/
├── flutter_app/                  # Flutter mobile app
│   └── lib/
│       ├── constants.dart        # Backend URL, business ID, API key
│       ├── main.dart             # App entry point + Material 3 theme
│       ├── models/               # ChatMessage, BusinessConfig, OnboardingProfile
│       ├── providers/            # ChatNotifier (Riverpod StateNotifier)
│       ├── screens/              # SplashScreen, ChatScreen, SummaryScreen
│       └── services/             # ApiService (all HTTP calls)
│
└── artifacts/api-server/         # Node.js backend
    └── src/
        ├── lib/
        │   ├── chat.ts           # Claude API calls + two-call extraction pattern
        │   ├── supabase.ts       # Database client
        │   └── logger.ts         # Pino logger
        ├── middleware/
        │   └── auth.ts           # API key authentication
        └── routes/
            ├── chat.ts           # POST /api/chat
            ├── business.ts       # GET + POST + PATCH /api/business
            ├── sessions.ts       # GET + PATCH /api/sessions
            ├── profiles.ts       # GET /api/profile + PATCH email-sent
            └── status.ts         # GET /api/status
```

---

## API endpoints

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/api/healthz` | Health check |
| `GET` | `/api/status` | All endpoint docs + quickstart |
| `POST` | `/api/business` | Register a new business config |
| `GET` | `/api/business/:id` | Fetch business config |
| `PATCH` | `/api/business/:id` | Update business config |
| `GET` | `/api/business/:id/sessions` | List sessions (filterable, paginated) |
| `GET` | `/api/business/:id/profiles` | List all extracted profiles |
| `POST` | `/api/chat` | Multi-turn onboarding conversation |
| `GET` | `/api/sessions/:id` | Full conversation history |
| `PATCH` | `/api/sessions/:id` | Attach user identifier |
| `GET` | `/api/profile/:session_id` | Extracted onboarding profile |
| `PATCH` | `/api/profiles/:id/email-sent` | Mark profile as emailed |

All endpoints except `/api/healthz` and `/api/status` require an `X-Api-Key` header.

---

## Database schema

```sql
-- Stores one row per business using the assistant
business_configs (id, business_name, assistant_name, tone, onboarding_steps, welcome_message, created_at)

-- Stores one row per onboarding session with full message history
sessions (id, business_id, user_identifier, status, messages, created_at, updated_at)

-- Stores one row per completed onboarding with extracted profile data
onboarding_profiles (id, session_id, business_id, extracted_data, email_sent, created_at)
```

Row Level Security is enabled on all three tables. All writes go through the server-side service role key — never from the client.

---

## Setup

### Prerequisites
- Flutter SDK 3.0+
- Node.js 18+
- Supabase project
- Anthropic API key

### 1. Database
Run `artifacts/api-server/supabase-schema.sql` in your Supabase SQL editor. This creates all three tables, enables RLS, and seeds a test business config.

### 2. Backend
```bash
cd artifacts/api-server
npm install

export ANTHROPIC_API_KEY=your_key
export SUPABASE_URL=your_supabase_url
export SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
export API_KEY=your_chosen_api_key
export PORT=3000

npm run dev
```

### 3. Flutter app
```bash
cd flutter_app
flutter pub get
```

Edit `lib/constants.dart`:
```dart
const String kBackendUrl = 'https://your-backend-url';
const String kBusinessId = 'your-business-uuid-from-supabase';
const String kApiKey    = 'your-chosen-api-key';
```

```bash
flutter run
```

---

## Onboarding flow

1. **Splash screen** — loads business config from the backend (assistant name, welcome message)
2. **Chat screen** — user converses naturally with the AI assistant; one question at a time, adapts to answers, ends with a hidden `[ONBOARDING_COMPLETE]` token
3. **Extraction** — a second Claude call parses the full conversation into structured JSON saved to Supabase
4. **Summary screen** — shows the user a clean recap card of their onboarding profile

---

## What I learned

- **Prompt engineering for agentic flows** — designing a system prompt that reliably guides a multi-turn conversation to completion, including hidden completion tokens and conditional question branching
- **Two-call Claude pattern** — separating conversation from extraction into two distinct Claude calls with different system prompts, and handling JSON-parsing edge cases (markdown fence stripping)
- **Multi-tenant API design** — one backend serving multiple business configurations without code changes
- **Flutter + Riverpod** — StateNotifier pattern for managing async chat state, loading states, and navigation triggers

---

## Author

**Faruk** — Flutter & AI mobile developer  
Bayero University Kano · GDSC Mobile Lead  
Building at the intersection of Flutter and the Claude API

[LinkedIn](https://linkedin.com/in/yourprofile) · [GitHub](https://github.com/FBA23)