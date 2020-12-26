import 'dart:async';
import 'package:mobileSystems/src/Mixin/Matcher.dart';
import 'package:mobileSystems/src/validator/password_validator.dart';
import 'package:rxdart/rxdart.dart';

class LoginBloc with Matcher{
  //Variables declaration in the BLOC
  int _counter = 0;
  
  bool verify = false;

  final PublishSubject<bool> _validPass = PublishSubject<bool>();

  final PublishSubject<bool> _validUserName = PublishSubject<bool>();
 
  final Validator _validator = Validator();
 

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
  }

  //Counter getter
  int get getCounter => _counter;

  //Username controller
  final BehaviorSubject _userNameController = BehaviorSubject<String>(); 
 
 Stream<String> get userNameStream => _userNameController.stream.transform(validateUser()); 
 Function(String) get userOnChange => _userNameController.sink.add; 
 

  final BehaviorSubject _passwordController = BehaviorSubject<String>(); 

  //Stream that validates that the password is not empty and that is long enough
  Stream<String> get passwordStream => _passwordController.stream.transform(validatePassword()); 
  Function(String) get passwordOnChange => _passwordController.sink.add; 


    StreamTransformer validatePassword() { 
    return StreamTransformer<String, String>.fromHandlers( 
    handleData: (String password, EventSink<String> sink) { 
      //Characters allowed !@#%\$&*~= and space
    if (Matcher.simpleMatcher(password) ){ 
        sink.add(password); 
    } else if (password.isEmpty || password == null){
      //If the password is empty 
      sink.addError('The username is empty'); 
    } else {
        //If the password is not long enough 
        sink.addError('Password is too short'); 
      }
    } 
    ); 
 } 

  StreamTransformer validateUser() { 
          return StreamTransformer<String, String>.fromHandlers( 
          handleData: (String username, EventSink<String> sink) { 
          if (Matcher.userName(username)){ 
          sink.add(username); 
          
          } else if (username.isEmpty || username == null){ 
          sink.addError('The password is empty'); 
          
          } else { 
          sink.addError('Enter a valid username'); 
          
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

      String result = await _validator.validatePassword(_passwordController.value, _userNameController.value);

      if(result == null){
        _counter = 0;
        return true;
      }else{
         _counter++;
         return false;
      }
    }

    void dispose(){  
      _passwordController.close();  
      _validPass.close(); 
      _validUserName.close();
      _userNameController.close();
    } 

    
 }

