import 'package:hive/hive.dart';
import 'package:MobileSystemsPass/src/note/note.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../note/note.dart';
import 'code.dart';

class NoteHandler{ 
 static init(HiveAesCipher cipher) async {
    //Initialize the Hive DB
      await Hive.initFlutter();//waits to initialize path on flutter with the default path

    Hive.registerAdapter(NoteAdapter());
    Hive.registerAdapter(NoteTypeAdapter());
    Hive.registerAdapter(CheckListNoteAdapter());
    Hive.registerAdapter(TextNoteAdapter());
    print(Code.notesDB());
    await Hive.openBox<Note>(Code.notesDB(), encryptionCipher: cipher);//if it's the first time running, it will also create the "Box", else it will just open
    await Hive.openBox<TextNote>(Code.notesTextDB(), encryptionCipher: cipher);//this box will be used later for the Text Type entries
    await Hive.openBox<CheckListNote>(Code.notesCheckDB(), encryptionCipher: cipher);//this box will be used later for the Check List Type entries
  }
 
 static resetPass(HiveAesCipher cipher) async {
   //Get the old boxes
   Box<Note> notes = Hive.box(Code.notesDB());
   Box<TextNote> textnotes = Hive.box(Code.notesTextDB());
   Box<CheckListNote> checklist = Hive.box(Code.notesCheckDB());
   //Get the contents
   List<Note> notesList =[];
   if (notes.isNotEmpty) {
     notes.keys.forEach((key) { 
       notesList.add(notes.get(key));
     });
   }
   List<TextNote> textNotesList =[];
   if (textnotes.isNotEmpty) {
     textnotes.keys.forEach((key) { 
       textNotesList.add(textnotes.get(key));
     });
   }
   List<CheckListNote> notescheckList =[];
   if (checklist.isNotEmpty) {
     checklist.keys.forEach((key) { 
       notescheckList.add(checklist.get(key));
     });
   }
   
   //Delete the boxes
   notes.deleteFromDisk();
   textnotes.deleteFromDisk();
   checklist.deleteFromDisk();

   //Create the new boxes
  await Code.increaseVersion();
  print("heeeee");
  print(Code.notesDB());
   await Hive.openBox<Note>(Code.notesDB(), encryptionCipher: cipher);//if it's the first time running, it will also create the "Box", else it will just open
   await Hive.openBox<TextNote>(Code.notesTextDB(), encryptionCipher: cipher);//this box will be used later for the Text Type entries
   await Hive.openBox<CheckListNote>(Code.notesCheckDB(), encryptionCipher: cipher);//this box will be used later for the Check List Type entries
   Box<Note> notes2 = Hive.box(Code.notesDB());
   print(Code.notesCheckDB());
   Box<TextNote> textnotes2 = Hive.box(Code.notesTextDB());
   Box<CheckListNote> checklist2 = Hive.box(Code.notesCheckDB());
   //Copy all the contents
   if (notesList.isNotEmpty) {
     notesList.forEach((element) { 
       Note newNote = Note(element.dateCreated,element.title,
       element.description,element.dateUpdated,element.noteType,element.position);
       notes2.add(newNote);
     });
   }
   if (textNotesList.isNotEmpty) {
     textNotesList.forEach((element) { 
        TextNote newNote = TextNote(element.text, element.noteParent);
        textnotes2.add(newNote);
     });
   }
   if (notescheckList.isNotEmpty) {
     notescheckList.forEach((element) { 
        CheckListNote newNote = CheckListNote(element.text, element.done, element.position, element.noteParent);
        checklist2.add(newNote);
     });
   }

 }

 }