import 'package:MobileSystemsPass/src/bloc/bloc_sign_up.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:MobileSystemsPass/src/captcha/captcha.dart';
import 'package:MobileSystemsPass/src/screens/notebook_screen.dart';

class SignUp extends StatefulWidget{
  @override 
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp>{
  SignUpBloc _bloc = SignUpBloc();
  TextEditingController _passController = TextEditingController();
  TextEditingController _passRepeatController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text('Register in the notebook')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
          //email field
          StreamBuilder<String>( 
            stream: _bloc.emailStream, 
            builder: (context, snapshot) { 
              return emailField(context, snapshot);
            }),


            //Password Field
            StreamBuilder<String>( 
              stream: _bloc.passwordRegistrationStream, 
              builder: (context, snapshot){
                return passwordField(context, snapshot);
              },
            ),

           //Repeat Password Field
            StreamBuilder<String>( 
              stream: _bloc.passwordRepeatStream, 
              builder: (context, snapshot){
                return repeatPasswordField(context, snapshot);
              },
            ),

          //SUBMIT BUTTON
          StreamBuilder<bool>( 
          stream: _bloc.registerValid, 
          builder: (context, snapshot) { 
            return _registerButton(context,snapshot);
          }),

          //Add some padding
          Padding(padding: EdgeInsets.only(top:25.0, bottom: 25.0)),

          //CAPTCHA
         // recaptchaButton(),

          ],),
          ),
      );
      
  }

  Widget emailField(BuildContext context, dynamic snapshot){
    return TextField( 
            controller: _emailController,
            decoration: InputDecoration( 
            labelText: 'Email', 
            errorText: snapshot.error, 
            ), 
            onChanged: (String value) { 
            _bloc.emailOnChange(value); 
            }, 
            ); 
  }

  Widget passwordField(BuildContext context, dynamic snapshot){
    return TextField( 
        enableSuggestions: false,
        autocorrect: false,
        obscureText: true,
        controller: _passController,
        decoration: InputDecoration( 
          labelText: 'Password', 
          errorText: snapshot.error, 
        ), 
        onChanged: (String value) { 
              _bloc.passwordRegistrationOnChange(value);
            }, 
      ); 
    }
  Widget repeatPasswordField(BuildContext context, dynamic snapshot){
    return TextField( 
        enableSuggestions: false,
        autocorrect: false,
        obscureText: true,
        controller: _passRepeatController,
        decoration: InputDecoration( 
          labelText: 'Repeat Password', 
          errorText: snapshot.error, 
        ), 
        onChanged: (String value) { 
              _bloc.passwordRepeatOnChange(value);
            }, 
      ); 
    }

  Widget _registerButton(context, snapshot){
     
      return RaisedButton( 
        
        color: Colors.lightGreen, 
        disabledColor: Colors.grey, 
            child: Text('Register', style: TextStyle(color: Colors.white),), 
         onPressed: (){
           _onPressRegister(snapshot,context);
         }
      );
  }
    Future<void> _onPressSubmit(snapshot,context) async {
      if(snapshot.hasData && snapshot.data){
        //Check if the user has verified the CAPTCHA
        if(_bloc.getVerify){
          //On true check the password
          var result = await _bloc.submitLogin();

          if(result){
            _goToNoteScreen(context); //Go to Notebook on true
            _bloc.setVerify = false; //The captcha is no longer verified
          }else{
            //Show the wrongPassword dialog
            _showWrongPass();
          _bloc.setVerify = false; //Make the user verify himself again in order to prevent bruteforce
          }
        //Show the not verified alertDialog
        }else 
        _showNotVerified();
        }
      }

    _goToCaptchaScreen(context){
     var captcha = CaptchaPage();
     captcha.setBloc(_bloc);
     Navigator.push(context, MaterialPageRoute(builder: (context) => captcha));
   }
      

    Widget recaptchaButton(){
     return Stack(
        children: <Widget>[
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Show that you are not a bot"),
                RaisedButton(
                  child: Text(_bloc.getVerifyText),
                  color: Colors.black38,
                  textColor: Colors.white,
                  disabledColor: Colors.lightGreenAccent,
                  disabledTextColor: Colors.white,
                  onPressed: (){
                    if(!_bloc.getVerify) return _goToCaptchaScreen(context); else return null;
                  } ,
                ),
              ],
            ),
          )
        ]
     );
    }

Future<void> _showNotVerified() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Click the CAPTCHA button'),
          content: SingleChildScrollView(
            child: Text('You have not verified the captcha'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}