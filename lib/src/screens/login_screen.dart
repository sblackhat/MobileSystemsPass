import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:MobileSystemsPass/src/bloc/login_bloc.dart';
import 'package:MobileSystemsPass/src/captcha/captcha.dart';
import 'package:MobileSystemsPass/src/screens/notebook_screen.dart';



class LoginScreen extends StatefulWidget{
  @override 
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>{
  LoginBloc _bloc = LoginBloc();
  TextEditingController _passController = TextEditingController();
  TextEditingController _userController = TextEditingController();

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text('BlackNotebook Log in')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
          //Username field
          StreamBuilder<String>( 
            stream: _bloc.userNameStream, 
            builder: (context, snapshot) { 
              return userNameField(context, snapshot);
            }),


            //Password Field
            StreamBuilder<String>( 
              stream: _bloc.passwordStream, 
              builder: (context, snapshot){
                return passwordField(context, snapshot);
              },
            ),

          //FORGET PASSWORD FIELD
          

          //SUBMIT BUTTON
          StreamBuilder<bool>( 
          stream: _bloc.submitValid, 
          builder: (context, snapshot) { 
            return _submitButton(context,snapshot);
          }),

          //Add some padding
          Padding(padding: EdgeInsets.only(top:25.0, bottom: 25.0)),

          //CAPTCHA
          recaptchaButton(),
          ],),
          ),
      );
      
  }

  Widget userNameField(BuildContext context, dynamic snapshot){
    return TextField( 
            controller: _userController,
            decoration: InputDecoration( 
            labelText: 'Username', 
            errorText: snapshot.error, 
            ), 
            onChanged: (String value) { 
            _bloc.userOnChange(value); 
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
              _bloc.passwordOnChange(value);
            }, 
      ); 
    }

  Widget _forgetPass(){
    TextStyle defaultStyle = TextStyle(color: Colors.grey, fontSize: 20.0);
    TextStyle linkStyle = TextStyle(color: Colors.blue);
    return RichText(
      text: TextSpan(
        style: defaultStyle,
        children: <TextSpan>[
          TextSpan(text: 'By clicking Sign Up, you agree to our '),
          TextSpan(
              text: 'Terms of Service',
              style: linkStyle,
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  print('Terms of Service"');
                }),
          TextSpan(text: ' and that you have read our '),
          TextSpan(
              text: 'Privacy Policy',
              style: linkStyle,
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  print('Privacy Policy"');
                }),
        ],
      ),
    );
  }

  }

  Widget _submitButton(context, snapshot){
     
      return RaisedButton( 
        
        color: Colors.blue, 
        disabledColor: Colors.grey, 
            child: Text('Submit', style: TextStyle(color: Colors.white),), 
         onPressed: (){
           _onPressSubmit(snapshot,context);
         }
      );
  }
  Future<void> _showWrongPass() async {
    final int counter  = _bloc.getCounter;
    return showDialog<void>(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Wrong Password/Username'),
          content: SingleChildScrollView(
            child: Text('You have introduced the wrong password/username $counter times!'),
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

  Future<void> _onPressSubmit(snapshot,context) async {
      if(snapshot.hasData && snapshot.data){
        //Check if the user has verified the CAPTCHA
        if(_bloc.verify){
          //On true check the password
          var result = await _bloc.submitLogin();

          if(result){
            _goToNoteScreen(context); //Go to Notebook on true
            _bloc.verify = false; //The captcha is no longer verified
          }else{
            //Show the wrongPassword dialog
            _showWrongPass();
          _bloc.verify = false; //Make the user verify himself again in order to prevent bruteforce
          }
        //Show the not verified alertDialog
        }else 
        _showNotVerified();
        }
      }
      

    Widget recaptchaButton(){
     return Stack(
        children: <Widget>[
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  child: Text("SHOW ReCAPTCHA"),
                  onPressed: () {
                    _goToCaptchaScreen(context);
                  },
                ),
                Text("Click on the CAPTCHA to verify"),
              ],
            ),
          )
        ]
     );
    }

   _goToNoteScreen(context){
     _clearLoginScreen();
     Navigator.push(context, MaterialPageRoute(builder: (context) => NoteBookScreen()));
   }

   _goToCaptchaScreen(context){
     var captcha = CaptchaPage();
     captcha.loginBloc(_bloc);
     Navigator.push(context, MaterialPageRoute(builder: (context) => captcha));
   }


  _clearLoginScreen(){
    //_bloc.clearStream();
     _userController.clear();
     _passController.clear();
  }
  
}
 
