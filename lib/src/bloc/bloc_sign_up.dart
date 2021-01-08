import 'dart:async';
import 'package:MobileSystemsPass/src/Mixin/Matcher.dart';
import 'package:MobileSystemsPass/src/validator/UI_validator.dart';
import 'package:rxdart/rxdart.dart';

class SignUpBloc with Matcher {
  //Variable declaration
  static bool _verify = false;
  static String _verifyText = "I am not a robot";
  static bool _success = false;
  static final PublishSubject<bool> _validPassRegistration = PublishSubject<bool>();
  static final PublishSubject<bool> _validUserName = PublishSubject<bool>();
  static final PublishSubject<bool> _validPassRepeat = PublishSubject<bool>();
  static final  BehaviorSubject<String>_validPhone =  BehaviorSubject<String>();
  static bool _phone = false;
  
  //Object constructor
  SignUpBloc() {
    userNameStream.listen((value) {
      _validUserName.sink.add(true);
    }, onError: (error) {
      _validUserName.sink.add(false);
    });

    passwordRegistrationStream.listen((value) {
      _validPassRegistration.sink.add(true);
    }, onError: (error) {
      _validPassRegistration.sink.add(false);
    });

    passwordRepeatStream.listen((value) {
      _validPassRepeat.sink.add(true);
    }, onError: (error) {
      _validPassRepeat.sink.add(false);
    });
    Validator.init();
  }

  //Verify setter
  set setVerify(bool value) => _verify = value;
  set setVerifyText(String value) => _verifyText = value;

  //Verify getter
  bool get getVerify => _verify;
  String get getVerifyText => _verifyText;

  bool get getSuccess => _success;

  set setPhoneNumber(bool phone) => _phone = phone;

  PublishSubject<bool> get validUserName => _validUserName;

  final BehaviorSubject _userNameController = BehaviorSubject<String>(); 
 
 Stream<String>   get userNameStream  => _userNameController.stream.transform(_validateUser()); 
 Function(String) get userNameOnChange => _userNameController.sink.add;
 set phoneNumberOnChange(String phone) => _validPhone.sink.add(phone);

 StreamTransformer _validateUser() { 
          return StreamTransformer<String, String>.fromHandlers( 
          handleData: (String userName, EventSink<String> sink) { 
          //Check if the email does not contain extrange characters 
          if (Matcher.userName(userName)){ 
          sink.add(userName); 
          //Check if the userName field is empty
          } else if (userName == null || userName.isEmpty){ 
          sink.addError('Empty field'); 
          } else { 
          sink.addError('Enter a valid username'); 
          
          } 
          } 
          ); 
 } 

  final BehaviorSubject _passwordRegistrationController =
      BehaviorSubject<String>();

  //Stream that validates the password during registration
  Stream<String> get passwordRegistrationStream =>
      _passwordRegistrationController.stream
          .transform(_validateRegistrationPassword());
  Function(String) get passwordRegistrationOnChange =>
      _passwordRegistrationController.sink.add;

  //Repeat password field

  final BehaviorSubject _passwordRepeatController = BehaviorSubject<String>();

  //Stream that validates the password during registration
  Stream<String> get passwordRepeatStream =>
      _passwordRepeatController.stream.transform(_validateRepeatPassword());
  Function(String) get passwordRepeatOnChange =>
      _passwordRepeatController.sink.add;

  StreamTransformer _validateRegistrationPassword() {
    return StreamTransformer<String, String>.fromHandlers(
        handleData: (String password, EventSink<String> sink) {
      //Check if the password does not contain special characters
      if (Matcher.pass(password)) {
        if (password.length > 20)
          sink.add(password);
        else
          sink.addError("The password should be at least 20 characters long");
      } else if (password.isEmpty || password == null) {
        //If the password field is empty
        sink.addError('The password is empty');
      } else {
        //If the contains extrange characters
        sink.addError('Special characters allowed !@#%\$&*~=()');
      }
    });
  }

  StreamTransformer _validateRepeatPassword() {
    return StreamTransformer<String, String>.fromHandlers(
        handleData: (String password, EventSink<String> sink) {
      //Check if the password does not contain special characters
      if (_passwordRegistrationController.value == password) {
        sink.add(password);
      } else if (password.isEmpty || password == null) {
        //If the password field is empty
        sink.addError('The password is empty');
      } else {
        //If the password is not long enough
        sink.addError('The passwords should match');
      }
    });
  }


  Stream<bool> get registerValid => Rx.combineLatest3(_validUserName.stream, _validPassRegistration.stream, _validPassRepeat.stream, (isValidUser, isPasswordValid, isRepeatValid) { 
        if( isValidUser is bool && isPasswordValid is bool && isRepeatValid) { 
            return isPasswordValid && isValidUser && isRepeatValid && _phone; 
        } 
        return false; 
 });
  
  void register() => Validator.registerUserName(_userNameController.value,_passwordRegistrationController.value, _validPhone.value);

  Future<bool> isRegistered() async {
    return await Validator.isRegistered();
  }

  @override
  void dispose() {
     _validPassRegistration.close();
    _passwordRegistrationController.close();
    _passwordRepeatController.close();
    _validPassRepeat.close();
    _validUserName.close();
    _userNameController.close();
    _validPhone.close();
  }
}
