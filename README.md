# TwitterClone (Flutter + Firebase)

A full-featured Twitter-like mobile application built with Flutter and Firebase. This project demonstrates production-grade architecture, modular feature design, real-time capabilities, and clean state management using Provider. It includes authentication, timeline, tweet composition with media, messaging, notifications, bookmarks, search, profile management, and a robust theming system.

This repository was reconstructed from an earlier completed app and carefully migrated with granular commits per feature to reflect a realistic development history.

## Table of Contents
- Overview
- Feature Highlights
- Architecture & Design
- Tech Stack
- Project Structure
- State Management
- Navigation & Routing
- Dependency Injection
- Firebase Integration
- Theming & Styles
- Media & Link Preview
- Notifications (FCM)
- Authentication
- Feed & Tweets
- Messaging (DM)
- Search
- Bookmarks
- Settings
- Build & Run
- Environment Configuration
- iOS & Android Setup Notes
- Testing
- Screenshots
- Roadmap
- Contributing
- License

---

## Overview
TwitterClone is a production-quality Flutter application that mirrors core Twitter functionality with a clean, extensible architecture. It uses Firebase (Auth, Firestore/RealtimeDatabase, Storage, Messaging, Dynamic Links, Remote Config, Analytics) for backend services.

Key goals:
- Clean separation of concerns (UI, State, Model, Helper, Resource)
- Feature-first structure to scale independently
- Robust theming and typography
- Real-time updates for feed and messaging
- Offline-friendly where possible (image cache, shared prefs)

## Feature Highlights
- Firebase Auth (email/password + Google)
- Tweet creation with images (image picker + storage)
- Timeline: likes, retweets, replies, link previews
- Profile: follow/unfollow, edit profile, QR code share/scan
- Messaging: 1:1 chats, typing indicators (if enabled), read states
- Notifications: likes, follows, retweets, replies
- Bookmarks: save/unsave tweets
- Search: users, tweets, hashtags, trending
- Settings: privacy/safety, notifications, display & sound, data usage, content prefs, accessibility, proxy

## Architecture & Design
- UI (widgets/pages) is kept declarative and dumb: reads from Providers
- State layer (ChangeNotifier) encapsulates feature business logic
- Models are plain Dart data classes with JSON (de)serialization
- Services (resource/) provide platform/SDK bridges (e.g., FCM)
- Helpers centralize cross-cutting concerns (routes, validators, prefs)

## Tech Stack
- Flutter (Dart)
- Provider (state management)
- Firebase: Auth, Firestore/Realtime DB, Storage, Messaging, Remote Config, Dynamic Links, Analytics
- Google Sign-In
- Cached network images
- Image picker
- Share Plus, URL launcher, Intl
- QR code scanner & generator
- Google Fonts

## Project Structure
```
lib/
  main.dart
  helper/
  model/
  resource/
  state/
    base/
    chats/
  ui/
    page/
      Auth/
      bookmark/
      common/
      feed/
        composeTweet/
          state/
          widget/
      message/
        conversationInformation/
      notification/
        widget/
      profile/
        follow/
        qrCode/
        widgets/
      search/
      settings/
        accountSettings/
          about/
          accessibility/
          contentPrefrences/
            trends/
          dataUsage/
          displaySettings/
          notifications/
          privacyAndSafety/
            directMessage/
          proxy/
        widgets/
    theme/
      color/
  widgets/
    bottomMenuBar/
    newWidget/
    tweet/
      widgets/
    url_text/
```

## State Management
- Provider + ChangeNotifier across features: AppState, AuthState, FeedState, ProfileState, SearchState, NotificationState, BookmarkState, ChatState, ComposeTweetState.
- TweetBaseState provides shared tweet logic where needed.

## Navigation & Routing
- Centralized route table in `helper/routes.dart` with `onGenerateRoute` and fallback route handlers.
- Custom transitions via `helper/customRoute.dart`.

## Dependency Injection
- Lightweight service locator in `ui/page/common/locator.dart` (GetIt) for shared services.

## Firebase Integration
- Initialization in `main.dart` (Firebase.initializeApp())
- Auth: email/password and Google Sign-In
- Database: Firestore/Realtime DB for tweets, users, chats, notifications
- Storage: images (profile/tweet media)
- Messaging (FCM): push notifications and background handlers
- Remote Config/Dynamic Links/Analytics are wired; enable/configure as needed.

### Required Firebase files (not included)
- Android: `android/app/google-services.json`
- iOS: `ios/Runner/GoogleService-Info.plist`

## Theming & Styles
- `ui/theme/theme.dart`, `ui/theme/color/light_color.dart`, `ui/theme/text_styles.dart`, `ui/theme/app_icons.dart`
- Custom TwitterIcon font and HelveticaNeue font family
- GoogleFonts Mulish text theme is applied app-wide

## Media & Link Preview
- `widgets/url_text/*` for parsing URLs, mentions, hashtags
- `model/link_media_info.dart` and link preview widget for rich embeds
- `widgets/cache_image.dart` provides cached images with placeholders

## Notifications (FCM)
- `resource/push_notification_service.dart` handles token sync, foreground/background message handling, and deep linking to appropriate screens.

## Authentication
- Screens in `ui/page/Auth/*` for sign in, sign up, password reset, Google login, email verification, and auth method selection.
- State in `state/authState.dart` with session and user profile management.

## Feed & Tweets
- `state/feedState.dart` for timeline, likes, retweets, replies
- `ui/page/feed/*` for feed, detail, image viewer, suggested users
- `ui/page/feed/composeTweet/*` for composition flow with image attachments
- `widgets/tweet/*` for reusable tweet UI blocks (icons row, bottom sheet, retweet, translation, etc.)

## Messaging (DM)
- `state/chats/chatState.dart` for conversation logic
- `ui/page/message/*` for chat list, chat screen, new message, and conversation information

## Search
- `state/searchState.dart`, `state/suggestionUserState.dart`
- `ui/page/search/SearchPage.dart` with real-time search for users/tweets

## Bookmarks
- `state/bookmarkState.dart` for save/unsave
- `ui/page/bookmark/bookmarkPage.dart` for viewing saved tweets

## Settings
- Complete settings tree under `ui/page/settings/` covering accessibility, display, data usage, notifications, privacy & safety (incl. DM), content preferences (incl. trends), proxy settings, and common widgets.

## Getting Started (Quickstart)

1) Prerequisites
- Flutter SDK 3.9+ (check with `flutter --version`)
- Android Studio/Xcode set up
- A Firebase project created at console.firebase.google.com

2) Firebase setup
- Android: download google-services.json and place it at `android/app/google-services.json`
- iOS: download GoogleService-Info.plist and place it at `ios/Runner/GoogleService-Info.plist`
- Enable authentication providers you need (Email/Password, Google) in Firebase Console
- Create Firestore database OR Realtime Database and choose a location close to your users
- Enable Cloud Storage

3) Recommended Firebase Security Rules (examples)

Firestore rules (example):
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isSignedIn() { return request.auth != null; }

    match /users/{uid} {
      allow read: if true;  // public profiles
      allow write: if isSignedIn() && request.auth.uid == uid;
    }

    match /tweets/{tweetId} {
      allow read: if true;
      allow create: if isSignedIn();
      allow update, delete: if isSignedIn() && request.resource.data.authorId == request.auth.uid;
    }

    match /chats/{chatId} {
      allow read, write: if isSignedIn() && request.auth.uid in resource.data.participants;
    }

    match /notifications/{doc=**} {
      allow read, write: if isSignedIn();
    }
  }
}
```

Realtime Database rules (example):
```
{
  "rules": {
    ".read": false,
    ".write": false,
    "chats": {
      "$chatId": {
        ".read": "auth != null && root.child('chatParticipants').child($chatId).child(auth.uid).val() == true",
        ".write": "auth != null && root.child('chatParticipants').child($chatId).child(auth.uid).val() == true"
      }
    }
  }
}
```

Cloud Storage rules (example):
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    function isSignedIn() { return request.auth != null; }
    match /user_uploads/{allPaths=**} {
      allow read: if true;  // allow public viewing of profile and tweet images
      allow write: if isSignedIn();
    }
  }
}
```

4) Auth flows (Email/Password and Google)
- Email/Password: create a user in the app via Sign Up; a profile document is created and managed in Firestore
- Sign In: use email/password; session is persisted via Firebase Auth; `AuthState` notifies listeners
- Reset Password: trigger via Forgot Password page; user receives reset email
- Google Sign-In: enable provider in Firebase, add reversed client ID (iOS) and SHA-1/SHA-256 (Android) as needed; use Google button in the Sign In screen

5) Run the App
```
flutter pub get
flutter run
```

6) Troubleshooting
- If iOS pods fail, run `cd ios && pod repo update && pod install && cd ..`
- If Android build fails with multidex, ensure `multiDexEnabled true` and `implementation 'com.android.support:multidex:1.0.3'` if required (or AndroidX equivalent)


## Build & Run
Prerequisites:
- Flutter SDK (3.x)
- Dart SDK (bundled with Flutter)
- Configured Firebase project

Install deps:
```
flutter pub get
```

Android:
```
# Place google-services.json
flutter run -d android
```

iOS:
```
# Place GoogleService-Info.plist
cd ios && pod install && cd ..
flutter run -d ios
```

Web/Desktop (experimental):
```
flutter run -d chrome
flutter run -d macos  # or windows/linux
```

## Environment Configuration
Common places to configure:
- `helper/constant.dart` for collection names, feature flags
- `Info.plist` (iOS) for permissions strings
- Android manifests for permissions and deep links
- Firebase console (Auth providers, Cloud Messaging, Storage rules)

## iOS & Android Setup Notes
- Ensure minimum iOS version in Podfile matches Firebase SDK requirements.
- On Android, enable multidex if dependency count grows.
- Configure notification channels on Android if adding custom types.

## Testing
- Unit/widget tests under `test/`
- Suggested: add golden tests for widgets/tweet UI; integration tests for auth + feed flows.

## Screenshots
Below are some representative screens. Full gallery is available under `./screenshots/`.

### Auth
![Auth 1](screenshots/Auth/screenshot_1.jpg)
![Auth 2](screenshots/Auth/screenshot_2.jpg)
![Auth 3](screenshots/Auth/screenshot_3.jpg)
![Auth 4](screenshots/Auth/screenshot_4.jpg)

### Home / Timeline
![Home 1](screenshots/Home/screenshot_1.jpg)
![Home 2](screenshots/Home/screenshot_2.jpg)
![Home 3](screenshots/Home/screenshot_3.jpg)
![Home 4](screenshots/Home/screenshot_4.jpg)
![Home 5](screenshots/Home/screenshot_5.jpg)
![Home 6](screenshots/Home/screenshot_6.jpg)
![Home 7](screenshots/Home/screenshot_7.jpg)

### Tweet Detail
![Tweet 1](screenshots/TweetDetail/screenshot_1.jpg)
![Tweet 2](screenshots/TweetDetail/screenshot_2.jpg)
![Tweet 3](screenshots/TweetDetail/screenshot_3.jpg)
![Tweet 4](screenshots/TweetDetail/screenshot_4.jpg)
![Tweet 5](screenshots/TweetDetail/screenshot_5.jpg)
![Tweet 6](screenshots/TweetDetail/screenshot_6.jpg)
![Tweet 7](screenshots/TweetDetail/screenshot_7.jpg)

### Chat
![Chat 1](screenshots/Chat/screenshot_1.jpg)
![Chat 2](screenshots/Chat/screenshot_2.jpg)
![Chat 3](screenshots/Chat/screenshot_3.jpg)
![Chat 4](screenshots/Chat/screenshot_4.jpg)

### Notifications
![Notifications 1](screenshots/Notification/screenshot_1.jpg)
![Notifications 2](screenshots/Notification/screenshot_2.jpg)
![Notifications 3](screenshots/Notification/screenshot_3.jpg)
![Notifications 4](screenshots/Notification/screenshot_4.jpg)

### Profile
![Profile 1](screenshots/Profile/screenshot_1.jpg)
![Profile 2](screenshots/Profile/screenshot_2.jpg)
![Profile 3](screenshots/Profile/screenshot_3.jpg)
![Profile 4](screenshots/Profile/screenshot_4.jpg)
![Profile 5](screenshots/Profile/screenshot_5.jpg)
![Profile 6](screenshots/Profile/screenshot_6.jpg)
![Profile 7](screenshots/Profile/screenshot_7.jpg)

### Search
![Search 1](screenshots/Search/screenshot_1.jpg)
![Search 2](screenshots/Search/screenshot_2.jpg)

### Settings
![Settings 1](screenshots/Settings/screenshot_1.jpg)    ![Settings 2](screenshots/Settings/screenshot_2.jpg)

![Settings 3](screenshots/Settings/screenshot_3.jpg)
![Settings 4](screenshots/Settings/screenshot_4.jpg)
![Settings 5](screenshots/Settings/screenshot_5.jpg)
![Settings 6](screenshots/Settings/screenshot_6.jpg)
![Settings 7](screenshots/Settings/screenshot_7.jpg)
![Settings 8](screenshots/Settings/screenshot_8.jpg)
![Settings 9](screenshots/Settings/screenshot_9.jpg)
![Settings 10](screenshots/Settings/screenshot_10.jpg)

## Roadmap
- Migrate to Riverpod/BLoC (optional)
- Add unit tests for state classes
- Add integration tests for auth/feed flows
- Add CI (GitHub Actions) for build + test
- Add localization (intl ARB) and RTL support
- Add image/video uploads with progress

## Contributing
PRs are welcome! Please:
- Follow the established folder structure
- Write clear commit messages (conventional commits preferred)
- Add/update tests where appropriate

## License
This project is licensed under the terms of the LICENSE file included in this repository.
