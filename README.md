# beYou — Hobby Social Platform

**beYou** is a full-stack mobile application built with Flutter for iOS, designed as a social content-sharing platform centred around personal hobbies. Users discover, create, and engage with hobby-specific content, connect with like-minded people nearby on a live map, and chat with an AI-powered assistant — all backed by a real-time Firebase infrastructure.

---

## Table of Contents

- [Overview](#overview)
- [Core Features](#core-features)
- [Technical Stack](#technical-stack)
- [Architecture & Project Structure](#architecture--project-structure)
- [Firebase Integration](#firebase-integration)
- [Screens & Navigation](#screens--navigation)
- [State Management](#state-management)
- [Authentication](#authentication)
- [AI Integration](#ai-integration)
- [Maps & Geolocation](#maps--geolocation)
- [Getting Started](#getting-started)

---

## Overview

beYou enables users to express themselves through their hobbies. Upon registration, users go through a personalised onboarding flow where they select their hobbies (e.g., Cars, Music, Running, Traveling, Art, Cooking) and answer preference questions. The platform then tailors a "For You" feed, surfaces relevant community groups, and shows nearby users on a live Google Map — creating a hyper-personalised social experience.

---

## Core Features

### 🔐 Authentication
- **Email & Password** sign-in and registration via Firebase Authentication
- **Google Sign-In** via `google_sign_in` package
- **Sign In with Apple** via `sign_in_with_apple` (displayed only on iOS/macOS)
- Persistent auth state using `GoRouterRefreshStream` — routes automatically redirect when auth state changes
- User documents created in Firestore on first sign-up, including display name, email, and last-known GPS location

### 🏠 Home Feed
- Displays hobby content from Firestore in card format, grouped by content type: **Tips**, **Challenges**, and **Recommendations**
- **Home** mode: shows all content across all hobbies
- **For You** mode: filters content to match the user's own hobby selection
- Horizontal scrolling card rows with random item sampling for freshness on each visit
- Tapping a card navigates to a full **Detail Page**

### 📝 Content Creation
- Users can create and publish their own hobby posts with:
  - A cover image (picked from device gallery and uploaded to Firebase Storage)
  - A title, description, content type (Challenge, Tip, Recommendation, or custom), hobby category, and optional hashtag metadata
- Uploaded content is stored in the `hobbyContent` Firestore collection and immediately visible in the feed

### 📄 Detail Page
- Full-page view of individual content pieces
- Displays image, title, description, metadata/tags, like count, and content creator info
- **Like** and **Bookmark** functionality with real-time Firestore write-back
- **Comments** section with live Firestore stream
- **Join** button for challenge-type content, adding the user to a `participants` sub-collection

### 🌍 Community Page
- Horizontally scrolling list of **all registered users**, showing their avatar, name, and up to 3 hobby tags
- List of **Hobby Groups** from Firestore with description and associated hobby colour coding
- Users can **Join** groups directly from the community page; join status is checked and reflected in real time
- Tapping a group navigates to its dedicated **Group Chat** page

### 💬 Group Chat
- Real-time group messaging using Firestore's `onSnapshot` streams
- Messages display sender avatar, timestamp, and bubble-style layout distinguishing current user from others
- Chat messages stored per group in a `messages` sub-collection

### 🤖 AI Chatbot
- One-on-one conversational assistant powered by **Google Gemini Pro** (`gemini-pro` via `google_generative_ai` package)
- User messages and bot responses are persisted in Firestore under `chatbotMessages/{userId}/messages`
- Chat history is loaded from Firestore on each session, providing continuity across app launches
- Bubble-style UI with user avatar fetched from their Firestore profile

### 🗺️ Map (Nearby Users)
- Full-screen **Google Maps** integration showing all registered users as custom circular avatar markers
- Users' last known location is stored in Firestore as a `GeoPoint` and updated on login
- Filter between **All Users** and **Similar Hobbies** — the latter only shows users who share at least one hobby with the current user
- Tapping a map marker shows a bottom overlay card with the user's name, avatar, hobbies, and distance (in km)
- Custom marker rendering: user avatars are downloaded, clipped into circles, and painted as `BitmapDescriptor` map icons

### 👤 Profile
- View and edit your own profile (display name, profile photo)
- View any other user's profile by tapping them in the Community or Map page
- Profile photo uploaded to Firebase Storage; URL stored in Firestore
- Displays hobby tags with colour coding
- Quick links to: **Liked Contents**, **Bookmarks**, and **Created Posts**
- Logout button with Firebase Auth sign-out

### ❤️ Likes & Bookmarks
- **Liked Contents**: All posts the user has liked, fetched from Firestore
- **Bookmarks**: Locally persisted via a `BookmarkProvider` (using `shared_preferences` or in-memory state), also synced where applicable
- **Created Posts**: All content the user themselves has published

### 🎯 Onboarding (Hobby Selection Flow)
- Multi-step onboarding flow (`StartPage` → `HobbyFlowPage`) after first registration
- Users select their hobbies from a visual grid of illustrated hobby tiles
- For each selected hobby, users complete a preference questionnaire (e.g., skill level, interests)
- Results stored in a `hobby_details` sub-collection under the user's Firestore document, powering the "For You" feed and map filters

---

## Technical Stack

| Category              | Technology                                      |
|-----------------------|-------------------------------------------------|
| **Framework**         | Flutter (Dart), targeting iOS                   |
| **Backend / BaaS**    | Firebase (Firestore, Auth, Storage)             |
| **Navigation**        | `go_router` with auth-aware redirect guards     |
| **State Management**  | `provider` (ChangeNotifier pattern)             |
| **Maps**              | Google Maps Flutter + Geolocator                |
| **AI**                | Google Gemini Pro (`google_generative_ai`)      |
| **Image Handling**    | `image_picker`, `cached_network_image`, `firebase_storage` |
| **Auth Providers**    | Firebase Auth, Google Sign-In, Sign in with Apple |
| **Icons & UI**        | `lucide_icons`, `font_awesome_flutter`, `material_design_icons_flutter`, `flutter_svg` |
| **Utilities**         | `uuid`, `intl`, `dart_openai`, `go_router`      |

---

## Architecture & Project Structure

```
lib/
├── main.dart                   # App entry point; Firebase init; multi-provider setup
├── app.dart                    # GoRouter config; route definitions; auth redirect logic
├── home.dart                   # Home feed with hobby content cards and filter tabs
├── community.dart              # Community page: users list + groups list
├── profile.dart                # User profile view/edit page
├── create.dart                 # Content creation page (image + form + upload)
├── detail.dart                 # Content detail page (likes, comments, bookmarks)
├── maps.dart                   # Google Maps page with live user markers
├── chatbot.dart                # Gemini AI chatbot page
├── groupchat.dart              # Real-time group chat page
├── start.dart                  # Onboarding: hobby selection grid
├── flow.dart                   # Onboarding: per-hobby preference questionnaire
├── views.dart                  # "View All" page for content categories
├── liked_content.dart          # Liked posts list
├── bookmarked.dart             # Bookmarked posts list
├── user_created.dart           # User's own published posts
├── firebase_options.dart       # Firebase platform config (auto-generated)
│
├── login/
│   ├── login_page.dart         # Login UI (email/password + Google + Apple)
│   └── register_page.dart      # Registration UI
│
├── components/
│   ├── my_button.dart          # Reusable gradient action button
│   ├── my_textfield.dart       # Reusable glassmorphism text input
│   ├── square_title.dart       # Circular social login icon button
│   └── svg_style.dart          # Transparent SVG icon widget
│
├── cards/
│   └── hobby_card.dart         # Adaptive hobby content cards (tall/wide/default styles)
│
├── navigation/
│   ├── navigation.dart         # Bottom navigation bar widget
│   └── navigation_provider.dart # Navigation state (ChangeNotifier)
│
├── providers/
│   ├── hobby_provider.dart     # Hobby selection state during onboarding
│   └── bookmark.dart           # Bookmark state management
│
└── data_models/                # Data model classes
```

---

## Firebase Integration

### Firestore Collections

| Collection           | Description                                              |
|----------------------|----------------------------------------------------------|
| `users`              | User profile documents (name, email, avatarUrl, lastLocation) |
| `users/{uid}/hobby_details` | Per-user hobby preferences (sub-collection)       |
| `hobbyContent`       | All published hobby posts (title, description, imageUrl, type, hobby, likeCount) |
| `hobbyContent/{id}/comments` | Comments on each post                          |
| `hobbyContent/{id}/participants` | Users who joined a challenge                |
| `groups`             | Community hobby groups (name, description, avatarUrl, hobby) |
| `groups/{id}/members` | Members of each group                                   |
| `chatbotMessages/{uid}/messages` | Per-user AI chat history                      |

### Firebase Storage

| Path                  | Content                             |
|-----------------------|-------------------------------------|
| `hobby_images/{id}.jpg` | User-uploaded content images      |
| `avatars/{uid}.jpg`   | User profile photos                 |

### Security Rules

Firestore and Storage rules are configured to require authenticated access:
```js
allow read, write: if request.auth != null;
```

---

## Screens & Navigation

All routing is handled declaratively via `go_router`. The router listens to Firebase Auth state changes and automatically redirects:
- **Unauthenticated** users → `/login`
- **Authenticated** users trying to access `/login` or `/register` → `/home`

| Route                  | Screen                          |
|------------------------|---------------------------------|
| `/login`               | Login Page                      |
| `/register`            | Registration Page               |
| `/start`               | Onboarding Hobby Selection      |
| `/hobby-setup`         | Onboarding Preference Flow      |
| `/home`                | Main Home Feed                  |
| `/create`              | Create Content Page             |
| `/detail`              | Content Detail Page             |
| `/community`           | Community Page                  |
| `/groupChat/:groupId`  | Group Chat Page                 |
| `/chatbot`             | AI Chatbot Page                 |
| `/profile`             | Own Profile Page                |
| `/profile/:uid`        | Another User's Profile Page     |
| `/liked`               | Liked Content List              |
| `/bookmarks`           | Bookmarked Content List         |
| `/created`             | User's Created Content List     |

The main `HomePage` uses a bottom navigation bar (managed by `NavigationProvider`) to switch between **Home**, **Community**, **Map**, and **Profile** without navigating to new routes.

---

## State Management

The app uses the `provider` package with three global `ChangeNotifier` providers:

- **`HobbyProvider`** — Manages hobby selection state during the onboarding flow
- **`NavigationProvider`** — Tracks the currently selected bottom navigation index
- **`BookmarkProvider`** — Loads and manages bookmarked content, initialised on app launch

---

## Authentication

The app supports three sign-in methods, all powered by Firebase Authentication:

1. **Email & Password** — Standard Firebase Auth with automatic Firestore user document creation on sign-up
2. **Google Sign-In** — OAuth via `google_sign_in`; new users are auto-provisioned in Firestore
3. **Apple Sign-In** — OAuth via `sign_in_with_apple`; shown only on iOS and macOS platforms

After any sign-in, the app checks if a Firestore user document already exists:
- **Existing user** → navigates directly to `/home`
- **New user** → navigates to `/start` (onboarding)

---

## AI Integration

The chatbot page integrates **Google Gemini Pro** using the official `google_generative_ai` Flutter package. Each user has an isolated chat history persisted in Firestore, allowing conversations to be resumed across sessions. The integration uses streaming content generation and displays responses in a real-time message bubble UI.

---

## Maps & Geolocation

The app uses `geolocator` to request and retrieve the device's current GPS position. This location is:
- Stored as a Firestore `GeoPoint` in the user's document at sign-in/registration
- Used to initialise the Google Map camera position
- Used to calculate and display km distances to nearby users in the map overlay card

Custom map markers are generated programmatically by downloading each user's avatar, decoding the image bytes, clipping them into a circle using Flutter's `Canvas` API, and converting the result to a `BitmapDescriptor` for the Google Maps SDK.

---

## Getting Started

### Prerequisites

- Flutter SDK (Channel master, 3.33.0+)
- Xcode 26.5+ with iOS 26 Simulator platform installed
- CocoaPods 1.16.2+
- Firebase project with Firestore, Auth, and Storage enabled
- `GoogleService-Info.plist` placed at `ios/Runner/GoogleService-Info.plist`

### Setup

```bash
# Install Flutter dependencies
flutter pub get

# Install iOS CocoaPods dependencies
cd ios && pod install && cd ..

# Run on iOS Simulator
flutter run -d <simulator-device-id>
```

### Accept Xcode License (first time)
```bash
sudo xcodebuild -license accept
sudo xcodebuild -runFirstLaunch
xcodebuild -downloadPlatform iOS
```

### Hot Reload vs Hot Restart

While the app is running in the terminal:
- Press `r` — **Hot Reload** (fast, preserves state)
- Press `R` — **Hot Restart** (full restart, resets state)
- Press `q` — Quit
