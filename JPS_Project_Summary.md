# JPS Case Management System — Project Summary

> Created: 2026-05-11 | Last updated: 2026-05-20 (Session 4)
> Three connected applications built in one project session.

---
## Session 1 — 2026-05-11

## Group 1 — Python FastAPI Backend

### What was built
A REST API server connecting the iOS app and the Windows app to a shared MySQL database.

### Stack
- Python + FastAPI + SQLAlchemy ORM + PyMySQL
- JWT authentication (via `python-jose`)
- bcrypt password hashing (via `passlib`, pinned to `bcrypt==3.2.2`)
- MySQL database (`jps_case_db`)

### Key files
| File | Purpose |
|---|---|
| `backend/main.py` | App entry point, CORS middleware, router registration |
| `backend/database.py` | SQLAlchemy engine + session factory |
| `backend/models.py` | ORM models: `User`, `Employee`, `Case` |
| `backend/schemas.py` | Pydantic request/response schemas |
| `backend/auth.py` | JWT creation, token decoding, auth dependencies |
| `backend/routers/users.py` | iOS user register/login + list users |
| `backend/routers/employees.py` | Windows employee register/login |
| `backend/routers/cases.py` | CRUD for cases (create, update, query) |
| `backend/database_setup.sql` | Full MySQL schema + migration commands |

### Run command
```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```
Swagger UI available at: `http://<server-ip>:8000/docs`

### Authentication design
Two completely separate JWT systems:
- **iOS users** → POST `/auth/login` → token contains `sub` claim
- **Windows employees** → POST `/employees/login` → token contains `emp_sub` claim
- `get_any_actor()` dependency accepts either token type on shared endpoints (e.g. GET/PUT `/cases`)

### Database tables
- `users` — iOS app accounts (`role`: admin / officer / viewer)
- `employees` — Windows app accounts (standalone, no link to users table)
- `cases` — case records (`created_by_id` nullable so employees can create cases)

### Problems solved
- `bcrypt` version conflict → pinned to `bcrypt==3.2.2`
- FastAPI version conflict → removed version pin, let pip resolve
- 401 errors after migration → re-run SQL migration + force re-login on both apps
- iOS app couldn't connect → disabled Windows Firewall / opened port 8000

---

## Group 2 — iOS SwiftUI App

### What was built
A mobile app for field officers to register, log in, submit cases, and receive case update notifications.

### Stack
- Swift + SwiftUI
- URLSession for HTTP calls
- Native iOS notifications

### Key views
| View | Purpose |
|---|---|
| `ContentView.swift` | Root view — routes between login and main |
| `LoginView.swift` | Username / password login form with JPS logo |
| `RegisterView.swift` | New user registration |
| `CreateCaseView.swift` | Form to submit a new case |
| `CaseListView.swift` | List of cases assigned to / created by the officer |
| `NotificationView.swift` | Case update notifications |

### Authentication flow
1. POST `/auth/login` with `{ username, password }`
2. Store returned JWT in app state
3. Attach `Authorization: Bearer <token>` header on all subsequent requests

### How to add Swift files to a project
1. In Xcode: **File → New → File → Swift File**
2. Make sure the target checkbox is ticked
3. Add code, then build with ⌘B

### Problems solved
- App could not connect to server → Windows Firewall was blocking port 8000; fix: disable firewall or add inbound rule for port 8000

---

## Group 3 — Windows WinForms App (C#)

### What was built
A desktop application for JPS employees to log in, view/filter/search cases, create new cases, and edit existing ones.

### Stack
- C# / .NET 8 (net8.0-windows)
- Windows Forms (WinForms)
- Newtonsoft.Json for HTTP response deserialization
- HttpClient for REST API calls

### Key files
| File | Purpose |
|---|---|
| `Program.cs` | Entry point — `Application.Run(new LoginForm())` |
| `AppSession.cs` | Static session holder (Token + CurrentEmployee) |
| `Config.cs` | Server base URL setting |
| `Models/AppModels.cs` | C# models matching API schemas |
| `Services/ApiService.cs` | All HTTP calls (login, get/create/update cases, list users) |
| `Forms/LoginForm.cs` | Employee login UI + logic |
| `Forms/MainForm.cs` | Case list grid, search/filter, toolbar |
| `Forms/MainForm.Designer.cs` | WinForms control layout |
| `Forms/CaseDetailForm.cs` | Create / edit case dialog |

### Key design decisions

**Employee auth (separate from iOS users)**
- `AppSession.CurrentEmployee` holds `EmployeeOut` (not `UserOut`)
- Login calls `POST /employees/login`; token stored in `AppSession.Token`

**DataGridView display fix (long-running issue)**
The grid was blank for many attempts. Root causes found and fixed:
1. Visual Studio kept regenerating `MainForm.Designer.cs`, wiping custom column names
2. `Controls.Add()` order was wrong — Fill control must be added **first** so layout engine gives it leftover space; Top/Bottom panels added **last** claim their edges first
3. Fix: `SetupControls()` method in `MainForm.cs` (VS never touches `.cs` files) always runs after `InitializeComponent()` and rebuilds grid columns from scratch

**Correct Controls.Add docking order**
```csharp
Controls.Add(grid);         // Fill  — processed last → gets remaining middle space
Controls.Add(statusStrip);  // Bottom
Controls.Add(pnlBottom);    // Bottom — above statusStrip
Controls.Add(pnlHeader);    // Top    — below toolbar
Controls.Add(pnlToolbar);   // Top    — processed first → claims very top
```

**Logout button not visible fix**
`btnLogout` was hidden behind `lblAppTitle` (DockStyle.Fill). Fix: add `btnLogout` to `pnlHeader.Controls` **before** `lblAppTitle` so it has a higher Z-order and renders on top.

**App staying alive in background fix**
`LoginForm.DoLogin()` was calling `Hide()` instead of closing the form. Since `Application.Run(new LoginForm())` keeps the process alive until that form closes, the process never exited.

Fix in `LoginForm.cs`:
```csharp
main.FormClosed += (_, _) =>
{
    txtPassword.Clear();
    Show();   // re-show original login form
};
main.Show();
Hide();
```

Fix in `MainForm.cs` logout:
```csharp
private void btnLogout_Click(object sender, EventArgs e)
{
    AppSession.Clear();
    Close();   // FormClosed handler re-shows LoginForm automatically
}
```

Now the process only exits when the user closes the LoginForm itself.

### Problems solved (summary)
| Problem | Fix |
|---|---|
| Build error: app.ico not found | Removed ico reference from .csproj |
| Cannot see form designer | Added `<SubType>Form</SubType>` in .csproj |
| Grid shows count but no rows | WinForms docking order bug + SetupControls() pattern |
| Logout button invisible | Z-order fix — add button before Fill label in panel |
| App running in background after close | LoginForm.FormClosed re-show pattern |
| VS regenerating Designer.cs | SetupControls() in MainForm.cs overrides whatever VS generates |

---

*Next possible features: push notifications to iOS when case is updated, admin panel for user management, case history/audit log, export to PDF/Excel, role-based dashboard access.*

---
## Session 2 — 2026-05-15

### iOS — Case Resolved Notifications (Local + Background)

Field officers now receive an iOS notification whenever one of their cases is changed to **Resolved** status by an employee — both while the app is open and while it is suspended in the background.

#### How it works

**Foreground (app open):** The existing poll timer (`Config.pollInterval` = 10 s) already fetches cases on a loop. After this change, each poll compares the new status of every case against the last known status. If any case transitioned to `.resolved`, a local notification fires immediately.

**Background (app suspended):** iOS's `BGAppRefreshTask` framework wakes the app briefly in the background (roughly every 15 minutes, iOS-controlled). The background task runs the same fetch-and-compare logic and fires a local notification if needed, then schedules the next wake-up.

The status snapshot is persisted to `UserDefaults` so foreground polls and background tasks share the same state and never double-notify.

#### New / changed files

| File | Change |
|---|---|
| `NotificationManager.swift` | **New** — wraps `UNUserNotificationCenter`; requests permission; fires `"Case Resolved ✓"` banners; delegate ensures banners show even while the app is in foreground |
| `BackgroundTaskManager.swift` | **New** — registers/schedules `BGAppRefreshTask`; runs the case fetch in background; reads/writes the `UserDefaults` status snapshot |
| `JPSCaseApp.swift` | Added `init()` to request notification permission and register the background task; added `onChange(of: scenePhase)` to re-schedule the background task whenever the app moves to `.background` |
| `CaseViewModel.swift` | Added `previousStatuses: [Int: CaseStatus]` tracking; detects resolved transitions on every poll and fires `NotificationManager`; loads snapshot from `UserDefaults` on init and saves after each fetch |
| `Info.plist` | Added `BGTaskSchedulerPermittedIdentifiers` → `["com.jps.caseapp.refresh"]` |

#### Required Xcode setup (one-time)

1. Select the **JPSCaseApp** target → **Signing & Capabilities** tab
2. Click **"+"** → add **Background Modes**
3. Tick **Background fetch**

#### Background refresh interval

Set in `BackgroundTaskManager.swift`:
```swift
request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)  // 15 minutes minimum
```
`earliestBeginDate` is a *minimum* — iOS may delay beyond it based on battery and usage patterns.

#### Testing on the Simulator

Background tasks never fire automatically on the simulator. To trigger one manually:

1. Run the app → press Home (Shift+Cmd+H)
2. In the Xcode debugger console, run:
```
e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.jps.caseapp.refresh"]
```
3. Resume (Ctrl+Cmd+Y) — the background fetch executes and any resolved-case notification appears.

On a real iPhone, iOS triggers the background task automatically.

---

## Session 3 — 2026-05-18 to 2026-05-20

### dashboard.html — Analytics Dashboard & CLAUDE.md

#### What was built
A standalone single-file HTML analytics dashboard (`dashboard.html`) at the repo root, connecting directly to the FastAPI backend with an employee login gate and four interactive Chart.js charts. A `CLAUDE.md` codebase guide was also created in this session.

#### Stack
- Vanilla HTML / CSS / JavaScript (no build step)
- Chart.js 4.4.1 (cdnjs CDN)
- Backend API at `http://192.168.66.4:8282`

#### Dashboard features

**Login & session** — Full-screen employee login form calls `POST /employees/login`. Session is saved to `localStorage` so page refresh stays logged in. Expired tokens auto-logout. Sign Out button in the header.

**Case data fetching** — Paginates through all pages of `GET /cases` (`skip` / `limit`, max 100 per request) with a loading overlay showing progress and a Retry button on failure.

**KPI cards** — Total Cases, Open (with %), In Progress (with %), Resolved (resolution rate %).

**Charts** — All four charts share Daily / Weekly / Monthly filter pills. Selecting Daily reveals a From → To date picker (pre-filled to last 14 days).

| # | Chart | Type | What it shows |
|---|---|---|---|
| 1 | Cases Opened & Resolved | Grouped bar | Opened (pink) vs resolved (green) per time bucket |
| 2 | Delivery Provider Breakdown | Doughnut | % split — Uber / DoorDash / GrabHub / Self Delivery |
| 3 | Case Resolve Time | Bar | Avg hours or days from `created_at` → `updated_at` (resolved cases only); Hours/Days toggle |
| 4 | Complaint Type Breakdown | Doughnut | % split — Not Received / Bad Quality / Missing Item / Wrong Order; colors: orange, purple, cyan, pink |

#### Key JS functions
| Function | Purpose |
|---|---|
| `doLogin()` / `logout()` | Auth — POST login, save/clear `localStorage` session |
| `loadAllCases()` | Paginate all case pages, then call `buildDashboard()` |
| `buildDashboard()` | Run all four render functions + `updateKPIs()` |
| `renderCases()` / `renderPie()` / `renderResolve()` / `renderComplaint()` | Build each Chart.js chart |
| `setFilter()` / `onDateChange()` | Handle pill clicks and date-range inputs, re-render |
| `makeBuckets()` / `cutoffDate()` | Generate time-bucket keys for the selected range |

#### How to serve the dashboard
```bash
# Option 1 — Python (no code changes)
cd "JPS Case Management"
python -m http.server 8080
# → http://192.168.66.4:8080/dashboard.html
```
```python
# Option 2 — FastAPI (single port), add to main.py:
@app.get("/dashboard")
def serve_dashboard():
    return FileResponse("dashboard.html")
# Copy dashboard.html into backend/ → http://192.168.66.4:8282/dashboard
```

#### CLAUDE.md
Created at the repo root documenting run commands for all three apps, the dual JWT auth design (`sub` vs `emp_sub`, `get_any_actor()`), authorization rules in `cases.py`, the `cases.created_by_id` nullable design, the WinForms `Controls.Add()` docking order, the `bcrypt==3.2.2` pin, and server URL config locations.

#### Git
`dashboard.html` and `CLAUDE.md` committed and pushed to `origin/main` (commit `f9d32ec`).
