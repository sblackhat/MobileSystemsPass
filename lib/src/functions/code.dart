import 'package:hive/hive.dart';
import 'package:MobileSystemsPass/src/note/note.dart';
import 'package:intl/intl.dart' as intl;
import 'package:shared_preferences/shared_preferences.dart';

import '../validator/UI_validator.dart';

class Code {
  static String _notes_db;
  static String _text_notes_db;
  static String _checklist_notes_db;
  static int _version;

  static setNames(String notes,String textNotes, String checklist,{int version}) async {
    final prefs = await SharedPreferences.getInstance();
    if(version != null) await prefs.setInt("version", version);
    await prefs.setString("notes_db", notes);
    await prefs.setString("text_notes_db", textNotes);
    await prefs.setString("checklist_notes_db", checklist);
  }

  static init() async {
    final prefs = await SharedPreferences.getInstance();
    _notes_db = prefs.getString("notes_db");
    _text_notes_db =  prefs.getString("text_notes_db");
    _checklist_notes_db = prefs.getString("checklist_notes_db");
    _version = prefs.getInt("version");
  }

  static String notesDB() { print(_notes_db); return _notes_db;}
  static String notesTextDB()  {print(_text_notes_db); return _text_notes_db;}
  static String notesCheckDB() {print(_checklist_notes_db);return _checklist_notes_db;}
  

  static Future<void> increaseVersion() async {
    final prefs = await SharedPreferences.getInstance();
     _version = prefs.getInt("version");
     _version++;
     _notes_db = _notes_db.substring(0,_notes_db.length-1) + _version.toString();
     _text_notes_db = _text_notes_db.substring(0,_text_notes_db.length-1) + _version.toString();
     _checklist_notes_db = _checklist_notes_db.substring(0,_checklist_notes_db.length-1) + _version.toString();
     await setNames(_notes_db,_text_notes_db,_checklist_notes_db,version: _version);
  }

  changeUpdatedDate(int noteKey) async {
    Box<Note> notes = Hive.box<Note>(_notes_db);
    Note note = Hive.box<Note>(_notes_db)
        .values
        .singleWhere((value) => value.key == noteKey);
    note.dateUpdated = DateTime.now();
    await notes.put(noteKey, note);
  }
  String getDateFormated(DateTime date) {
    return intl.DateFormat('dd-MM-yyyy HH:mm:ss').format(date);
  }
}
