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
```
flutter pub get
dart pub global activate flutterfire_cli
flutterfire configure
```
Follow prompts and include the platforms you need. This generates `lib/firebase_options.dart`. Replace the placeholder file included here.

## Run
1. `flutter pub get`
2. Start two emulators.
3. Run app on Emulator A:
   - Tap **Seed dummy users** (only once)
   - Choose **Alice**
4. Run app on Emulator B:
   - Choose **Bob**
5. On either emulator open the other user's chat and send messages.
   - When you send, message doc is created with `status: "sent"` → UI shows ✅
   - When the recipient's client sees the doc (Stream), it updates `status: "delivered"` → UI shows ✅✅

## Firestore Structure
- `users/{uid}`: { uid, name, isOnline, lastSeen }
- `chats/{chatId}/messages/{msg}`: { senderId, receiverId, text, timestamp, status }

## RTDB Structure
- `status/{uid}`: { state: "online"|"offline", lastSeen: SERVER_TIMESTAMP }

## Notes
- Replace firebase_options.dart with generated file from flutterfire configure.
- For production, secure Firestore and RTDB rules appropriately.