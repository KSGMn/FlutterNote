import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NoteEditPage extends StatefulWidget {
  static const routeName = '/edit';

  int? index;

  String? id;


  NoteEditPage({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  State<NoteEditPage> createState() => _NoteEditPageState();
}

class _NoteEditPageState extends State<NoteEditPage> {
  final titleController = TextEditingController();

  final bodyController = TextEditingController();



  String Selectcategorytitle = 'All';

  late FocusNode myFocusNode;

  Future reload() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FirebaseAuth auth = FirebaseAuth.instance;
      final docid = auth.currentUser!.uid;
      final noteId = widget.id;
      final note = FirebaseFirestore.instance
          .collection('User')
          .doc(docid)
          .collection('Notes')
          .doc(noteId);
      final Truecategory =  FirebaseFirestore.instance
          .collection('User')
          .doc(docid)
          .collection('Category')
          .where('category_isSelected', isEqualTo: true);
      setState(() {
        if (noteId != null) {
          note.get().then((DocumentSnapshot doc) {
            titleController.text = doc['note_title'];
            bodyController.text = doc['note_body'];
          });
          note.get().then((snapshot){
            Selectcategorytitle = snapshot.data()!['note_category'].toString();
          });
        } else if (Truecategory != null) {
          Truecategory.get().then((value) {
            Selectcategorytitle = value.docs[0]['category_title'];
          });
        }
      });
    });
  }

  @override
  initState() {
    super.initState();
    reload();
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;

    final docid = auth.currentUser!.uid;

    final CollectionReference ref = FirebaseFirestore.instance
        .collection('User')
        .doc(docid)
        .collection('Notes');

    final noteId = widget.id;

    final note = FirebaseFirestore.instance
        .collection('User')
        .doc(docid)
        .collection('Notes')
        .doc(noteId);

    return SafeArea(
      child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('User')
              .doc(docid)
              .collection('Notes')
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            final notes = snapshot.data?.docs;
            return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('User')
                    .doc(docid)
                    .collection('Category')
                    .where('category_isSelected', isEqualTo: true)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  final ctgt = snapshot.data?.docs;
                  final Cname = ctgt?.length == 1 ? ctgt![0]['category_title'] : null;
                  final Cnotes = notes?.where((element) => element.get('note_category') == Cname).toList();
                  return Scaffold(
                    appBar: AppBar(
                      elevation: 0,
                      // actions: [
                      //   Container(
                      //     width: 80,
                      //     child: TextButton(
                      //       style: TextButton.styleFrom(
                      //         foregroundColor: Colors.white,
                      //       ),
                      //       onPressed: () {
                      //         _displayCategorySelectionDialog();
                      //       },
                      //       child:  Text(
                      //         Selectcategorytitle,
                      //         maxLines: 1,
                      //         overflow: TextOverflow.ellipsis,
                      //         style: TextStyle(
                      //           color: Colors.white,
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ],
                      title: Text('NoteEdit'),
                      centerTitle: true,
                    ),
                    body: GestureDetector(
                      onDoubleTap: () {},
                      child: SizedBox.expand(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration(
                                      fillColor: Colors.white,
                                      border: InputBorder.none,
                                      hintText: '제목 입력'),
                                  maxLines: null,
                                  controller: titleController,
                                ),
                                SizedBox(
                                  height: 8.0,
                                ),
                                TextFormField(
                                  autofocus: true,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: '노트를 입력하세요',
                                  ),
                                  minLines: 25,
                                  maxLines: null,
                                  controller: bodyController,
                                  keyboardType: TextInputType.multiline,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    floatingActionButton: FloatingActionButton(
                      child: Icon(Icons.save),
                      onPressed: () {
                        final noteId = widget.id;
                        if (bodyController.text.isNotEmpty) {
                          if (noteId != null) {
                            // snapshot.data!.docs[widget.index!].reference.update({
                            //   'note_title': titleController.text,
                            //     'note_body': bodyController.text,
                            // }).whenComplete(() => Navigator.pop(context,note));1
                            FirebaseFirestore.instance
                                .collection('User')
                                .doc(docid)
                                .collection('Notes')
                                .doc(noteId)
                                .update({
                              'note_title': titleController.text,
                              'note_body': bodyController.text,
                              'note_category': Selectcategorytitle,
                            }).whenComplete(() =>
                                    Navigator.pop(context, snapshot.data));
                          } else {
                            ref.add({
                              'note_title': titleController.text,
                              'note_body': bodyController.text,
                              'note_isSelected': false,
                              'note_category': Selectcategorytitle,
                              'note_time': Timestamp.now(),
                              'note_auth': auth.currentUser!.uid,
                            }).whenComplete(
                                () => Navigator.pop(context, snapshot.data));
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('노트를 입력하세요'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }

                        // if (bodyController.text.isNotEmpty) {
                        //   final note = Note(
                        //     titleController.text,
                        //     bodyController.text,
                        //     false
                        //   );
                        //   final noteIndex = widget.index;
                        //   if(noteIndex != null) {
                        //     context.read<NoteProvider>().updateNote(noteIndex, note);
                        //   } else {
                        //     context.read<NoteProvider>().addNote(
                        //         titleController.text, bodyController.text,false);
                        //   }
                        //
                        //   Navigator.pop(context,note);
                        // }
                        // else {
                        //   ScaffoldMessenger.of(context).showSnackBar(
                        //     SnackBar(content: Text('노트를 입력하세요'),
                        //       behavior: SnackBarBehavior.floating,),
                        //   );
                        // }
                      },
                    ),
                  );
                });
          }),
    );
  }

  void _displayCategorySelectionDialog() {
    FocusManager.instance.primaryFocus?.unfocus();

    FirebaseAuth auth = FirebaseAuth.instance;

    final docid = auth.currentUser!.uid;

    showDialog(
      context: context,
      builder: (context) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('User')
              .doc(docid)
              .collection('Category')
              .orderBy('category_time', descending: false)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            final ctg = snapshot.data?.docs;
            final ctglenght = ctg?.length ?? 0;
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              title: Text('카테고리 선택'),
              content: Container(
                width: double.minPositive,
                // height: ctglenght > 0 ? ctglenght * 70 : 70,
                // width: 250,
                child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: ctglenght + 1,
                    itemBuilder: (context, index) {
                      if (index == 0 || index == ctglenght + 1) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: InkWell(
                            customBorder: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                            ),
                            child: ListTile(
                              title: Text('All'),
                            ),
                            onTap: () {
                              setState(() {
                                Navigator.pop(context);
                                Selectcategorytitle = 'All';
                              });
                            },
                          ),
                        );
                      }
                      return CategoryCard(context, ctg![index - 1]);
                    },
                    separatorBuilder: (context, index) {
                      return Container();
                    }),
              ),
            );
          },
        );
      },
    );
  }

  Widget CategoryCard(BuildContext context, QueryDocumentSnapshot doc) {
    return Column(children: [
      ListTile(
        title: Text(
          doc['category_title'],
        ),
        onTap: () {
          setState(() {
            Navigator.pop(context);
            Selectcategorytitle = doc['category_title'];
          });
        },
      ),
    ]);
  }
}
