import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:MobileSystemsPass/src/Mixin/Matcher.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:pointycastle/random/fortuna_random.dart';
import 'validatorHelpers.dart';


class Validator{
  static final _secure             = FlutterSecureStorage();
  static final _derivator          = KeyDerivator("Scrypt");
  static final int _iterations     = 16384;
  static final int _blocksize      = 32;
  static final int _paralelization = 1; 

  //Initalize the Keyderivation function   
  init() async {
  //Memory required = 128 * N * r * p bytes
  //128 * 2048 * 8 * 1 = 2 MB
   String salt = await _getSalt();
   Uint8List bytes = Uint8List.fromList(salt.codeUnits);
   //64 bytes key lenght
   var params    = ScryptParameters(_iterations,_blocksize,_paralelization,64,bytes);

   //Init the key derivation function
   _derivator.init(params);
  }

  static _getHashedPass(String password){
    final bytes = _derivator.process(new Uint8List.fromList(password.codeUnits));
    return formatBytesAsHexString(bytes);
  }

  static Future<String> _getSalt() async {
    return await _secure.read(key: "salt");
  }

  static Future<String> validatePassword(String password, String email) async{
    final String _wrongResult = 'Wrong password/email';

    //Check if the password has any not allowed character and
    //validate the email of the user
    if(Matcher.pass(password) && validateEmail(email)){
      final hash  = _getHashedPass(password);
      final stored = _secure.read(key: "email");
        //Check the stored hashed key and the input key
        if(stored != null && hash == stored)
          return null;
        else 
          return _wrongResult;
      } else return _wrongResult;
    }

  static Future<void> _writePass(String password,String email) async{
    final hashed = Validator._getHashedPass(password);
    _secure.write(key: "email", value: hashed);
    //Write new salt
    //Create a new salt every time the password changes
    final rnd = new FortunaRandom()..seed(new KeyParameter(new Uint8List(64)));
    //64 byte salt
    String salt = formatBytesAsHexString(rnd.nextBytes(64));
    //Store the salt
    _secure.write(key: "salt", value: salt);
    }
  
  static Future<bool> registerEmail(String email, String password) async {
    final bool containsEmail = await _secure.containsKey(key: email);
    if(!containsEmail){
      _writePass(email,password);
    }
    return !containsEmail;
  }

  }
