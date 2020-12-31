import 'dart:async';
import 'package:MobileSystemsPass/src/Mixin/Matcher.dart';
import 'package:MobileSystemsPass/src/bloc/bloc.dart';
import 'package:MobileSystemsPass/src/validator/UI_validator.dart';
import 'package:rxdart/rxdart.dart';

class LoginBloc extends Bloc with Matcher {
  //Variables declaration in the BLOC
  static int _counter = 0;
  
  static final PublishSubject<bool> _validPass = PublishSubject<bool>();
 
  static final Validator _validator = Validator();
 

  //Object constructor
  LoginBloc(){

       userNameStream.listen((value){ 
        super.validUserName.sink.add(true); 
        }, onError:(error) { 
      super.validUserName.sink.add(false); 
      });

      passwordStream.listen((value){ 
          _validPass.sink.add(true); 
          }, onError:(error) { 
        _validPass.sink.add(false); 
    }); 

    Validator.init();
  }

  //Counter getter
  int get getCounter => _counter;

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

  Stream<bool> get submitValid => Rx.combineLatest2(super.validUserName.stream, _validPass.stream, (isValidUser, isPasswordValid) { 
        if( isValidUser is bool && isPasswordValid is bool) { 
            return isPasswordValid && isValidUser; 
        } 
        return false; 
 });


  Future<bool> submitLogin() async {

      String result = await Validator.validatePassword(_passwordController.value, super.userNameValue);

      if(result == null){
        _counter = 0;
        return true;
      }else if(super.getVerify){
         _counter++;
         return false;
      }
    return false;
    }

    void dispose(){  
      super.dispose();
      _passwordController.close();  
      _validPass.close(); 
    } 
    
 }

