import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import '../validator/UI_validator.dart';

class ChangePhone extends StatefulWidget {
  @override
  _ChangePhoneState createState() => _ChangePhoneState();
}

class _ChangePhoneState extends State<ChangePhone> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _newphone = TextEditingController();
  bool _validated = false;

  Future<void> _validateInputs() async {
    if (_validated && _formKey.currentState.validate()) {
      print(_newphone.text);
      _registerUser(_newphone.text, context);
    }else{
      _showResult("Cannot change the phone number", "Check the phone number you wrote");
    }
  }

    _showResult(String title,String message){
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
      return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Text(message),
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

  Future _registerUser(String mobile, BuildContext context) async {
    FirebaseAuth _auth = FirebaseAuth.instance;

    _auth.verifyPhoneNumber(
        phoneNumber: mobile,
        timeout: Duration(seconds: 60),
        verificationCompleted: (AuthCredential authCredential) async {
          await _auth.signInWithCredential(authCredential);
          _auth.currentUser.delete();
          Validator.registerUserName(phone: _newphone.text);
        },
        verificationFailed: (FirebaseAuthException authException) {
          _showResult("Cannot change the phone number", authException.message);
        },
        codeSent: (String verID, int forceResendingToken) =>
            _codeSent(verID, forceResendingToken),
        codeAutoRetrievalTimeout: (String verificationId) {
          print("Timeout");
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
                      final String phone = _newphone.text;
                      auth.currentUser.delete();
                      Validator.registerUserName(phone: _newphone.text);
                      Navigator.of(context).pop();
                      _showResult("Phone number successfuly changed!", "Your now phone number is $phone");
                    }on FirebaseAuthException catch (e) {
                      Navigator.of(context).pop();
                      _showResult("Phone number change failed", "Wrong OTP code");
                    }
                  },
                )
              ],
            ));
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(title: Text('Secure Black Notebook')),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(child: Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Text("New phone",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold))),),
              Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: InternationalPhoneNumberInput(
                    onInputChanged: (PhoneNumber phone) {
                      _newphone.text = phone.phoneNumber;
                    },
                    onInputValidated: (bool value) {
                      _validated = value;
                    },
                    selectorConfig: SelectorConfig(
                      selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                    ),
                    ignoreBlank: false,
                    autoValidateMode: AutovalidateMode.onUserInteraction,
                    selectorTextStyle: TextStyle(color: Colors.black),
                    formatInput: false,
                    keyboardType: TextInputType.numberWithOptions(
                        signed: true, decimal: true),
                    inputBorder: OutlineInputBorder(),
                  ),
                ),
              ),
              Center(
                child: RaisedButton(
                  onPressed: _validateInputs,
                  elevation: 0.0,
                  color: Colors.blue,
                  disabledColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
                    child: Text(
                      "Submit Changes",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  void dispose() {
    super.dispose();
    _newphone.clear();
  }
}
