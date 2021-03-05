# MobileSystemsPass

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

A secure notebook that uses OTP mobile phone login and it uses scrypt keyderivator function to store the passwords securely. The storage of the notes is handled by
the Hive library (find out more here: https://pub.dev/packages/hive/) which uses AES-256 CBC to encrypt the database.

The OTP is managed using Firebase Authentication, which provides free OTP verification for a decent amount of users. Recaptcha_v2 is used in the registration period to prevent non-human users to register in the notebook and it is also checked if the users has a rooted phone, unlocked bootloader or non trusted phone using the Google SafeNet. 
The project is fully written on flutter and mainly uses the following dependencies:
 - pointycastle
 - shared_preferences
 - flutter_secure_storage
 - rxdart
 - hive
 - flutter_recaptcha_v2
 - firebase_auth
