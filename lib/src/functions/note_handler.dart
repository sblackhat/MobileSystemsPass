import 'package:hive/hive.dart';
import 'package:MobileSystemsPass/src/note/note.dart';
import 'package:hive_flutter/hive_flutter.dart';

class NoteHandler{ 
 static init() async {
    //Initialize the Hive DB
      await Hive.initFlutter();//waits to initialize path on flutter with the default path
      
    Hive.registerAdapter(NoteAdapter());
    Hive.registerAdapter(NoteTypeAdapter());
    Hive.registerAdapter(CheckListNoteAdapter());
    Hive.registerAdapter(TextNoteAdapter());
    await Hive.openBox<Note>("notesBox");//if it's the first time running, it will also create the "Box", else it will just open
    await Hive.openBox<TextNote>("textNotesBox");//this box will be used later for the Text Type entries
    await Hive.openBox<CheckListNote>("CheckListNotes");//this box will be used later for the Check List Type entries
  }
}