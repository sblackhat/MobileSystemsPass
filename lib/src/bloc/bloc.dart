abstract class Bloc{
  //Variable declaration
  static bool _verify = true;
  static String _verifyText = "I am not a robot";

  //Verify setter
  set setVerify(bool value) => _verify = value;
  set setVerifyText(String value) => _verifyText = value;

  //Verify getter
  bool get getVerify => _verify;
  String get getVerifyText => _verifyText;

}