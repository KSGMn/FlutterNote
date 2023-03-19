// class Note {
//
//   final String title;
//
//   final String body;
//
//   bool isSelected;
//
//   Note(this.title,this.body,this.isSelected);
//
// }

import 'package:cloud_firestore/cloud_firestore.dart';

// Future createNote({
//   required String title,
//   required String body,
//   required bool isSelected,
// }) async {
//   final docUser = FirebaseFirestore.instance.collection('Notes').doc();
//
//   final user = Note(
//     title: title,
//     body: body,
//     isSelected: false,
//   );
//   final json = user.toJson();
//
//   await docUser.set(json);
// }

class Note {


  final String title;

  final String body;

  bool isSelected;

  Note({
    required this.title,
    required this.body,
    required this.isSelected});


  Map<String, dynamic> toJson() => {
    'note_title' : title,
    'note_body' : body,
    'note_isSelected' : isSelected,
  };

}

