import 'dart:async';
import 'package:MobileSystemsPass/src/bloc/bloc_sign_up.dart';
import 'package:MobileSystemsPass/src/screens/signup_success.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:MobileSystemsPass/src/captcha/captcha.dart';
import 'package:flutter/semantics.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  SignUpBloc _bloc = SignUpBloc();
  //Manage the OTP button
  static const _timerDuration = 30;
  StreamController _timerStream = new StreamController<int>();
  int timerCounter;
  Timer _resendCodeTimer;
  //Controllers for the UI
  TextEditingController _passController = TextEditingController();
  TextEditingController _passRepeatController = TextEditingController();
  TextEditingController _userNameController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();

  @override
  void initState() {
    _activeCounter();

    super.initState();
  }

  _activeCounter() {
    _resendCodeTimer = new Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (_timerDuration - timer.tick > 0)
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
      appBar: AppBar(title: Text('Register in the notebook')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            //Phone Number field
            Text("Phone Number", style: TextStyle(fontSize: 12)),

            InternationalPhoneNumberInput(
              onInputChanged: (PhoneNumber number) =>
                  _bloc.phoneNumberOnChange(number.phoneNumber),
              onInputValidated: (bool value) => _bloc.validPhoneNumber = value,
              selectorConfig: SelectorConfig(
                selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
              ),
              ignoreBlank: false,
              autoValidateMode: AutovalidateMode.always,
              selectorTextStyle: TextStyle(color: Colors.black),
              initialValue: PhoneNumber(isoCode: "48"),
              textFieldController: _phoneNumberController,
              formatInput: false,
              keyboardType:
                  TextInputType.numberWithOptions(signed: true, decimal: true),
              inputBorder: OutlineInputBorder(),
            ),

            //UserName field
            StreamBuilder<String>(
                stream: _bloc.userNameStream,
                builder: (context, snapshot) {
                  return _userNameField(context, snapshot);
                }),

            Padding(
              padding: EdgeInsets.only(top: 25),
            ),

            //Text("Make sure you not forget this password!\nOtherwise you will lose your notes!"),

            //Password Field
            StreamBuilder<String>(
              stream: _bloc.passwordRegistrationStream,
              builder: (context, snapshot) {
                return passwordField(context, snapshot);
              },
            ),

            //Repeat Password Field
            StreamBuilder<String>(
              stream: _bloc.passwordRepeatStream,
              builder: (context, snapshot) {
                return repeatPasswordField(context, snapshot);
              },
            ),

            //Register BUTTON
            StreamBuilder<bool>(
                stream: _bloc.registerValid,
                builder: (context, snapshot) {
                  return _registerButton(context, snapshot);
                }),

            //Add some padding
            Padding(padding: EdgeInsets.only(top: 25.0, bottom: 25.0)),

            //CAPTCHA
            recaptchaButton(),
          ],
        ),
      ),
    );
  }

  Widget _userNameField(BuildContext context, dynamic snapshot) {
    return TextField(
      controller: _userNameController,
      decoration: InputDecoration(
        labelText: 'User Name',
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
        _bloc.passwordRegistrationOnChange(value);
      },
    );
  }

  Widget repeatPasswordField(BuildContext context, dynamic snapshot) {
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

  Widget _registerButton(context, snapshot) {
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
              onPressed: snapshot.data == 0 ? () {
                    _onPressRegister(snapshot, context);
                  } : null,
            ));
      },
    );
  }

  _onPressRegister(snapshot, context){
    if (snapshot.hasData && snapshot.data == 0) {
    //Check if the user has verified the CAPTCHA
    if (_bloc.getVerify) {
      var resul = "+34" + _phoneNumberController.value.text;
      print(resul);
      _registerUser(resul, context);
      _timerStream.sink.add(30);
      _activeCounter();
    } else if (_bloc.isRegistered()) {
      _showNotRegistered("You are already registered in this notebook");
    } else
      _showNotVerified();//Show the not verified alertDialog
    }
  }

  Future _registerUser(String mobile, BuildContext context) async {
    FirebaseAuth _auth = FirebaseAuth.instance;

    _auth.verifyPhoneNumber(
        phoneNumber: mobile,
        timeout: Duration(seconds: 60),
        verificationCompleted: (AuthCredential authCredential) async {
          await _auth.signInWithCredential(authCredential);
          _bloc.register();
          Navigator.pop(context);
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      RegisterScreen(user: _auth.currentUser)));
          _clearSignUp(); //Clear the UI details
        },
        verificationFailed: (FirebaseAuthException authException) {
          _showNotRegistered(authException.message);
        },
        codeSent: (String verID, int forceResendingToken) =>
            _codeSent(verID, forceResendingToken),
        codeAutoRetrievalTimeout: (String verificationId) {
          print("Timeout");
        });
  }

  _goToCaptchaScreen(context) {
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
          title: Text('Click the I am not a robot button'),
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

  _showNotRegistered(String message) {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Registration Failed'),
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

  _codeSent(String verificationId, [int forceResendingToken]) {
    //show dialog to take input from the user
    final TextEditingController _codeController = new TextEditingController();
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
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
                      // Sign the user in with the credential
                      _clearSignUp();
                      Navigator.of(context).pop();
                      dispose();
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  RegisterScreen(user: auth.currentUser)));
                    } catch (e) {
                      String message;
                      switch (e.message) {
                        case 'The SMS code has expired. Please re-send the verification code to try again':
                          message = 'The SMS is no longer valid';
                          break;
                        case 'The sms verification code used to create the phone auth credential is invalid. Please resend the verification code sms and be sure use the verification code provided by the user.':
                          message = "Wrong OTP code";
                          break;
                        case 'A network error (such as timeout, interrupted connection or unreachable host) has occurred.':
                          message = "Cannot stablish connection with the server";
                          break;
                        default:
                          message = e.message;
                      }
                       Navigator.of(context).pop();
                      _showNotRegistered(message);
                    }
                  },
                )
              ],
            ));
  }

  _clearSignUp() {
    _phoneNumberController.clear();
    _passController.clear();
    _passRepeatController.clear();
    _userNameController.clear();
  }

  @override
  void dispose() {
    _timerStream.close();
    super.dispose();
  }
}
