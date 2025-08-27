# Chat Firebase Provider Demo

## Summary
A small 1-to-1 chat demo built with Flutter + Firebase using Provider state management.
Features:
- Anonymous demo authentication
- Dummy users stored in Firestore
- 1-to-1 real-time chat (Firestore)
- Presence (online/offline) using Realtime Database and mirrored to Firestore
- Message ticks: "sent" (single ✅) -> "delivered" (double ✅✅) when recipient device receives message

## Prerequisites
- Flutter (you said you're using 3.32.6) installed
- Firebase account & project
- dart & flutterfire CLI:
  ```
  dart pub global activate flutterfire_cli
  ```

## Setup Firebase (quick)
1. Create a Firebase project at console.firebase.google.com.
2. Enable **Anonymous Authentication** (Authentication → Sign-in method → Anonymous).
3. Create **Cloud Firestore** (start in test mode for demo).
4. Create **Realtime Database** (default location). Set rules to allow authenticated read/write for demo.
5. (Optional) Set security rules as shown in repository README for a demo.

## Configure Flutter project with Firebase
From your project root:

flutter pub get
dart pub global activate flutterfire_cli
flutterfire configure
## Tech Stack

Flutter: Frontend framework

Dart: Programming language

Firebase Authentication: User login

Cloud Firestore: Real-time message storage

Firebase Realtime Database: Presence tracking

Firebase Cloud Messaging (FCM): Message delivery

Provider : State management

##Project Structure

lib/
 ├─ main.dart
 ├─ firebase_options.dart           
 ├─ providers.dart
 ├─ utils/
 │   ├─ chat_id.dart
 │   └─ time_ago.dart
 ├─ models/
 │   ├─ app_user.dart
 │   └─ message.dart
 ├─ services/
 │   ├─ user_repository.dart
 │   ├─ chat_repository.dart
 │   └─ presence_service.dart
 ├─ screens/
 │   ├─ select_user_screen.dart
 │   ├─ users_list_screen.dart
 │   └─ chat_screen.dart
 └─ widgets/
     └─ message_bubble.dart

