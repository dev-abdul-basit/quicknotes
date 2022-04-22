class Note {
  int? _id;
  late String _title;
  late String _description;
  late String _date;
  late int _priority;

  // Constructor for Creating new Class object
  Note(this._title, this._date, this._priority, this._description);

  //Constructor for editing an existing class object with _id
  // Note.withId(this._id, this._title, this._date, this._priority,
  //     [this._description]);
  Note.withId(
      this._id, this._title, this._date, this._priority, this._description);

  // All the getters
  int? get id => _id;
  String get title => _title;
  String get description => _description;
  String get date => _date;
  int get priority => _priority;

  //All the setters
  set setTitle(String newTitle) {
    if (newTitle.length <= 255) {
      _title = newTitle;
    }
  }

  set setDescription(String newDescription) {
    if (newDescription.length <= 255) {
      _description = newDescription;
    }
  }

  set setDate(String newDate) {
    _date = newDate;
  }

  set setPriority(int newPriority) {
    if (newPriority >= 1 && newPriority <= 2) {
      _priority = newPriority;
    }
  }

  // Functions to save and retreive data from database
  // Converting note object to a map object, and a map object is returened
  Map<String, Object?> toMap() {
    var map = <String, Object?>{};

    if (id != null) {
      map['id'] = _id;
    }
    map['title'] = _title;
    map['description'] = _description;
    map['date'] = _date;
    map['priority'] = _priority;
    return map;
  }

  // Converting map to note back
  Note.fromMapObject(Map<String, dynamic> map) {
    _id = map['id'];
    _title = map['title'];
    _description = map['description'];
    _date = map['date'];
    _priority = map['priority'];
  }
}
