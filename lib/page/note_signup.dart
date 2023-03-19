import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider_note_example/page/note_login_screen.dart';

class SignUpWidget extends StatelessWidget {
  SignUpWidget({Key? key}) : super(key: key);

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
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('User').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          return Scaffold(
            appBar: AppBar(
              title: Text('회원가입'),
            ),
            body: SingleChildScrollView(
              reverse: true,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(height: 100,),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children:[
                        Container(
                          width: 30,
                        ),
                        Text('Sign up',
                          style: TextStyle(fontSize: 40),)
                      ]),
                  Container(height: 50,),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (value){
                              userName = value;
                            },
                            onSaved: (value){
                              userName = value!;
                            },
                            key: ValueKey(1),
                            decoration: InputDecoration(
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              hintText: '사용할 이름을 입력하세요',
                            ),
                            validator: (value){
                              if(value!.isEmpty || value.length<2){
                                return '유효한 이름을 입력해주세요';
                              }
                              return null;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (value){
                              userId = value;
                            },
                            onSaved: (value){
                              userId = value!;
                            },
                            key: ValueKey(2),
                            decoration: InputDecoration(
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              hintText: '사용할 이메일 주소를 입력하세요',
                            ),
                            validator: (value){
                              if(value!.isEmpty || !value.contains('@') || !value.contains('.com')){
                                return '유효한 이메일 주소를 입력해주세요';
                              }
                              return null;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: TextFormField(
                            obscureText: true,
                            onChanged: (value){
                              userPassword = value;
                            },
                            onSaved: (value){
                              userPassword = value!;
                            },
                            key: ValueKey(3),
                            validator: (value){
                              if(value!.isEmpty || value.length < 6){
                                return '비밀번호는 6자리 이상 입력해주세요';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                hintText: '사용할 비밀번호를 입력하세요'
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(height: 40,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        )
                      ),
                        onPressed: () async {
                          _tryValidation();
                          try {

                            final newUser =
                                await _authentication.createUserWithEmailAndPassword(
                                    email: userId,
                                    password: userPassword
                                );
                            String username = userName;

                            if(newUser.user != null) {
                             Navigator.push(context, MaterialPageRoute(builder: (context) => LoginWidget()));
                             await FirebaseFirestore.instance.collection('User').doc(newUser.user!.uid)
                                 .set({
                               'user_id' : userId,
                               'user_name' : userName,
                             });
                            }
                          } catch(e){
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('이메일, 비밀번호를 확인하세요',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),),
                              backgroundColor: Colors.grey[800],)
                            );
                          }
                        },
                        child: Text('회원가입')),
                  ),
                  Container(height: 50,),
                ],
              ),
            ),
          );
        }
      ),
    );
  }
}