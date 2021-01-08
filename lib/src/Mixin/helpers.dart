class Helper {
  static String solveMessage(e) {
    String message;
    switch (e.message) {
      case 'The SMS code has expired. Please re-send the verification code to try again':
        message = 'The SMS is no longer valid';
        break;
      case 'The sms verification code used to create the phone auth credential is invalid. Please resend the verification code sms and be sure use the verification code provided by the user.':
        message = "Wrong OTP code";
        break;
      case 'A network error (such as timeout, interrupted connection or unreachable host) has occurred.':
        message = "Cannot stablish connection with the server";
        break;
      default:
        message = e.message;
    }
    return message;
  }
}
