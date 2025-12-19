# WiesbadenAfterDark - Master Resources Guide
## All Tools, MCPs, Skills & Documentation

**Last Updated:** December 19, 2025

---

## 🔧 MCPs Available (13 Active)

| MCP | Purpose | Use For |
|-----|---------|---------|
| **Archon** | Knowledge base + Task management | Project docs, tasks, Bloghead patterns |
| **Supabase** | Database toolkit | Schema, migrations, RLS policies |
| **XcodeBuild** | iOS compilation | Build, test, archive iOS app |
| **Apple Docs** | SwiftUI/Xcode reference | iOS development patterns |
| **Playwright** | E2E testing | Browser automation tests |
| **GitHub** | Version control | Commits, PRs, issues |
| **Perplexity** | Web research | Competitor analysis, docs |
| **Gemini** | Large context | Analyze big codebases |
| **Blender** | 3D visualization | Marketing assets |
| **Prisma** | Database ORM | Schema generation |
| **Notion** | Documentation | Team docs |

---

## 📚 Archon Knowledge Bases

| Source | Words | Use For |
|--------|-------|---------|
| Claude Docs | 2.7M | Best practices, prompting |
| MCP Servers | 3.4M | Tool integrations |
| n8n | 501K | Automation workflows |
| Supabase | 487K | Database, auth, realtime |
| PydanticAI | 373K | Python AI patterns |
| SwiftUI | 162K | iOS UI development |
| Xcode | 115K | Build, debug, deploy |
| GitHub | 40K | Git workflows |

---

## 🛠 Claude Code Skills (27)

### Development
- `codebase-documenter` - Auto-generate docs
- `test-specialist` - Unit/E2E test generation
- `cicd-pipeline-generator` - CI/CD setup
- `docker-containerization` - Docker configs
- `frontend-enhancer` - UI improvements
- `tech-debt-analyzer` - Code quality

### Business
- `seo-optimizer` - SEO improvements
- `pitch-deck` - Investor presentations
- `startup-validator` - Business validation
- `business-document-generator` - Reports

### Documents
- `docx` - Word documents
- `pdf` - PDF generation
- `research-paper-writer` - Research docs

---

## 📁 Project Documentation

| File | Description |
|------|-------------|
| `MASTER_RESOURCES.md` | This file - all resources |
| `WIESBADEN_AFTER_DARK_MASTER_PLAN.md` | Implementation plan |
| `TESTING_CHECKLIST.md` | Das Wohnzimmer testing |
| `DAS_WOHNZIMMER_PREP.md` | On-site prep guide |
| `COMPETITOR_RESEARCH_SUMMARY.md` | 20 companies analyzed |
| `KNOWLEDGE-BASE-REFERENCE.md` | API reference |
| `RAILWAY_DEPLOYMENT_GUIDE.md` | Backend deployment |
| `IMAGE_OPTIMIZATION_SUMMARY.md` | Image handling |

---

## 🏗 Project Structure
WiesbadenAfterDark/
├── WiesbadenAfterDark/        # iOS App (SwiftUI)
│   ├── App/                   # App entry, MainTabView
│   ├── Core/                  # Services, Config, Extensions
│   │   ├── Services/          # API, Auth, Location
│   │   └── Extensions/        # Swift extensions
│   ├── Features/              # 14 feature modules
│   │   ├── Home/
│   │   ├── Venues/
│   │   ├── Events/
│   │   ├── Profile/
│   │   ├── Community/
│   │   └── Onboarding/
│   └── Shared/                # Reusable components
│       └── Components/        # Buttons, Cards, etc.
│
├── owner-pwa/                 # Owner Dashboard (React)
│   └── src/
│       ├── pages/             # Dashboard, Events, Shifts, Tasks, Inventory
│       ├── components/        # UI components
│       ├── services/          # API client
│       ├── contexts/          # Auth context
│       └── types/             # TypeScript types
│
├── backend/                   # FastAPI Backend
│   └── app/
│       ├── api/routes/        # API endpoints
│       ├── models/            # SQLAlchemy models
│       ├── schemas/           # Pydantic schemas
│       └── services/          # Business logic
│
└── app-store-assets/          # Screenshots, icons

---

## 🔗 Live URLs

| Service | URL |
|---------|-----|
| Owner PWA | https://owner-3m18tjk4b-l3lim3d-2348s-projects.vercel.app |
| Backend API | https://wiesbade-after-dark-production.up.railway.app |
| Supabase | https://exjowhbyrdjnhmkmkvmf.supabase.co |

---

## 📱 iOS App Features Status

| Feature | Status | Performance |
|---------|--------|-------------|
| Onboarding | ✅ | Good |
| Auth | ✅ | Good |
| Home | ✅ | 🔴 Slow images |
| Venues | ✅ | 🔴 Slow images |
| Events | ✅ | 🔴 Slow images |
| Community | ✅ | Good |
| Profile | ✅ | Good |
| Check-in | ✅ | Good |
| Tab Bar | ✅ | Good |

---

## 🎯 Current Sprint Tasks

1. **iOS App Optimization** - Fix slow image loading
2. **Connect iOS ↔ PWA** - Sync events between apps
3. **Security & Testing** - E2E tests, security audit
4. **Das Wohnzimmer Testing** - On-site next week

---

## 📝 How to Use MCPs

# Archon - Task management
"Use Archon MCP to create task: [description]"

# Supabase - Database
"Use supabase-toolkit skill for migrations"

# Apple Docs - iOS
"Check SwiftUI knowledge base for [topic]"

# Playwright - Testing
"Use Playwright MCP to create E2E tests"

---

**Document maintained by:** Ali
**Project:** WiesbadenAfterDark
