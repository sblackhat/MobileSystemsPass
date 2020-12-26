import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'package:mobileSystems/src/Mixin/Matcher.dart';

class Validator{
  final _secure = FlutterSecureStorage();
  final _salt    = 'dKJw/,:n0y,l#+/x4u.akfldjaskao<Rb]ZW/A12bq68/Pb=bzJW3L=';
  final _seed     = 'MeltedIceberg200%Titanic';

  Validator(){
    /**   hash(hash($password) + salt)  *//*
    final hashed = new Hmac(sha256, utf8.encode(_seed));
    final Digest digest = hashed.convert(utf8.encode("SpainIs100%different" + _salt));
*/
    _secure.write(key: "MBSS", value: digest.toString());
    //_secure.write(key: "counter", value: "0");

    //print(digest.toString());
  }


  Future<String> validatePassword(String input, String user) async{
    final String _wrongResult = 'Wrong password/username';

    //Check if the password meets the requirements before checking
    /*
    More than 20 characters
    */
    if(Matcher.pass(input)){

        final hashed = new Hmac(sha256, utf8.encode(_seed));
        final Digest digest = hashed.convert(utf8.encode(input + _salt));
        final String stored = await _secure.read(key: user);
        
        //Check the stored hashed key and the input key
        if(stored != null && digest.toString() == stored )
          return null;
        else 
          return _wrongResult;
      } else return _wrongResult;
    }

    Future<void> writePass(String pass,String user) async{
      final hashed = new Hmac(sha256, utf8.encode(_seed));

      final Digest digested = hashed.convert(utf8.encode(pass +_salt));

      _secure.write(key: user, value: digested.toString());
    }
  

  }
