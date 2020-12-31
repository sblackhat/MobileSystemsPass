import 'dart:async';
import 'package:MobileSystemsPass/src/Mixin/Matcher.dart';
import 'package:rxdart/rxdart.dart';

abstract class Bloc{
  //Variable declaration
  static bool _verify = false;
  static String _verifyText = "I am not a robot";
  static final PublishSubject<bool> _validUserName = PublishSubject<bool>();

  //Verify setter
  set setVerify(bool value) => _verify = value;
  set setVerifyText(String value) => _verifyText = value;

  //Verify getter
  bool get getVerify => _verify;
  String get getVerifyText => _verifyText;

  PublishSubject<bool> get validUserName => _validUserName;

  final BehaviorSubject _userNameController = BehaviorSubject<String>(); 
 
 Stream<String>   get userNameStream  => _userNameController.stream.transform(_validateUser()); 
 Function(String) get userNameOnChange => _userNameController.sink.add;
 String get userNameValue => _userNameController.value;

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
 void dispose(){
   _validUserName.close();
   _userNameController.close();
 }
}