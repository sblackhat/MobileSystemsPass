import 'dart:async';
import 'package:MobileSystemsPass/src/Mixin/Matcher.dart';
import 'package:rxdart/rxdart.dart';

abstract class Bloc{
  //Variable declaration
  static bool _verify = false;
  static String _verifyText = "I am not a robot";
  static final PublishSubject<bool> _validemail = PublishSubject<bool>();

  //Verify setter
  set setVerify(bool value) => _verify = value;
  set setVerifyText(String value) => _verifyText = value;

  //Verify getter
  bool get getVerify => _verify;
  String get getVerifyText => _verifyText;

  PublishSubject<bool> get validemail => _validemail;

  final BehaviorSubject _emailController = BehaviorSubject<String>(); 
 
 Stream<String>   get emailStream  => _emailController.stream.transform(_validateEmail()); 
 Function(String) get emailOnChange => _emailController.sink.add;
 String get emailValue => _emailController.value;

 StreamTransformer _validateEmail() { 
          return StreamTransformer<String, String>.fromHandlers( 
          handleData: (String email, EventSink<String> sink) { 
          //Check if the email does not contain extrange characters 
          if (Matcher.email(email)){ 
          sink.add(email); 
          //Check if the email field is empty
          } else if (email.isEmpty || email == null){ 
          sink.addError('The email is empty'); 
          } else { 
          sink.addError('Enter a valid email'); 
          
          } 
          } 
          ); 
 } 
 void dispose(){
   _validemail.close();
   _emailController.close();
 }
}