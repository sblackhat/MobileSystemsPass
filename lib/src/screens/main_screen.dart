
/*import 'package:MobileSystemsBio/src/functions/note_handler.dart';
import 'package:MobileSystemsBio/src/screens/notebook_screen.dart';
import 'package:MobileSystemsBio/src/screens/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import 'login_by_phone.dart';

class LoginScreen extends StatefulWidget{
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>{
  LocalAuthentication _auth = LocalAuthentication();
  bool _canCheckBio;
  List<BiometricType> _availableBio;
  String _authorized = "Not authorized";

  Future<void> _checkBio() async {
    bool canCheckBio;
    try{
      canCheckBio = await _auth.canCheckBiometrics;
    } on PlatformException catch(e){
      print(e);
    }
    if(!mounted) return;
      setState(() {
        _canCheckBio = canCheckBio;
      });
    
  }

  Future<void> _getAvailableBio() async {
    List<BiometricType> availableBio;
    try{
      availableBio = await _auth.getAvailableBiometrics();
    }on PlatformException catch(e){
      print(e);
    }
    setState(() {
      _availableBio = availableBio;
    });
  }

   Future<void>_authenticate()  async {
    bool authenticated = false;

    try{
      authenticated = await _auth.authenticateWithBiometrics(
        localizedReason: "Put your finger on the sensor to authenticate",
        useErrorDialogs: true,
        stickyAuth: false);
    }on PlatformException catch(e){
      print(e);
    }

    if(!mounted) return;
      setState(() {
        _authorized = authenticated ? "Authenticated sucessfuly" : "Failed to authenticate";
        if(authenticated){
          NoteHandler.init();
          Navigator.push(context, MaterialPageRoute(builder: (context) => NoteBookScreen()));
        }
        print(_authorized);
      });
    
  }

   _goToSignUp(context){
     Navigator.push(context, MaterialPageRoute(builder: (context) => SignUp()));
   }

  @override
  void initState(){
    super.initState();
    _checkBio();
    _getAvailableBio();
  }

  @override
  Widget build(BuildContext context) {
   return SafeArea(child: 
   Scaffold(
     backgroundColor: Color(0x37474F),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Log In Text
            Center(
              child: Text("Login", style: TextStyle(
                color: Colors.white10, 
                fontSize: 40,
                fontWeight: FontWeight.bold)
                ,)
            ),

           Center(
              child: Text("Secure Notebook", style: TextStyle(
                color: Colors.white10, 
                fontSize: 40,
                fontWeight: FontWeight.bold)
                ,)
            ),

          Container(
            margin: EdgeInsets.symmetric(vertical: 50.0),
            child: Column(children: [
              Icon(
                Icons.fingerprint,
                color: Colors.blue,
                size: 120,
              ),
          Text("FingerPrint Auth", style: TextStyle(
            color: Colors.white,
            fontSize: 32.0,
            fontWeight: FontWeight.bold,
          ),
          ),

          Container(
            margin: EdgeInsets.symmetric(vertical: 15.0),
            width: double.infinity,
            child: RaisedButton(
              onPressed: _authenticate,
              elevation:0.0,
              color: Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
                child: Text("Authenticate",style: TextStyle(
                  color: Colors.white),),
                ),
              ),
            ),

          Container(width: 250,
          child: Text("Cannot authenticate with fingerprint? Try phone OTP",style: TextStyle(fontSize: 20),)),

          /*Container(
            margin: EdgeInsets.symmetric(vertical: 15.0),
            width: 240,
            child: RaisedButton(
              onPressed: _logInByPhone,
              elevation:0.0,
              color: Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
                child: Text("Log In by phone",style: TextStyle(
                  color: Colors.white),),
                ),
              ),
            ),*/
            Container(width: 250,
          child: Text("Not registered yet?",style: TextStyle(fontSize: 16),)),

          Container(
            margin: EdgeInsets.symmetric(vertical: 15.0),
            width: 240,
            child: RaisedButton(
              onPressed: _goToSignUp(context),
              elevation:0.0,
              color: Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
                child: Text("Sign Up",style: TextStyle(
                  color: Colors.white),),
                ),
              ),
            ),    
            
            ],
            ),
          ),

          ],
        ),
      ),
   ));
  }
  
}*/