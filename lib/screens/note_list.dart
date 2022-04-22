import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import '../helper/database_helper.dart';
import '../model/note.dart';
import 'note_details.dart';
import '/utility/config.dart';

class NoteList extends StatefulWidget {
  const NoteList({Key? key}) : super(key: key);

  @override
  State<NoteList> createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> list = <Note>[];
  int count = 0;
  bool isLoading = true;
  bool isDark = false;
  bool isListView = true;

  @override
  void initState() {
    super.initState();
    updateListView();
    setState(() {
      if (currentTheme.currentTheme() == ThemeMode.dark) {
        isDark = true;
      }
    });
  }

  // @override
  // void dispose() {
  //   super.dispose();
  //   databaseHelper.close();
  // }

  @override
  Widget build(BuildContext context) {
    // ignore: unnecessary_null_comparison
    // if (list == null) {
    //   list = <Note>[];
    //   updateListView();
    // }

    return Scaffold(
      appBar: AppBar(
        title: const Text('QuickNotes'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: Icon(
              isListView ? Icons.menu_rounded : Icons.grid_on_rounded,
            ),
            onPressed: () {
              setState(() {
                isListView = !isListView;
              });
            },
          ),
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () {
              setState(() {
                isDark = !isDark;
                currentTheme.switchTheme();
              });
            },
          ),
        ],
      ),
      body: isLoading ? const CircularProgressIndicator() : getNoteListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToNoteDetail(Note('', '', 1, ''), 'Add Note');
        },
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  ListView getNoteListView() {
    return ListView.builder(
      itemCount: count,
      itemBuilder: (context, position) {
        return Card(
          margin: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              4.0,
            ),
          ),
          color:
              list[position].priority == 1 ? Colors.purple : Colors.purple[300],
          elevation: 4.0,
          child: ListTile(
            leading: const CircleAvatar(
              backgroundImage:
                  NetworkImage('https://learncodeonline.in/mascot.png'),
            ),
            title: Text(
              list[position].title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
            subtitle: Text(
              list[position].description,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.normal,
                fontSize: 16.0,
              ),
            ),
            trailing: SizedBox(
              width: 100,
              child: Row(children: <Widget>[
                IconButton(
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    navigateToNoteDetail(list[position], 'Edit Todo');

                    debugPrint('id:' + list[position].id.toString());
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    _delete(list[position].id!);
                  },
                ),
              ]),
            ),
          ),
        );
      },
    );
  }

  void navigateToNoteDetail(Note note, String title) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetails(note, title);
    }));

    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initalizeDatabase();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          list = noteList;
          count = noteList.length;
          isLoading = false;
        });
      });
    });
  }

  void _delete(int id) async {
    int result = await databaseHelper.deleteNote(id);
    if (result != 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Successfully deleted !'),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error Deleting'),
      ));
    }
    updateListView();
  }
}
