import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_note_example/data/noteProvider.dart';
import 'package:provider_note_example/page/app_setting.dart';
import 'package:provider_note_example/page/note_edit.dart';
import 'package:provider_note_example/page/note_list.dart';
import 'package:provider_note_example/page/note_login.dart';
import 'package:provider_note_example/page/note_view.dart';

import 'firebase_options.dart';

void main()
async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
//   await Firebase.initializeApp(
//   options: DefaultFirebaseOptions.currentPlatform,
// );
  runApp(
      const MyApp());
}

class MyApp extends StatelessWidget {
   const MyApp({super.key});



  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Themedata').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        return ChangeNotifierProvider(
          create: (context) => NoteProvider(),
          child: Consumer<NoteProvider>(
            builder: (context, NoteProvider data, child){
              return  MaterialApp(
                title: 'Flutter Demo',
                theme: data.DarkTheme,
                initialRoute: '/login',
                routes: {
                  '/login' : (context) => NoteLoginPage(),
                  // '/list' : (context) => NoteListPage(),
                  // '/setting' : (context) => AppSettingPage(),
                  // '/edit' : (context) => NoteEditPage(),
                  // '/view' : (context) => NoteViewPage(),
                },
              );
            },
          ),
        );
      }
    );
  }
}

