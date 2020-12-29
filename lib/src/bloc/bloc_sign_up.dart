import 'dart:async';
import 'package:MobileSystemsPass/src/Mixin/Matcher.dart';
import 'package:MobileSystemsPass/src/bloc/bloc.dart';
import 'package:MobileSystemsPass/src/validator/UI_validator.dart';
import 'package:rxdart/rxdart.dart';

class SignUpBloc extends Bloc with Matcher {
  //Variable declaration
  static bool _verify = false;
  static String _verifyText = "I am not a robot";
  static final PublishSubject<bool> _validPassRegistration =
      PublishSubject<bool>();
  static final PublishSubject<bool> _validPassRepeat = PublishSubject<bool>();
  static final Validator _validator = Validator();

  //Object constructor
  SignUpBloc() {
    emailStream.listen((value){ 
        super.validemail.sink.add(true); 
        }, onError:(error) { 
      super.validemail.sink.add(false); 
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

    _validator.init();
  }

  //Verify setter
  set setVerify(bool value) => _verify = value;
  set setVerifyText(String value) => _verifyText = value;

  //Verify getter
  bool get getVerify => _verify;
  String get getVerifyText => _verifyText;

  final BehaviorSubject _passwordRegistrationController = BehaviorSubject<String>(); 

  //Stream that validates the password during registration
  Stream<String> get passwordRegistrationStream => _passwordRegistrationController.stream.transform(_validateRegistrationPassword()); 
  Function(String) get passwordRegistrationOnChange => _passwordRegistrationController.sink.add; 

  //Repeat password field

  final BehaviorSubject _passwordRepeatController = BehaviorSubject<String>(); 

  //Stream that validates the password during registration
  Stream<String> get passwordRepeatStream => _passwordRepeatController.stream.transform(_validateRepeatPassword()); 
  Function(String) get passwordRepeatOnChange => _passwordRepeatController.sink.add;

  
  StreamTransformer _validateRegistrationPassword() { 
    return StreamTransformer<String, String>.fromHandlers( 
    handleData: (String password, EventSink<String> sink) { 
      //Check if the password does not contain special characters
    if (Matcher.pass(password)){ 
      if(password.length > 20)
        sink.add(password); 
      else
        sink.addError("The password should be at least 20 characters long");
    } else if (password.isEmpty || password == null){
      //If the password field is empty 
      sink.addError('The password is empty'); 
    } else {
        //If the contains extrange characters
        sink.addError('Special characters allowed !@#%\$&*~=()'); 
      }
    } 
    ); 
 } 

  StreamTransformer _validateRepeatPassword() { 
    return StreamTransformer<String, String>.fromHandlers( 
    handleData: (String password, EventSink<String> sink) { 
      //Check if the password does not contain special characters
    if (_passwordRegistrationController.value == password){ 
        sink.add(password); 
    } else if (password.isEmpty || password == null){
      //If the password field is empty 
      sink.addError('The password is empty'); 
    } else {
        //If the password is not long enough 
        sink.addError('The passwords should match'); 
      }
    } 
    ); 
 }


  Stream<bool> get registerValid => Rx.combineLatest2(_registerValid1, _registerValid2, (isValid1, isValid2) { 
        if( isValid1 is bool && isValid2 is bool) { 
            return isValid2 && isValid1; 
        } 
        return false; 
  });


 Stream<bool> get _registerValid1 => Rx.combineLatest2(super.validemail.stream, _validPassRegistration.stream, (isValidEmail, isPassValid) { 
        if( isValidEmail is bool && isPassValid is bool) { 
            return isPassValid && isValidEmail; 
        } 
        return false; 
 });
 Stream<bool> get _registerValid2 => Rx.combineLatest2(_validPassRegistration.stream, _validPassRepeat.stream, (isPassValid, isRepeatValid) { 
        if( isPassValid is bool && isRepeatValid is bool) { 
            return isPassValid && isRepeatValid; 
        } 
        return false; 
 });

  void disposeReg(){
      super.dispose();
      _validPassRegistration.close();
      _passwordRegistrationController.close();
      _passwordRepeatController.close();
      _validPassRepeat.close();
    }

}
