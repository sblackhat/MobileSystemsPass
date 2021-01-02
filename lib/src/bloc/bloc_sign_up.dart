import 'dart:async';
import 'package:MobileSystemsPass/src/Mixin/Matcher.dart';
import 'package:MobileSystemsPass/src/bloc/bloc.dart';
import 'package:MobileSystemsPass/src/validator/UI_validator.dart';
import 'package:rxdart/rxdart.dart';

class SignUpBloc extends Bloc with Matcher {
  //Variable declaration
  static bool _verify = false;
  static bool _success = false;
  static String _verifyText = "I am not a robot";
  static final PublishSubject<bool> _validPhoneNumber = PublishSubject<bool>();
  static final PublishSubject<bool> _validPassRegistration =
      PublishSubject<bool>();
  static final PublishSubject<bool> _validPassRepeat = PublishSubject<bool>();
  //Object constructor
  SignUpBloc() {
    userNameStream.listen((value) {
      super.validUserName.sink.add(true);
    }, onError: (error) {
      super.validUserName.sink.add(false);
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
  set setSuccess(bool value) => _success = value;

  //Verify getter
  bool get getVerify => _verify;
  String get getVerifyText => _verifyText;
  bool get getSuccess => _success;

  //Set valid phone number
  set validPhoneNumber(bool value) => _validPhoneNumber.sink.add(value);

  final BehaviorSubject _phoneNumberController = BehaviorSubject<String>();

  //Stream that validates the password during registration
  Stream<String> get phoneNumberStream =>
      _phoneNumberController.stream.transform(_validatePhoneNumber());
  Function(String) get phoneNumberOnChange => _phoneNumberController.sink.add;
  String get phoneValue => _phoneNumberController.value;

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

  StreamTransformer _validatePhoneNumber() {
    return StreamTransformer<String, String>.fromHandlers(
        handleData: (String phoneNumber, EventSink<String> sink) {
      //Check the phone number
    });
  }

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

  Stream<bool> get registerValid => Rx.combineLatest4(
          super.validUserName.stream,
          _validPassRegistration.stream,
          _validPassRepeat.stream,
          _validPhoneNumber, (a, b, c, d) {
        if (a is bool && b is bool && c is bool && d is bool) {
          return a && b && c && d;
        }
        return false;
      });

  void register() => Validator.registerUserName(super.userNameValue,_passwordRegistrationController.value, _phoneNumberController.value);

  bool isRegistered() {
     Validator.isRegistered(super.userNameValue).then((value) {
    return value;
  }, onError: (error) {
    print(error);
  });
  return false;
  }

  @override
  void dispose() {
    super.dispose();
    _validPhoneNumber.close();
    _phoneNumberController.close();
    _validPassRegistration.close();
    _passwordRegistrationController.close();
    _passwordRepeatController.close();
    _validPassRepeat.close();
  }
}
