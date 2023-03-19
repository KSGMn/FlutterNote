import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_note_example/data/noteProvider.dart';


class AppSettingPage extends StatefulWidget {

  AppSettingPage({Key? key}) : super(key: key);

  @override
  State<AppSettingPage> createState() => _AppSettingPageState();
}

class _AppSettingPageState extends State<AppSettingPage> {


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<QuerySnapshot>(
        stream : FirebaseFirestore.instance.collection('Themedata').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot){
         final iconbool = snapshot.data?.docs[0].get('theme_bool');
          return Consumer<NoteProvider>(
              builder: (context, NoteProvider data, child) {
                return Scaffold(
                  appBar: AppBar(
                    title: Text('설정'),
                    centerTitle: true,
                    elevation: 0.0,
                    actions: [
                    ],
                  ),
                  body: Column(
                    children: [
                      Container(
                        height: 100,
                      width: double.infinity,

                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                          onPressed: () {
                            if(iconbool == false) {
                          FirebaseFirestore.instance
                              .collection('Themedata')
                              .doc('theme')
                              .update({
                            'theme_bool': true,
                          });
                        } else if(iconbool == true) {
                              FirebaseFirestore.instance
                                  .collection('Themedata')
                                  .doc('theme')
                                  .update({
                                'theme_bool': false,
                              });
                            }
                    },
                          icon: iconbool == false ? Icon(Icons.light_mode,size: 30,) : Icon(Icons.dark_mode,size: 30,),
                        ),
                          IconButton(onPressed: (){},
                              icon: Icon(Icons.settings,size: 30,)),
                          IconButton(onPressed: (){},
                              icon: Icon(Icons.settings,size: 30,)),
                          IconButton(onPressed: (){},
                              icon: Icon(Icons.settings,size: 30,)),
                        ]
                      ),
                    ),
                    ]
                  ),
                );
              }
          );
        },
      ),
    );
  }
}
