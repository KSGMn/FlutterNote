import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider_note_example/page/note_list.dart';
import 'package:provider_note_example/page/note_signup.dart';

class LoginWidget extends StatelessWidget {
  LoginWidget({Key? key}) : super(key: key);

  final _authentication = FirebaseAuth.instance;

  final _formKey = GlobalKey<FormState>();
  String userName = '';
  String userId = '';
  String userPassword = '';

  void _tryValidation(){
    final isValid = _formKey.currentState!.validate();
    if(isValid){
      _formKey.currentState!.save();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Note'),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            reverse: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 100,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                    children:[
                      Container(
                        width: 30,
                      ),
                  Text('Sign in',
                  style: TextStyle(fontSize: 40),)
                ]),
                Container(
                  height: 50,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: TextFormField(
                          autofocus: true,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (value){
                            userId = value;
                          },
                          onSaved: (value){
                            userId = value!;
                          },
                          key: ValueKey(1),
                          decoration: InputDecoration(
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              hintText: 'E-mail'
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: TextFormField(
                          textInputAction: TextInputAction.done,
                          obscureText: true,
                          onChanged: (value){
                            userPassword = value;
                          },
                          onSaved: (value){
                            userPassword = value!;
                          },
                          key: ValueKey(2),
                          decoration: InputDecoration(
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              hintText: 'Password'
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children:[
                    TextButton(
                      onPressed: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignUpWidget()));
                      },
                      child: Text('sign up',)
                  ),
                    Container(
                      width: 30,
                    ),
                  ]
                ),
                Container(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)
                      ),
                      elevation: 0
                    ),
                      onPressed: () async {
                          _tryValidation();
                          try {
                          final newUser =
                          await _authentication.signInWithEmailAndPassword(
                              email: userId,
                              password: userPassword
                          );


                          if(newUser.user != null) {
                            Navigator.push(
                                context,
                                MaterialPageRoute
                                  (builder: (context) => NoteListPage()));
                          }
                        } on FirebaseException catch (e){
                            String message = '유효한 값이 아닙니다.';
                          if(e.code == 'user-not-found'){
                            message = '사용자가 존재하지 않습니다.';
                          } else if(e.code == 'wrong-password') {
                            message = '비밀번호를 확인하세요.';
                          } else if (e.code == 'invalid-email') {
                            message = '이메일을 확인하세요.';
                          }ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message,style: TextStyle(
                            color: Colors.white,
                          ),),
                          backgroundColor: Colors.grey[800],));
                        }
                      },
                      child: Text('로그인')),
                ),
                Container(
                  height: 30,
                ),
                Container(
                  height: 70,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}