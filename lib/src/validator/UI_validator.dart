import 'dart:async';
import 'dart:typed_data';
import 'package:MobileSystemsPass/src/functions/note_handler.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:MobileSystemsPass/src/Mixin/Matcher.dart';
import 'package:hive/hive.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:pointycastle/random/fortuna_random.dart';
import '../functions/code.dart';
import '../functions/note_handler.dart';
import 'validatorHelpers.dart';

class Validator {
  static final _secure = FlutterSecureStorage();
  static final _derivator = KeyDerivator("scrypt");
  static final int _iterations = 256;
  static final int _blocksize = 8;
  static final int _paralelization = 1;
  static bool _init = false;

  //Initalize the Keyderivation function
  static init() async {
    //Memory required = 128 * N * r * p bytes
    //128 * 65536 * 8 * 1 = 2 MB
    String salt = await _getSalt();
    if (salt != null) {
      Uint8List bytes = Uint8List.fromList(salt.codeUnits);
      //64 bytes hash lenght
      var params =
          ScryptParameters(_iterations, _blocksize, _paralelization, 64, bytes);

      //Init the key derivation function
      _derivator.init(params);
    }
  }

  //Get the phone from the KeyStorage
  static Future<String> getPhone() async {
    String result = await _secure.read(key: "phone");
    return result;
  }

  //Returns the hashed password
  static Future<String> _getHashedPass(String password) async {
    Uint8List list = new Uint8List.fromList(password.codeUnits);
    final bytes = _derivator.process(list);
    return formatBytesAsHexString(bytes);
  }

  static Future<String> getUsername() async {
    return await _secure.read(key: "username");
  }

  static Future<String> _getSalt() async {
    return await _secure.read(key: "salt");
  }

  static Future<bool> validatePassword(String password, {String username}) async {
    //Check if the password has any not allowed character and
    //validate the username of the user
    if (Matcher.pass(password)) {
      Validator.init();
      final hash = await _getHashedPass(password);
      final stored = await _secure.read(key: "password");
      final user =  await _secure.read(key: "username");
      //Check the stored hashed key and the input key
      if (stored != null && hash == stored && (username==null || username==user)) {
        if (!_init) {
          final String padding = "000000000000000000";
          final bytes = (password + padding).codeUnits.sublist(0, 32);
          final rand = new FortunaRandom()
            ..seed(new KeyParameter(new Uint8List.fromList(bytes)));
          await NoteHandler.init(HiveAesCipher(rand.nextBytes(32)));
          _init = true;
        }
        return true;
      } else
        return false;
    } else
      return false;
  }

  /*
   Functions below are used in the registration process
                                                        */

  static Future<void> _writePass(String password) async {
    //Write new salt
    //Create a new salt every time the password changes
    final rnd = new FortunaRandom()..seed(new KeyParameter(new Uint8List(32)));
    //256 bit salt
    final bool a = await _secure.containsKey(key: "salt");
    String salt = formatBytesAsHexString(rnd.nextBytes(32));
    //Store the salt
    await _secure.write(key: "salt", value: salt);
    //Init the cipher
    await Validator.init();
    //Get the passHash;
    final hashed = await Validator._getHashedPass(password);
    final String padding = "000000000000000000";
    final bytes = (password + padding).codeUnits.sublist(0, 32);
    final rand = new FortunaRandom()
      ..seed(new KeyParameter(new Uint8List.fromList(bytes)));await _secure.write(key: "password", value: hashed);
    if(a) await NoteHandler.resetPass(HiveAesCipher(rand.nextBytes(32)));
    await _secure.write(key: "password", value: hashed);
  }

  static Future<bool> isRegistered() {
    return _secure.containsKey(key: "username");
  }

  static void registerUserName(
      {String username, String password, String phone}) async {
    if (username != null) _secure.write(key: "username", value: username);
    if (phone != null) _secure.write(key: "phone", value: phone);
    if (password != null) await _writePass(password);
  }
}
