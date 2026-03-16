# PomoDuo - Product Requirements & Architecture

## Product Vision

PomoDuo is a collaborative Pomodoro timer app that connects users to work together in synchronized focus sessions. The app emphasizes peer accountability, social motivation, and progress tracking to help users stay productive alongside their friends.

**Development Philosophy**: Start simple with solo sessions, validate core mechanics, then progressively add social/collaborative features.

## Core Concept

Users can track their productivity using the Pomodoro technique (25min work, 5min break). Initially solo, then expanding to duo sessions with friends, and eventually supporting groups of 4+. The experience is designed to create accountability and motivation through both personal progress tracking and collaborative sessions.

## Phased Rollout Plan

### Phase 1: Solo Pomodoro MVP ⭐ **Start Here**
**Goal**: Validate core Pomodoro timer mechanics and local user experience

**Includes:**
- Single-user Pomodoro sessions (25min work, 5min break, configurable)
- Local timer with pause/resume/stop controls
- Session completion tracking
- Basic local stats (sessions today, this week, total)
- Simple session history (stored locally)
- Optional: User auth for cloud backup/sync across devices
- Clean, minimal UI focused on the timer

**Excludes:**
- Friends/social features
- Real-time sync
- Advanced gamification
- Duo/group sessions
- Push notifications

**Key Learning Goals:**
- Is the timer UX intuitive?
- Do users complete sessions?
- What stats do users care about?
- Session duration preferences?

**Technical Scope:**
- `PomoDuoSession` module (timer logic, local state)
- `PomoDuoStorage` module (local persistence - SwiftData)
- Optional: `PomoDuoAuth` module (basic auth for cloud sync)
- Optional: `PomoDuoHTTPService` (if doing cloud sync)
- Simple navigation (single screen or tab-based for stats)

---

### Phase 2: Social Foundation
**Goal**: Add user profiles and friend connections (read-only social)

**Adds:**
- User authentication (required now)
- User profiles (avatar, username, bio)
- Add friends (search by username/email)
- Friend list
- View friend profiles and stats (read-only)
- Basic presence (online/offline indicators)

**Use Case:**
Users can see their friends' productivity stats, creating passive motivation and social accountability without real-time sessions yet.

**Technical Additions:**
- `PomoDuoAuth` module (full implementation)
- `PomoDuoFriends` module
- Backend API for user/friend management
- Cloud sync for session history

---

### Phase 3: Duo Sessions (Real-time Collaboration)
**Goal**: Enable synchronized Pomodoro sessions between 2 users

**Adds:**
- Session invitations (invite a friend to join)
- Real-time timer synchronization via WebSocket
- Duo session view (see partner's timer status)
- Session notifications (invites, session starting)
- Shared session history ("Sessions with [Friend]")

**Use Case:**
"Want to work together?" - Users can start a synchronized Pomodoro session with a friend, creating real-time accountability.

**Technical Additions:**
- `PomoDuoRealtime` module (WebSocket)
- Real-time session coordination
- Push notifications
- Session invitation system

---

### Phase 4: Enhanced Engagement
**Goal**: Improve retention through gamification and advanced features

**Adds:**
- Achievement system (badges)
- Streak tracking (daily, partner streaks)
- Advanced stats filtering (date ranges, partners)
- Session templates (custom durations)
- Friend activity feed
- Celebration animations

---

### Phase 5: Group Sessions & Scale
**Goal**: Support larger groups and advanced collaboration

**Adds:**
- Group sessions (4+ users)
- In-session reactions/quick messages
- Team/organization accounts
- Custom session configurations
- Scheduled sessions
- Session playlists/ambient sounds

## User Stories

### Phase 1: Solo MVP

#### Timer & Sessions
- As a user, I can start a 25-minute Pomodoro timer
- As a user, I can pause and resume my timer
- As a user, I can stop a session early
- As a user, I see a 5-minute break timer after completing work
- As a user, I receive a notification when my session completes
- As a user, I can customize work/break durations
- As a user, I can see my current session progress

#### Stats & History
- As a user, I can see how many sessions I completed today
- As a user, I can see my weekly session count
- As a user, I can see my total lifetime sessions
- As a user, I can view my session history (date, duration, completed/incomplete)
- As a user, I can see my current daily streak

### Phase 2: Social Foundation

#### Authentication & Profile
- As a user, I can create an account with email/password
- As a user, I can log in and out
- As a user, I can set up my profile (name, avatar, bio)
- As a user, I can view my own profile
- As a user, my session data syncs across devices

#### Friend Management
- As a user, I can search for friends by username
- As a user, I can send friend requests
- As a user, I can accept/decline friend requests
- As a user, I can view my friend list
- As a user, I can remove friends
- As a user, I can view a friend's profile
- As a user, I can see a friend's total stats (sessions completed, streak)

### Phase 3: Duo Sessions

#### Collaborative Sessions
- As a user, I can invite a friend to join a Pomodoro session
- As a user, I can accept/decline session invitations
- As a user, I can see my partner's timer in real-time during a duo session
- As a user, I receive a notification when invited to a session
- As a user, I can see when my partner pauses/resumes
- As a user, I can see session history filtered by "sessions with [Friend]"
- As a user, I see which friends are currently in a session

### Phase 4: Enhanced Engagement

#### Gamification
- As a user, I can see my current streak
- As a user, I can unlock achievements
- As a user, I can see badges on my profile
- As a user, I feel motivated to maintain streaks
- As a user, I see encouragement messages after completing sessions

#### Advanced Stats
- As a user, I can filter sessions by date range (day/week/month/custom)
- As a user, I can see productivity trends over time
- As a user, I can see my most frequent session partners
- As a user, I can export my data

## Technical Architecture

### Modular Structure

#### Phase 1 Modules (Solo MVP)

**`PomoDuoSession` Module** ⭐ **Priority 1**
**Responsibilities:**
- Core Pomodoro timer logic (work/break cycles)
- Session state management (idle, active, paused, break, completed)
- Timer countdown logic
- Session configuration (work duration, break duration, long break)
- Local session persistence
- Session completion tracking

**Key Types:**
```swift
struct Session {
    let id: UUID
    let startTime: Date
    var endTime: Date?
    let workDuration: TimeInterval
    let breakDuration: TimeInterval
    var state: SessionState
    var isCompleted: Bool
}

enum SessionState {
    case idle
    case working(remainingSeconds: Int)
    case onBreak(remainingSeconds: Int)
    case paused(pausedAt: TimeInterval)
    case completed
}

protocol SessionManager {
    func startSession(config: SessionConfig) async throws
    func pauseSession() async throws
    func resumeSession() async throws
    func stopSession() async throws
    var currentSession: Session? { get }
    var sessionPublisher: Published<Session?>.Publisher { get }
}

struct SessionConfig {
    var workDuration: TimeInterval = 25 * 60  // 25 minutes
    var breakDuration: TimeInterval = 5 * 60  // 5 minutes
    var longBreakDuration: TimeInterval = 15 * 60  // 15 minutes
    var sessionsUntilLongBreak: Int = 4
}
```

**`PomoDuoStorage` Module** ⭐ **Priority 2**
**Responsibilities:**
- Local database (SwiftData)
- Session history CRUD
- Stats calculations
- Data persistence
- Cache management

**Key Types:**
```swift
protocol SessionRepository {
    func save(session: Session) async throws
    func fetchSessions(from: Date, to: Date) async throws -> [Session]
    func fetchAllSessions() async throws -> [Session]
    func deleteSession(id: UUID) async throws
}

protocol StatsCalculator {
    func sessionsToday() async -> Int
    func sessionsThisWeek() async -> Int
    func totalSessions() async -> Int
    func currentStreak() async -> Int
}
```

**`PomoDuoHTTPService` Module** ✅ **Already Exists**
- Used in later phases for cloud sync and API calls

---

#### Phase 2 Modules (Social Foundation)

**`PomoDuoAuth` Module**
**Responsibilities:**
- User authentication (signup, login, logout)
- Token management (JWT storage, refresh)
- User profile management
- Password reset

**Key Types:**
```swift
struct User {
    let id: String
    var username: String
    var email: String
    var avatarURL: URL?
    var createdAt: Date
}

protocol AuthService {
    func signUp(email: String, password: String, username: String) async throws -> User
    func login(email: String, password: String) async throws -> User
    func logout() async throws
    func getCurrentUser() async -> User?
    var currentUser: User? { get }
}
```

**`PomoDuoFriends` Module**
**Responsibilities:**
- Friend list management
- Friend requests (send/accept/reject)
- User search
- Friend presence (online/offline)

**Key Types:**
```swift
struct Friend {
    let user: User
    var status: FriendStatus
    var becameFriendsAt: Date
}

enum FriendStatus {
    case online
    case offline
    case inSession
}

struct FriendRequest {
    let id: String
    let from: User
    let to: User
    let sentAt: Date
    var status: RequestStatus
}

enum RequestStatus {
    case pending
    case accepted
    case rejected
}

protocol FriendService {
    func searchUsers(query: String) async throws -> [User]
    func sendFriendRequest(to userId: String) async throws
    func acceptFriendRequest(id: String) async throws
    func rejectFriendRequest(id: String) async throws
    func getFriends() async throws -> [Friend]
    func removeFriend(userId: String) async throws
}
```

**`PomoDuoStats` Module**
**Responsibilities:**
- Advanced stats calculations
- History filtering
- Cloud sync of stats
- Data aggregation

---

#### Phase 3 Modules (Duo Sessions)

**`PomoDuoRealtime` Module**
**Responsibilities:**
- WebSocket connection management
- Real-time event handling
- Session synchronization
- Reconnection logic
- Presence broadcasting

**Key Types:**
```swift
protocol RealtimeService {
    func connect() async throws
    func disconnect()
    func joinSession(id: String) async throws
    func leaveSession(id: String) async throws
    func sendEvent(_ event: SessionEvent) async throws
    var eventPublisher: Published<SessionEvent>.Publisher { get }
}

enum SessionEvent {
    case timerStarted(at: Date)
    case timerPaused(at: Date, remaining: TimeInterval)
    case timerResumed
    case sessionCompleted
    case userJoined(User)
    case userLeft(User)
}

struct DuoSession {
    let id: String
    let participants: [User]
    let config: SessionConfig
    var state: SessionState
    let createdAt: Date
}
```

---

#### Phase 4 Modules (Enhanced Engagement)

**`PomoDuoGamification` Module**
**Responsibilities:**
- Achievement system
- Streak calculation and tracking
- Badge management
- Progress milestones

**Key Types:**
```swift
struct Achievement {
    let id: String
    let name: String
    let description: String
    let badgeIcon: String
    let unlockedAt: Date?
    var isUnlocked: Bool { unlockedAt != nil }
}

struct Streak {
    let type: StreakType
    var currentCount: Int
    var bestCount: Int
    var lastActiveDate: Date
}

enum StreakType {
    case daily
    case partner(friendId: String)
}

protocol GamificationService {
    func checkAchievements() async throws -> [Achievement]
    func getStreaks() async throws -> [Streak]
    func recordSessionForStreak(session: Session) async throws
}
```

## Navigation Architecture

### Phase 1: Solo MVP Navigation

**Simple Single-Screen or Tab Navigation:**

#### Option A: Single Primary Screen
```
ContentView
├─ Timer View (main focus)
│  ├─ Circular timer display
│  ├─ Start/Pause/Resume/Stop buttons
│  └─ Current session info
│
└─ Sheet: Stats & History
   ├─ Today's stats
   ├─ Weekly stats
   ├─ Session history list
   └─ Settings (timer preferences)
```

#### Option B: Simple Tabs (Recommended)
```
TabView
├─ Timer Tab (main)
│  ├─ Circular timer display
│  ├─ Session controls
│  └─ Quick stats (sessions today)
│
└─ Stats Tab
   ├─ Session counts (today/week/total)
   ├─ Current streak
   ├─ Session history list
   └─ Settings button → Settings sheet
```

**Coordinator (Minimal):**
```swift
@Observable
class AppCoordinator {
    var selectedTab: AppTab = .timer
    var showingSettings = false
    var showingSessionHistory = false
}

enum AppTab {
    case timer
    case stats
}
```

---

### Phase 2: Social Foundation Navigation

**Add Friends Tab:**
```
TabView
├─ Timer Tab
├─ Friends Tab (new)
│  ├─ Friend List
│  ├─ Friend Requests badge
│  ├─ Search/Add Friends
│  └─ Friend Profile → Stats view
│
├─ Stats Tab
└─ Profile Tab (new)
   ├─ Your profile
   ├─ Settings
   └─ Logout
```

---

### Phase 3: Duo Sessions Navigation

**Update Timer Tab for Sessions:**
```
TabView
├─ Session Tab (renamed from Timer)
│  ├─ Session Lobby (when idle)
│  │  ├─ Start Solo Session
│  │  └─ Invite Friend to Duo Session
│  ├─ Active Session View
│  │  ├─ Your timer
│  │  ├─ Partner's timer (if duo)
│  │  └─ Session controls
│  └─ Session Complete View
│
├─ Friends Tab
│  └─ Shows who's online/in session
│
├─ Stats Tab
│  └─ Filter by partner
│
└─ Profile Tab
```

**Deep Linking:**
- `pomoduo://session/invite/{sessionId}` → Accept session invitation
- `pomoduo://friends/request/{userId}` → Friend request

## State Management

### Phase 1: Solo Sessions

**App-Level State:**
- Current session (shared between tabs)
- Session configuration
- User preferences

**Tab-Specific State:**
- Timer UI state (animations, button states)
- Stats filtering/sorting
- History pagination

**Dependency Injection:**
```swift
extension Container {
    // Session module
    var sessionManager: Factory<SessionManager> {
        Factory(self) { _SessionManager() }
            .scope(.singleton)  // Shared across app
    }

    var sessionRepository: Factory<SessionRepository> {
        Factory(self) { SwiftDataSessionRepository() }
            .scope(.singleton)
    }

    var statsCalculator: Factory<StatsCalculator> {
        Factory(self) { _StatsCalculator(repository: self.sessionRepository()) }
    }
}
```

### Phase 2+: Add Auth & Friends
```swift
extension Container {
    var authService: Factory<AuthService> {
        Factory(self) { _AuthService(httpService: self.pomoDuoHTTPService()) }
            .scope(.singleton)
    }

    var friendService: Factory<FriendService> {
        Factory(self) { _FriendService(httpService: self.pomoDuoHTTPService()) }
    }
}
```

## Backend Communication Strategy

### Phase 1: Solo MVP
**Backend: Optional (Local-First)**
- Can work entirely locally with SwiftData
- Optional: Simple cloud backup/sync API for session history

### Phase 2: Social Foundation
**Backend: Required**
- REST API for user management, authentication, friends
- Session history sync to cloud

**Endpoints:**
```
POST   /auth/signup
POST   /auth/login
POST   /auth/logout
GET    /users/me
PUT    /users/me
GET    /users/search?q={query}
POST   /friends/request
POST   /friends/{id}/accept
DELETE /friends/{id}
GET    /friends
GET    /sessions (cloud sync)
POST   /sessions (cloud sync)
```

### Phase 3: Duo Sessions
**Real-time: WebSocket**
- Session synchronization
- Presence updates
- Live notifications

**WebSocket Events:**
```
// Client → Server
session.join
session.leave
session.start
session.pause
session.resume

// Server → Client
session.user_joined
session.user_left
session.timer_sync
session.completed
```

## Design Principles

### User Experience
- **Focus First**: Timer should be the hero, minimal distractions
- **Fast & Responsive**: No lag between tap and timer response
- **Clear Feedback**: Always show current state (working, break, paused)
- **Accessible**: VoiceOver support, dynamic type, haptic feedback
- **Delightful**: Smooth animations, encouraging messages

### Technical
- **Modular**: Each feature is an independent module
- **Testable**: Business logic separate from UI
- **Type-Safe**: Leverage Swift's type system
- **Local-First**: Work offline, sync when online
- **Progressive**: Start simple, add complexity incrementally

### Social (Phase 2+)
- **Opt-in**: Social features don't interfere with solo experience
- **Positive**: Celebrate progress, no shaming
- **Privacy**: User controls data visibility

## Success Metrics

### Phase 1: Solo MVP
- **Activation**: % of users who complete their first session
- **Engagement**: Sessions per active user per day
- **Retention**: Day 1, Day 7 retention
- **Completion**: % of started sessions that are completed
- **Quality**: Average session duration, pause frequency

### Phase 2: Social Foundation
- **Social Activation**: % of users who add at least one friend
- **Friend Growth**: Average friends per user
- **Request Acceptance**: Friend request acceptance rate

### Phase 3: Duo Sessions
- **Duo Adoption**: % of users who try duo sessions
- **Duo Retention**: % continuing duo sessions after first
- **Session Mix**: Duo vs solo session ratio
- **Partnership**: Repeat duo partnerships

## Open Questions

### Phase 1 (Immediate)
1. Should we include background timers (app closed but timer continues)?
2. Local notifications when session/break ends?
3. What default session durations? (25/5/15 or customizable from start?)
4. Should breaks be mandatory or skippable?
5. Auto-start next session or require manual start?
6. Session naming/tagging (e.g., "Study", "Work", "Exercise")?

### Phase 2 (Social)
1. Username requirements (unique, length, characters)?
2. Avatar upload or use service like Gravatar?
3. Friend limit? (e.g., max 100 friends)
4. Privacy levels for stats (public, friends-only, private)?

### Phase 3 (Duo)
1. If one user pauses, does partner's timer pause too?
2. Can users join mid-session?
3. What if one user loses connection?
4. Session creator controls (can kick users, change settings)?
5. Invitation expiry time?

### Technical
1. **Backend choice**: Custom API, Firebase, Supabase, AWS Amplify?
2. **Storage**: SwiftData (iOS 17+) or Core Data (broader support)?
3. **Notifications**: Local only (Phase 1) or APNs from start?
4. **Analytics**: Built-in, Firebase, Mixpanel, or wait until later?
5. **Deployment target**: iOS 17+ (SwiftData, new APIs) or iOS 16+ (broader reach)?

## Phase 1 MVP - Detailed Scope

### Must Have (Launch Blockers)
- ✅ Start/pause/resume/stop timer
- ✅ Work session (25min default)
- ✅ Break session (5min default)
- ✅ Session completion tracking
- ✅ Basic stats (today, week, total)
- ✅ Session history list
- ✅ Local persistence (SwiftData)
- ✅ Settings (customize durations)
- ✅ Local notifications (session/break complete)

### Should Have (Important but can defer)
- Timer sound/haptic feedback
- Background timer support
- Session categories/tags
- Current streak calculation
- Long break after 4 sessions
- Dark mode support

### Could Have (Nice to have)
- Customizable timer sounds
- Multiple timer presets
- Session notes
- Export session data
- Widgets

### Won't Have (Phase 1)
- User accounts
- Cloud sync
- Friends
- Duo sessions
- Achievements
- Notifications beyond local

## Next Steps

1. ✅ Document product vision and architecture
2. ⏭️ Define Phase 1 MVP detailed requirements
3. ⏭️ Design Phase 1 navigation structure
4. ⏭️ Build `PomoDuoSession` module (timer logic)
5. ⏭️ Build `PomoDuoStorage` module (persistence)
6. ⏭️ Build UI for timer screen
7. ⏭️ Build UI for stats screen
8. ⏭️ Add local notifications
9. ⏭️ Testing and polish
10. ⏭️ Phase 1 launch preparation
