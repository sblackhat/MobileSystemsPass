import 'dart:async';
import 'dart:typed_data';
import 'package:MobileSystemsPass/src/functions/note_handler.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:MobileSystemsPass/src/Mixin/Matcher.dart';
import 'package:hive/hive.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:pointycastle/random/fortuna_random.dart';
import 'validatorHelpers.dart';

class Validator {
  static final _secure = FlutterSecureStorage();
  static final _derivator = KeyDerivator("scrypt");
  static final int _iterations = 128;
  static final int _blocksize = 8;
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

  static Future<String> getPhone() async { 
    String result = await _secure.read(key: "phone");
    print(result);
    print(result.replaceRange(1, 3, "34"));
    return result.replaceRange(1, 3, "34"); }

  static String _getHashedPass(String password) {
    Uint8List list = new Uint8List.fromList(password.codeUnits);
    final bytes =
        _derivator.process(list);
    return formatBytesAsHexString(bytes);
  }

  static Future<String> _getSalt() async {
    return await _secure.read(key: "salt");
  }

  static Future<bool> validatePassword(String password, String username) async {

    //Check if the password has any not allowed character and
    //validate the username of the user
    if (Matcher.pass(password)) {
      Validator.init();
      final hash = _getHashedPass(password);
      final stored = await _secure.read(key: username);
      //Check the stored hashed key and the input key
      if (stored != null && hash == stored){
        final String _salt = await _getSalt();
        final bytes = (password + _salt).codeUnits.sublist(0,32);
        final rand = new FortunaRandom()..seed(new KeyParameter(new Uint8List.fromList(bytes)));
        await NoteHandler.init(HiveAesCipher(rand.nextBytes(32)));
        return true;
      }
      else
        return false;
    } else
      return false;
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
    await Validator.init();
    //Get the passHash;
    final hashed = Validator._getHashedPass(password);
    await _secure.write(key: username, value: hashed);
  }

  static Future<bool> isRegistered(){
    return _secure.containsKey(key: "username");
  }

  static void registerUserName(
      String username, String password, String phone) async {
      _secure.write(key: "username", value: username);
      _secure.write(key: "phone", value: phone);
      _writePass(password, username);
  }
}
