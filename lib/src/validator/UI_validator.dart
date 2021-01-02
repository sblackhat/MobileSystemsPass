import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:MobileSystemsPass/src/Mixin/Matcher.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:pointycastle/random/fortuna_random.dart';
import 'validatorHelpers.dart';

class Validator {
  static final _secure = FlutterSecureStorage();
  static final _derivator = KeyDerivator("Scrypt");
  static final int _iterations = 16384;
  static final int _blocksize = 32;
  static final int _paralelization = 1;

  //Initalize the Keyderivation function
  static init() async {
    //Memory required = 128 * N * r * p bytes
    //128 * 2048 * 8 * 1 = 2 MB
    String salt = await _getSalt();
    if (salt != null) {
      Uint8List bytes = Uint8List.fromList(salt.codeUnits);
      //64 bytes key lenght
      var params =
          ScryptParameters(_iterations, _blocksize, _paralelization, 64, bytes);

      //Init the key derivation function
      _derivator.init(params);
    }
  }

  static _getHashedPass(String password) {
    final bytes =
        _derivator.process(new Uint8List.fromList(password.codeUnits));
    return formatBytesAsHexString(bytes);
  }

  static Future<String> _getSalt() async {
    return await _secure.read(key: "salt");
  }

  static Future<String> validatePassword(String password, String user) async {
    final String _wrongResult = 'Wrong password/email';
    //Initialize the cipher
    Validator.init();
    //Check if the password has any not allowed character and
    //validate the email of the user
    if (Matcher.pass(password)) {
      final hash = _getHashedPass(password);
      final stored = _secure.read(key: user);
      //Check the stored hashed key and the input key
      if (stored != null && hash == stored)
        return null;
      else
        return _wrongResult;
    } else
      return _wrongResult;
  }

   /*
   Functions below are used in the registration process
                                                        */

  static Future<void> _writePass(String password, String username) async {
    //Write new salt
    //Create a new salt every time the password changes
    final rnd = new FortunaRandom()..seed(new KeyParameter(new Uint8List(32)));
    //256 bit salt
    String salt = formatBytesAsHexString(rnd.nextBytes(32));
    //Store the salt
    _secure.write(key: "salt", value: salt);
    //Init the cipher
    Validator.init();
    //Get the passHash
    final hashed = Validator._getHashedPass(password);
    _secure.write(key: username, value: hashed);
    //Write the email
    _secure.write(key: "username", value: username);
  }

  static Future<bool> isRegistered(String userName){
    return _secure.containsKey(key: "username");
  }

  static void registerUserName(
      String username, String password, String phone) async {
      _secure.write(key: "phone", value: phone);
      _writePass(password, username);
  }
}
