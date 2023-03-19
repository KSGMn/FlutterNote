import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider_note_example/data/note.dart';

class NoteProvider extends ChangeNotifier {
  List<Note> _notes = [];


  getNote(int index) {
    return _notes[index];
  }
  bool? _ViewButton = false;

  get getViewButton {
    return _ViewButton;
  }

  void ViewButtonChange() {
    if(_ViewButton == true){
      _ViewButton = false;
    } if (_ViewButton == false) {
      _ViewButton = true;
    }
    notifyListeners();
  }

  void ViewButtonfalse() {
    _ViewButton = false;
    notifyListeners();
  }

  bool? _SelectedButton = false;

  get getSelectedButton {
    return _SelectedButton;
  }

  void ButtonChange() {
    if(_SelectedButton == true) {
      _SelectedButton = false;
    } if(_SelectedButton == false) {
      _SelectedButton = true;
    }
    notifyListeners();
  }

  void Buttonfalse() {
    _SelectedButton = false;
    notifyListeners();
  }




  final ligthTheme = ThemeData(
      // brightness: Brightness.light,
    // accentColor: Colors.white70,
    primarySwatch: primaryBlack,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black38,
    ),
    scaffoldBackgroundColor: Colors.white,
    // cardColor: Colors.black38,
    cardTheme: CardTheme(
      shape: OutlineInputBorder(

      )
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: Colors.white,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black38,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black38,
      )
    )
  );

  final DarkTheme = ThemeData(
      brightness: Brightness.dark,
      primarySwatch: primaryGrey,
    // primarySwatch: Colors.grey,
      appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[850]
  ),
    scaffoldBackgroundColor: Colors.grey[850],
    cardColor: Colors.grey[800],
      buttonTheme: ButtonThemeData(
        textTheme: ButtonTextTheme.primary,
      ),
   textButtonTheme: TextButtonThemeData(
     style: ButtonStyle(
       foregroundColor : MaterialStateProperty.all(Colors.white),
     ),
   ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.grey[800],
      foregroundColor: Colors.white,
    ),
    cardTheme: CardTheme(
      color: Colors.grey[800],
    ),
   inputDecorationTheme: InputDecorationTheme(
     focusedBorder: UnderlineInputBorder(
       borderSide: BorderSide(color: primaryGrey2),
     )
   ),
    textSelectionTheme: TextSelectionThemeData(
      selectionColor: Colors.lightBlue,
      selectionHandleColor: Colors.lightBlue,
      cursorColor: Colors.white,
    )
  );


  // void addNote(String title, String body, bool isSelected) {
  //   Note note = new Note(title, body, false);
  //
  //   _notes.add(note);
  //   notifyListeners();
  // }

  // void removeNote(int index) {
  //   _notes.removeAt(index);
  //   notifyListeners();
  // }
  //
  // void removeSelectNote(int index) {
  //   _notes.removeWhere(
  //       (element) => element.isSelected == _notes[index].isSelected);
  //   notifyListeners();
  // }

 // List<Note> get SelectNoteIndex{
 //    final whereNote = _notes.where((element) => element.isSelected == true).toList();
 //    return whereNote;
 // }
 //
 //  List<Note> get listNote {
 //    return _notes;
 //  }
 //
 //  void updateNote(int index, Note note) {
 //    _notes[index] = note;
 //    notifyListeners();
 //  }

  // void updateCount() {
  //   _conunt ++;
  //   notifyListeners();
  // }


}



const MaterialColor primaryGrey = MaterialColor(
  _greyPrimaryValue,
  <int, Color>{
    50: Color(0xFFFAFAFA),
    100: Color(0xFFF5F5F5),
    200: Color(0xFFEEEEEE),
    300: Color(0xFFE0E0E0),
    350: Color(0xFFD6D6D6), // only for raised button while pressed in light theme
    400: Color(0xFFBDBDBD),
    500: Color(0xFF9E9E9E),
    600: Color(0xFF757575),
    700: Color(0xFF616161),
    800: Color(0xFF424242),
    850: Color(0xFF303030), // only for background color in dark theme
    900: Color(0xFF212121),
  },
);
const int _greyPrimaryValue = 0xFF424242;


const MaterialColor primaryGrey2 = MaterialColor(
  _greyPrimaryValue2,
  <int, Color>{
    50: Color(0xFFFAFAFA),
    100: Color(0xFFF5F5F5),
    200: Color(0xFFEEEEEE),
    300: Color(0xFFE0E0E0),
    350: Color(0xFFD6D6D6), // only for raised button while pressed in light theme
    400: Color(0xFFBDBDBD),
    500: Color(0xFF9E9E9E),
    600: Color(0xFF757575),
    700: Color(0xFF616161),
    800: Color(0xFF424242),
    850: Color(0xFF303030), // only for background color in dark theme
    900: Color(0xFF212121),
  },
);
const int _greyPrimaryValue2 = 0xFF303030;



const MaterialColor primaryWhite = MaterialColor(
  _whitePrimaryValue,
  <int, Color>{
    50: Color(0xFFFAFAFA),
    100: Color(0xFFF5F5F5),
    200: Color(0xFFEEEEEE),
    300: Color(0xFFE0E0E0),
    350: Color(0xFFD6D6D6), // only for raised button while pressed in light theme
    400: Color(0xFFBDBDBD),
    500: Color(0xFF9E9E9E),
    600: Color(0xFF757575),
    700: Color(0xFF616161),
    800: Color(0xFF424242),
    850: Color(0xFF303030), // only for background color in dark theme
    900: Color(0xFF212121),
  },
);
const int _whitePrimaryValue = 0xFFFFFFFF;

const MaterialColor primaryBlack = MaterialColor(
  _blackPrimaryValue,
  <int, Color>{
    50: Color(0xFFFAFAFA),
    100: Color(0xFFF5F5F5),
    200: Color(0xFFEEEEEE),
    300: Color(0xFFE0E0E0),
    350: Color(0xFFD6D6D6), // only for raised button while pressed in light theme
    400: Color(0xFFBDBDBD),
    500: Color(0xFF9E9E9E),
    600: Color(0xFF757575),
    700: Color(0xFF616161),
    800: Color(0xFF424242),
    850: Color(0xFF303030), // only for background color in dark theme
    900: Color(0xFF212121),
  },
);
const int _blackPrimaryValue = 0x61000000;

