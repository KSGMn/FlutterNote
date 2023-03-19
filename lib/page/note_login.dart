import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider_note_example/page/note_login_screen.dart';
import 'package:provider_note_example/page/note_list.dart';


class NoteLoginPage extends StatelessWidget {
  const NoteLoginPage({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
            if(!snapshot.hasData){
              return LoginWidget();
            } else {
              return NoteListPage();
            }
          },
        ),
      ),
    );
  }
}


