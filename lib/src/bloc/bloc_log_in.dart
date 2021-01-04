import 'dart:async';
import 'package:MobileSystemsPass/src/Mixin/Matcher.dart';
import 'package:MobileSystemsPass/src/bloc/bloc.dart';
import 'package:MobileSystemsPass/src/validator/UI_validator.dart';
import 'package:rxdart/rxdart.dart';

class LoginBloc extends Bloc with Matcher {
  //Variables declaration in the BLOC
  
  static final PublishSubject<bool> _validPass = PublishSubject<bool>();

  static final PublishSubject<bool> _validUserName = PublishSubject<bool>();

  static final Validator _validator = Validator();
 

  //Object constructor
  LoginBloc(){

       userNameStream.listen((value){ 
        _validUserName.sink.add(true); 
        }, onError:(error) { 
      _validUserName.sink.add(false); 
      });

      passwordStream.listen((value){ 
          _validPass.sink.add(true); 
          }, onError:(error) { 
        _validPass.sink.add(false); 
    }); 

    Validator.init();
  }


  PublishSubject<bool> get validUserName => _validUserName;

  final BehaviorSubject _userNameController = BehaviorSubject<String>(); 
 
 Stream<String>   get userNameStream  => _userNameController.stream.transform(_validateUser()); 
 Function(String) get userNameOnChange => _userNameController.sink.add;

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


  //Password controller
  final BehaviorSubject _passwordController = BehaviorSubject<String>(); 

  //Stream that validates that the password is not empty and that is long enough
  Stream<String> get passwordStream => _passwordController.stream.transform(_validatePassword()); 
  Function(String) get passwordOnChange => _passwordController.sink.add;  

    StreamTransformer _validatePassword() { 
    return StreamTransformer<String, String>.fromHandlers( 
    handleData: (String password, EventSink<String> sink) { 
      //Check if the password is at leat 20 characters long
    if (password.length > 20){ 
        sink.add(password); 
    } else if (password.isEmpty || password == null){
      //If the password field is empty 
      sink.addError('The password is empty'); 
    } else {
        //If the password is not long enough 
        sink.addError('Password is too short'); 
      }
    } 
    ); 
 } 

  Stream<bool> get submitValid => Rx.combineLatest2(_validUserName.stream, _validPass.stream, (isValidUser, isPasswordValid) { 
        if( isValidUser is bool && isPasswordValid is bool) { 
            return isPasswordValid && isValidUser; 
        } 
        return false; 
 });

  
  Future<bool> submitLogin() async {

      bool result = await Validator.validatePassword(_passwordController.value, _userNameController.value);

      return result;
    }

    void dispose(){  
      _passwordController.close();  
      _validPass.close(); 
      _userNameController.close();
      _validUserName.close();
    } 
    
 }

