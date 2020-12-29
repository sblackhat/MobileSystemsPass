import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:MobileSystemsPass/src/note/note.dart';
import 'package:MobileSystemsPass/src/screens/add_note.dart';
import 'package:MobileSystemsPass/src/screens/edit_check_note.dart';
import 'package:MobileSystemsPass/src/screens/edit_note.dart';
import 'package:MobileSystemsPass/src/screens/edit_text_note.dart';

class NoteBookScreen extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("NoteBook"),
        ),
        body: getNotes(),
        floatingActionButton: addNoteButton(),
      );
  }

  getNotes() {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Note>("notesBox").listenable(),
      builder: (context, Box<Note> box, _) {
        if (box.values.isEmpty) {
          return Center(
            child: Text("No Notes!"),
          );
        }
        List<Note> notes = getNotesList(); //get notes from box function
        return ReorderableListView(
            onReorder: (oldIndex, newIdenx) async {
              await reorderNotes(oldIndex, newIdenx, notes);
            },
            children: <Widget>[
              for (Note note in notes) ...[
                getNoteInfo(note, context),
              ],
            ]);
      },
    );
  }

  reorderNotes(oldIndex, newIdenx, notes) async {
    Box<Note> hiveBox = Hive.box<Note>("notesBox");
    if (oldIndex < newIdenx) {
      notes[oldIndex].position = newIdenx - 1;
      await hiveBox.put(notes[oldIndex].key, notes[oldIndex]);
      for (int i = oldIndex + 1; i < newIdenx; i++) {
        notes[i].position = notes[i].position - 1;
        await hiveBox.put(notes[i].key, notes[i]);
      }
    } else {
      notes[oldIndex].position = newIdenx;
      await hiveBox.put(notes[oldIndex].key, notes[oldIndex]);
      for (int i = newIdenx; i < oldIndex; i++) {
        notes[i].position = notes[i].position + 1;
        await hiveBox.put(notes[i].key, notes[i]);
      }
    }
  }

  getNotesList() {
    //get notes as a List
    List<Note> notes = Hive.box<Note>("notesBox").values.toList();
    notes = getNotesSortedByOrder(notes);
    return notes;
  }

  getNotesSortedByOrder(List<Note> notes) {
    //ordering note list by position
    notes.sort((a, b) {
      var aposition = a.position;
      var bposition = b.position;
      return aposition.compareTo(bposition);
    });
    return notes;
  }

  getNoteInfo(Note note, BuildContext context) {
    return ListTile(
      dense: true,
      key: Key(note.key.toString()),
      onTap: () {
        if (note.noteType == NoteType.Text) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EditTextNote(
                noteParent: note.key,
                noteTitle: note.title,
              ),
            ),
          );
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EditCheckNote(
                noteParent: note.key,
                noteTitle: note.title,
              ),
            ),
          );
        }
      },
      title: Container(
        padding: EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: Colors.black,
        ),
        child: Text(
          note.title,
          style: TextStyle(fontSize: 18),
        ),
      ),
      trailing: IconButton(
        icon: Icon(Icons.info, size: 22, color: Colors.blueAccent),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EditNote(
                noteKey: note.key,
              ),
            ),
          );
        },
      ),
    );
  }

  addNoteButton() {
    return Builder(
      builder: (context) {
        return FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => AddNote()));
          },
        );
      },
    );
  }
}