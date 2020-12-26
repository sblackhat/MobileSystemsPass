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

Write a program - a secured notebook - access to which will be protected with a password. After entering the password, the user should be able to view the saved message, change it, change the password. Entering a wrong password should of course result in the lack of access to the message and the possibility of changing the password. In the source code, avoid any comments that may identify you (the code may be published, and the lecturer prefers to provide personal information only with the explicit consent. The user has to login in using an username and a password. It uses a recaptchav2 in order to protect against bruteforce and a salted-HMAC-SHA256 has to store the passwords. The messages are stored encryted using the Hive library in flutter.
