import 'package:hive/hive.dart';
import 'package:mobileSystems/src/note/note.dart';
import 'package:intl/intl.dart' as intl;

class Code {
  changeUpdatedDate(int noteKey) async {
    Box<Note> notes = Hive.box<Note>("FlutterNotesDB");
    Note note = Hive.box<Note>("FlutterNotesDB")
        .values
        .singleWhere((value) => value.key == noteKey);
    note.dateUpdated = DateTime.now();
    await notes.put(noteKey, note);
  }
  String getDateFormated(DateTime date) {
    return intl.DateFormat('dd-MM-yyyy HH:mm:ss').format(date);
  }
}
