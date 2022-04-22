import 'package:flutter/material.dart';
import '../model/note.dart';
import '../helper/database_helper.dart';
import 'package:intl/intl.dart';

class NoteDetails extends StatefulWidget {
  final String appBarTitle;
  final Note? noteData;
  const NoteDetails(this.noteData, this.appBarTitle, {Key? key})
      : super(key: key);

  @override
  State<NoteDetails> createState() => _NoteDetailsState();
}

class _NoteDetailsState extends State<NoteDetails> {
  DatabaseHelper helper = DatabaseHelper();
  final _priorities = ['High', 'Low'];

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  // @override
  // void dispose() {
  //   super.dispose();
  //   helper.close();
  // }

  late Note note = Note.withId(
    widget.noteData!.id,
    widget.noteData!.title,
    widget.noteData!.date,
    widget.noteData!.priority,
    widget.noteData!.description,
  );

  @override
  Widget build(BuildContext context) {
    // TextStyle textStyle = Theme.of(context).textTheme.titleMedium.toString();
    titleController.text = widget.noteData!.title;
    descriptionController.text = widget.noteData!.description;

    debugPrint('\nnote details page id: ' + widget.noteData!.id.toString());
    debugPrint('\nnote priority: ' + note.priority.toString());

    return WillPopScope(
      onWillPop: () {
        moveToLastScreen();
        throw 'ERROROROROR';
      },
      child: Scaffold(
        backgroundColor: Colors.grey,
        appBar: AppBar(
          title: Text(widget.appBarTitle),
          backgroundColor: Colors.purple,
          leading: IconButton(
            onPressed: () {
              moveToLastScreen();
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: Card(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0),
              ),
            ),
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 25.0, bottom: 5.0),
                  //dropdown menu
                  child: ListTile(
                    leading: const Icon(Icons.low_priority),
                    title: DropdownButton(
                        items: _priorities.map((String dropDownStringItem) {
                          return DropdownMenuItem<String>(
                            value: dropDownStringItem,
                            child: Text(
                              dropDownStringItem,
                              style: const TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.grey),
                            ),
                          );
                        }).toList(),
                        value: getPriorityAsString(note.priority),
                        onChanged: (valueSelectedByUser) {
                          setState(() {
                            updatePriorityAsInt(valueSelectedByUser.toString());
                            debugPrint('\nnote priority Changed: ' +
                                note.priority.toString() +
                                "--" +
                                valueSelectedByUser.toString());
                          });
                        }),
                  ),
                ),
                // Second Element
                Padding(
                  padding: const EdgeInsets.only(
                      top: 15.0, bottom: 15.0, left: 15.0),
                  child: TextField(
                      controller: titleController,
                      onChanged: (value) {
                        updateTitle();
                      },
                      cursorColor: Colors.purple,
                      decoration: const InputDecoration(
                        hintStyle: TextStyle(color: Colors.purple),
                        labelText: 'Title',
                        icon: Icon(Icons.title),
                      )),
                ),

                // Third Element
                Padding(
                  padding: const EdgeInsets.only(
                      top: 15.0, bottom: 15.0, left: 15.0),
                  child: TextField(
                    cursorColor: Colors.purple,
                    controller: descriptionController,
                    // style: textStyle,
                    onChanged: (value) {
                      updateDescription();
                    },
                    decoration: const InputDecoration(
                      labelText: 'Details',
                      icon: Icon(
                        Icons.details,
                      ),
                    ),
                  ),
                ),

                // Fourth Element
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: ElevatedButton(
                          child: const Text(
                            'Save',
                            textScaleFactor: 1.5,
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            setState(() {
                              debugPrint("Save button clicked");
                              _save();
                            });
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.purple),
                            padding: MaterialStateProperty.all<EdgeInsets>(
                                const EdgeInsets.all(15)),
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.purple),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                side: const BorderSide(color: Colors.purple),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void updateTitle() {
    note.setTitle = titleController.text;
  }

  void updateDescription() {
    note.setDescription = descriptionController.text;
  }

  // void _delete() async {
  //   if (note.id == null) {
  //     _showAlertDialog('Status', 'First Add a note');
  //     return;
  //   }

  //   int result = await helper.deleteNote(note.id!);
  //   if (result != 0) {
  //     _showAlertDialog('Status', 'Note Deleted Successfully');
  //   } else {
  //     _showAlertDialog('Status', 'Error');
  //   }
  // }

  //Convert to int to save into database
  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        note.setPriority = 1;
        break;
      case 'Low':
        note.setPriority = 2;
        break;
    }
  }

  //Convert int to String to show to user
  String getPriorityAsString(int value) {
    String? priority;

    switch (value) {
      case 1:
        priority = _priorities[0];

        break;
      case 2:
        priority = _priorities[1];

        break;
    }
    return priority!;
  }

  void _save() async {
    note.setDate = DateFormat.yMMMd().format(DateTime.now());
    moveToLastScreen();
    int result;
    if (note.id != null) {
      result = await helper.updateNote(note);
      debugPrint('note updated');
    } else {
      result = await helper.insertNote(note);
      debugPrint('note Created');
    }
    if (result != 0) {
      //_showAlertDialog('Status', 'Note Saved Successfully');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Status: Note Saved Successfully'),
      ));
      debugPrint(' Saved noteeee');
    } else {
      _showAlertDialog('Status', 'Problem Saving Note');
      debugPrint('Problem Saving noteeee');
    }
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );

    showDialog(
        context: context, builder: (BuildContext context) => alertDialog);
  }
}
