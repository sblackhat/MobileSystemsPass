import 'package:flutter/material.dart';
import 'package:flutter_recaptcha_v2/flutter_recaptcha_v2.dart';
import 'package:mobileSystems/src/bloc/login_bloc.dart';

class CaptchaPage extends StatefulWidget {
  CaptchaPage({Key key, this.title}) : super(key: key);

  // ignore: avoid_init_to_null
  LoginBloc _b = null;
  final String title;

  @override
  _CaptchaState createState() => _CaptchaState(_b);

  void loginBloc(LoginBloc bloc) {
    _b = bloc;
  }
}

class _CaptchaState extends State<CaptchaPage> {

  _CaptchaState(this._bloc);
  String _verifyText = "Not verified yet";

  final LoginBloc _bloc;
  RecaptchaV2Controller recaptchaV2Controller = RecaptchaV2Controller();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("CAPTCHA"),
      ),
      body: Stack(
        children: <Widget>[
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  child: Text("SHOW ReCAPTCHA"),
                  onPressed: () {
                    recaptchaV2Controller.show();
                  },
                ),
                Text(_verifyText),
              ],
            ),
          ),
          RecaptchaV2(
            apiKey: "6LeCwZYUAAAAAJo8IVvGX9dH65Rw89vxaxErCeou",
            apiSecret: "6LeCwZYUAAAAAKGahIjwfOARevvRETgvwhPMKCs_",
            controller: recaptchaV2Controller,
            onVerifiedError: (err){
              print(err);
            },
            onVerifiedSuccessfully: (success) {
              setState(() {
                if (success) {
                  _bloc.verify = true;
                  _verifyText = "You have been verified!!";
                } else {
                  _bloc.verify = false;
                  _verifyText = "Try to verify again!";
                }
              });
            },
          ),
        ],
      ),
    );
  }
}