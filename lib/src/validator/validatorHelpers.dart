import 'dart:typed_data';
import 'package:email_validator/email_validator.dart';

/// Creates a hexdecimal representation of the given [bytes].
String formatBytesAsHexString(Uint8List bytes) {
  var result = new StringBuffer();
  for (var i = 0; i < bytes.lengthInBytes; i++) {
    var part = bytes[i];
    result.write('${part < 16 ? '0' : ''}${part.toRadixString(16)}');
  }
  return result.toString();
}

 bool validateEmail(String email){
    return EmailValidator.validate(email);
  }

