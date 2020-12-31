import 'package:MobileSystemsPass/src/bloc/bloc_sign_up.dart';
import 'package:MobileSystemsPass/src/screens/login_screen.dart';
import 'package:MobileSystemsPass/src/screens/signup_success.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:MobileSystemsPass/src/captcha/captcha.dart';
import 'package:MobileSystemsPass/src/screens/notebook_screen.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  SignUpBloc _bloc = SignUpBloc();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _passController = TextEditingController();
  TextEditingController _passRepeatController = TextEditingController();
  TextEditingController _userNameController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  bool _success;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register in the notebook')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        key: _formKey,
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
    return RaisedButton(
        color: Colors.lightGreen,
        disabledColor: Colors.grey,
        child: Text(
          'Register',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          _onPressRegister(snapshot, context);
        });
  }

  Future<void> _onPressRegister(snapshot, context) async {
   // if (snapshot.hasData && snapshot.data) {
      //Check if the user has verified the CAPTCHA
      var result = _bloc.getVerify;
      print("Verify $result");
      if (_bloc.getVerify) {
        /** bloc_registerUser */
        var resul = "+34" + _phoneNumberController.value.text;
        print(resul);
        _registerUser(resul, context);
      }else
      _showNotVerified();
      //Show the not verified alertDialog
    //}else print("te jodes");
  }

  Future _registerUser(String mobile, BuildContext context) async {
    FirebaseAuth _auth = FirebaseAuth.instance;

    _auth.verifyPhoneNumber(
        phoneNumber: mobile,
        timeout: Duration(seconds: 60),
        verificationCompleted: (AuthCredential authCredential) {
          _showRegistered(_userNameController.value.text,
              _phoneNumberController.value.text);
          print("reg");
          _clearSignUp();
        },
        verificationFailed: (FirebaseAuthException authException) {
          _showNotRegistered(authException.message);
          print("fail");
        },
        codeSent: (String verID,int forceResendingToken) => _codeSent(verID,forceResendingToken),
        codeAutoRetrievalTimeout: (String verificationId) {
          verificationId = verificationId;
          print(verificationId);
          print("Timout");
        });
  }

  _goToCaptchaScreen(context) {
    var captcha = CaptchaPage();
    captcha.setBloc(_bloc);
    Navigator.push(context, MaterialPageRoute(builder: (context) => captcha));
  }

  Widget recaptchaButton() {
    return Stack(children: <Widget>[
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
              onPressed: () {
                if (!_bloc.getVerify)
                  return _goToCaptchaScreen(context);
                else
                  return null;
              },
            ),
          ],
        ),
      )
    ]);
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

  _showRegistered(String username, String number) {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('REGISTERED!'),
            content: SingleChildScrollView(
              child: Text(
                  'You have been successufuly registered with phone number $number and username $username!'),
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

  _showNotRegistered(String message) {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('REGISTERED!'),
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
                    onPressed: () {
                      FirebaseAuth auth = FirebaseAuth.instance;
                      var smsCode = _codeController.text.trim();
                      var _credential = PhoneAuthProvider.getCredential(verificationId: verificationId, smsCode: smsCode);
                     auth.signInWithCredential(_credential).then((UserCredential result){
            Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) => HomeScreen(user: result.user)
            ));
          }).catchError((e){
            print(e);
          });
        },)
              ],
            ));
  }

  _clearSignUp() {
    _phoneNumberController.clear();
    _passController.clear();
    _passRepeatController.clear();
    _userNameController.clear();
  }
}
