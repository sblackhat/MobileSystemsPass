import 'dart:async';

import 'package:MobileSystemsPass/src/Mixin/helpers.dart';
import 'package:MobileSystemsPass/src/functions/note_handler.dart';
import 'package:MobileSystemsPass/src/screens/sign_up.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:MobileSystemsPass/src/bloc/bloc_log_in.dart';
import 'package:MobileSystemsPass/src/captcha/captcha.dart';
import 'package:MobileSystemsPass/src/screens/notebook_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  LoginBloc _bloc = LoginBloc();
  TextEditingController _passController = TextEditingController();
  TextEditingController _userController = TextEditingController();
  //Manage the OTP button
  static const _timerDuration = 30;
  StreamController _timerStream = new StreamController<int>();
  int timerCounter;
  Timer _resendCodeTimer;

  bool _init = true;

  @override
  void initState() {
    _activeCounter();
    super.initState();
  }

  _activeCounter() {
    _resendCodeTimer = new Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (_timerDuration - timer.tick > 0 && !_init)
        _timerStream.sink.add(_timerDuration - timer.tick);
      else {
        _timerStream.sink.add(0);
        _resendCodeTimer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Secure Black Notebook')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            //email field
            StreamBuilder<String>(
                stream: _bloc.userNameStream,
                builder: (context, snapshot) {
                  return userNameField(context, snapshot);
                }),

            //Password Field
            StreamBuilder<String>(
              stream: _bloc.passwordStream,
              builder: (context, snapshot) {
                return passwordField(context, snapshot);
              },
            ),

            //FORGET PASSWORD FIELD

            //SUBMIT BUTTON
            StreamBuilder<bool>(
                stream: _bloc.submitValid,
                builder: (context, snapshot) {
                  return _submitButton(context, snapshot);
                }),

            //Add some padding
            Padding(padding: EdgeInsets.only(top: 30.0)),

            //SIGN UP
            _registerButton(),
          ],
        ),
      ),
    );
  }

  Widget userNameField(BuildContext context, dynamic snapshot) {
    return TextField(
      controller: _userController,
      decoration: InputDecoration(
        labelText: 'User',
        errorText: snapshot.error,
      ),
      onChanged: (String value) {
        _bloc.userNameOnChange(value);
      },
    );
  }

  Widget passwordField(BuildContext context, dynamic snapshot) {
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

  Widget _submitButton(ctx, snap) {
    return StreamBuilder(
      stream: _timerStream.stream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return SizedBox(
            width: 300,
            height: 30,
            child: RaisedButton(
              textColor: Theme.of(context).accentColor,
              child: Center(
                  child: snapshot.data == 0
                      ? Text('Register')
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                                ' Resend OTP in ${snapshot.hasData ? snapshot.data.toString() : 30} seconds '),
                          ],
                        )),
              onPressed: (snapshot.data == 0 && (snap.hasData && snap.data))
                  ? () {
                      _init = false;
                      _onPressSubmit(context);
                    }
                  : null,
            ));
      },
    );
  }

  Future<void> _showWrongPass() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Wrong username/password'),
          content: SingleChildScrollView(
            child: Text('You have introduced the wrong password/username.'),
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

  Future<void> _onPressSubmit(context) async {
    bool _registered = await _bloc.isRegistered();
    if (_registered) {
        _logInUser(context); 
    } else
      _showNotRegistered("Not registered yet? Sign up");
  }

  _goToNoteScreen(context) {
    _clearLoginScreen();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => NoteBookScreen()));
  }
  _goToSignUpScreen(context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => SignUp()));
  }

  _clearLoginScreen() {
    _userController.clear();
    _passController.clear();
  }

  Widget _registerButton() {
    return Stack(children: <Widget>[
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Not registered yet? Sign up"),
            RaisedButton(
              child: Text("SIGN UP"),
              onPressed: () {
                _goToSignUpScreen(context);
              },
            ),
          ],
        ),
      )
    ]);
  }

  _codeSent(String verificationId, [int forceResendingToken]) {
    //show dialog to take input from the user
    final TextEditingController _codeController = new TextEditingController();
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => AlertDialog(
              title: Text("Enter SMS Code"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: _codeController,
                  ),
                ],
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text("Done"),
                  textColor: Colors.white,
                  color: Colors.redAccent,
                  onPressed: () async {
                    FirebaseAuth auth = FirebaseAuth.instance;
                    String smsCode =
                        _codeController.text.trim(); // Update the UI
                    PhoneAuthCredential
                        phoneAuthCredential = // Create a PhoneAuthCredential with the code
                        PhoneAuthProvider.credential(
                            verificationId: verificationId, smsCode: smsCode);
                    try {
                      await auth.signInWithCredential(phoneAuthCredential);
                      if (auth.currentUser != null) {
                        // Sign the user in with the credential
                        var result = await _bloc.submitLogin();

                        if (result) {
                
                          Navigator.of(context).pop();
                          _goToNoteScreen(context);
                        } else {
                          //Show the wrongPassword dialog
                          Navigator.of(context).pop();
                          _showWrongPass();
                          _timerStream.sink.add(30);
                          _activeCounter();
                        }
                      }
                    } on FirebaseAuthException catch (e) {
                      String message = Helper.solveMessage(e);
                      Navigator.of(context).pop();
                      _timerStream.sink.add(30);
                      _activeCounter();
                      _showNotRegistered(message);
                    }
                  },
                )
              ],
            ));
  }

  Future _logInUser(BuildContext context) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    final phone = await _bloc.getPhone();
    _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: Duration(seconds: 60),
        verificationCompleted: (AuthCredential authCredential) async {
          await _auth.signInWithCredential(authCredential);
          // Sign the user in with the credential
          var result = await _bloc.submitLogin();

          if (result) {
            Navigator.of(context).pop();
            _goToNoteScreen(context);
          } else {
            //Show the wrongPassword dialog
            _showWrongPass();
          }
        },
        verificationFailed: (FirebaseAuthException authException) {
          _showNotRegistered(authException.message);
        },
        codeSent: (String verID, int forceResendingToken) async {
          _codeSent(verID, forceResendingToken);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print("Timeout");
        });
  }

  _showNotRegistered(String message) {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Log In Failed'),
            content: SingleChildScrollView(
              child: Text('$message'),
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
        });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
