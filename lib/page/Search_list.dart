import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_note_example/data/noteProvider.dart';
import 'package:provider_note_example/page/note_list.dart';
import 'package:provider_note_example/page/note_view.dart';

class SearchListPage extends StatefulWidget {
  int? index;

  SearchListPage({Key? key}) : super(key: key);

  @override
  State<SearchListPage> createState() => _SearchListPageState();
}

class _SearchListPageState extends State<SearchListPage> {
  final categorycontroller = TextEditingController();

  bool Categoryedit = false;

  String note_title = "";

  String note_body = "";

  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;

    final docid = auth.currentUser!.uid;

    final buttonbool2 = context.read<NoteProvider>().getViewButton;

    return SafeArea(
      child: StreamBuilder<QuerySnapshot>(
          stream:  buttonbool2 != true ? FirebaseFirestore.instance.collection('User').doc(docid)
              .collection('Notes').orderBy(
              'note_time', descending: false)
              .snapshots() : FirebaseFirestore.instance.collection('User').doc(docid)
              .collection('Notes').orderBy(
              'note_time', descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            final FireNotes = FirebaseFirestore.instance
                .collection('User')
                .doc(docid)
                .collection('Notes');
            final notes = snapshot.data?.docs;
            final noteslength = notes?.length ?? 0;
            final wherenote = notes
                ?.where((element) => element.get('note_isSelected') == true);
            final wherenotelength = wherenote?.length ?? 0;
            return Consumer(
              builder: (context, NoteProvider data, child) {
                return WillPopScope(
                  onWillPop: data.getSelectedButton == false ? () async {
                    wherenote!.forEach((QueryDocumentSnapshot doc) {
                      FireNotes.doc(doc.id).update({
                        'note_isSelected': false,
                      });
                    });

                    return true;
                  }
                  : () async {
                    data.Buttonfalse();
                    wherenote!.forEach((QueryDocumentSnapshot doc) {
                      FireNotes.doc(doc.id).update({
                        'note_isSelected': false,
                      });
                    });

                    return false;
                  },
                  child: Scaffold(
                    appBar: AppBar(
                      elevation: 0,
                      title: TextField(
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            hintText: '검색'),
                        onChanged: (val) {
                          setState(() {
                            note_title = val;
                            note_body = val;
                          });
                        },
                      ),
                    ),

                    body: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('Buttonbool')
                            .snapshots(),
                        builder: (context, AsyncSnapshot bsnapshot) {
                          final buttonbool = bsnapshot.data?.docs[0].get('bool');
                          return Consumer<NoteProvider>(
                            builder: (context, NoteProvider data, child) {
                              return Column(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding:
                                      const EdgeInsets.fromLTRB(10, 4, 10, 0),
                                      child: ListView.builder(
                                          itemCount: noteslength,
                                          itemBuilder: (context, index) {
                                            final Is = data.getSelectedButton;
                                            // var data = snapshot.data?.docs[index].data();
                                            //     as Map<String, dynamic>;
                                            final Data = noteslength > 0
                                                ? snapshot.data?.docs[index]
                                                : null;
                                            if (note_title.isEmpty) {
                                              return Is != true
                                                  ? BuildCard(context,
                                                  notes![index], false, index)
                                                  : SelectBuildCard(context,
                                                  notes![index], false, index);
                                            }
                                            if (Data!['note_title']
                                                .toString()
                                                .toLowerCase()
                                                .contains(
                                                note_title.toLowerCase())) {
                                              return  Is != true
                                                  ? SearchCard(context,
                                                  notes![index], false, index)
                                                  : SelectSearchCard(context,
                                                  notes![index], false, index);
                                            }
                                            if (Data['note_body']
                                                .toString()
                                                .toLowerCase()
                                                .contains(
                                                note_body.toLowerCase())) {
                                              return  Is != true
                                                  ? SearchCard(context,
                                                  notes![index], false, index)
                                                  : SelectSearchCard(context,
                                                  notes![index], false, index);
                                            }
                                            return Container();
                                          }),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        }),
                    bottomNavigationBar: data.getSelectedButton != true ? null : BottomAppBar(
                      child: Container(
                        height: 60,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              // crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MaterialButton(
                                  onPressed: () {
                                    wherenotelength == 0
                                        ? null
                                        : _confirmDelete(snapshot);
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.delete,
                                      ),
                                      Text(
                                        '삭제',
                                      ),
                                    ],
                                  ),
                                ),
                                MaterialButton(
                                  onPressed: () {
                                    wherenotelength == noteslength
                                        ? notes!.forEach((doc) {
                                      FirebaseFirestore.instance
                                          .collection('User')
                                          .doc(docid)
                                          .collection('Notes')
                                          .doc(doc.id)
                                          .update({
                                        'note_isSelected': false,
                                      });
                                    })
                                        : notes!.forEach((doc) {
                                      FirebaseFirestore.instance
                                          .collection('User')
                                          .doc(docid)
                                          .collection('Notes')
                                          .doc(doc.id)
                                          .update({
                                        'note_isSelected': true,
                                      });
                                    });
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      wherenotelength == noteslength
                                          ? Icon(
                                        Icons.check_circle,
                                        color: Colors.white,
                                      )
                                          : Icon(Icons.circle_outlined),
                                      wherenotelength == noteslength
                                          ? Text('선택 해제')
                                          : Text('전체 선택'),
                                    ],
                                  ),
                                ),
                                MaterialButton(
                                  onPressed: () {
                                    _displayCategoryMoveDialog();
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.arrow_right_alt,
                                      ),
                                      Text('이동'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },

            );
          }),
    );
  }
  void _confirmDelete(AsyncSnapshot<QuerySnapshot> snapshot) {
    FirebaseAuth auth = FirebaseAuth.instance;

    final docid = auth.currentUser!.uid;

    final Snote = snapshot.data!.docs
        .where((element) => element.get('note_isSelected') == true);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          title: Text('노트 삭제'),
          content: Text('노트를 ${Snote.length}개 삭제할까요?'),
          actions: [
            TextButton(
              child: Text('아니오'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              onPressed: () {
                Snote.forEach((doc) {
                  FirebaseFirestore.instance
                      .collection('User')
                      .doc(docid)
                      .collection('Notes')
                      .doc(doc.id)
                      .delete();
                });
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => NoteListPage()));
              },
              child: Text('예'),
            )
          ],
        );
      },
    );
  }

  void _displayCategoryMoveDialog() {
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
                            },
                          ),
                        );
                      }
                      return CategoryCard(ctg![index - 1]);
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

  Widget CategoryCard(
      QueryDocumentSnapshot doc,
      ) {
    String Ctitle = doc['category_title'];

    return Column(children: [
      ListTile(
        title: Text(
          Ctitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) {
              FirebaseAuth auth = FirebaseAuth.instance;

              final docid = auth.currentUser!.uid;

              return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('User')
                      .doc(docid)
                      .collection('Notes')
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    final Snote = snapshot.data?.docs.where(
                            (element) => element.get('note_isSelected') == true);
                    final Snotelength = Snote?.length ?? 0;
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      title: Text('${Ctitle} 카테고리로 이동'),
                      content: Text('선택된 카테고리로 노트${Snotelength}개를 이동할까요?'),
                      actions: [
                        TextButton(
                          child: Text('아니오'),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        TextButton(
                          onPressed: () {
                            Snote!.forEach((doc) {
                              FirebaseFirestore.instance
                                  .collection('User')
                                  .doc(docid)
                                  .collection('Notes')
                                  .doc(doc.id)
                                  .update({
                                'note_category': Ctitle,
                              });
                              FirebaseFirestore.instance
                                  .collection('User')
                                  .doc(docid)
                                  .collection('Notes')
                                  .doc(doc.id)
                                  .update({
                                'note_isSelected': false,
                              });
                            });
                            context.read<NoteProvider>().Buttonfalse();
                            Navigator.popUntil(
                                context, (route) => route.isFirst);
                          },
                          child: Text('예'),
                        )
                      ],
                    );
                  });
            },
          );
        },
      ),
    ]);
  }
}


Widget BuildCard(
  BuildContext context,
  QueryDocumentSnapshot doc,
  bool isSelected,
  int index,
) {
  FirebaseAuth auth = FirebaseAuth.instance;

  final docid = auth.currentUser!.uid;

  final upbool = FirebaseFirestore.instance
      .collection('User')
      .doc(docid)
      .collection('Notes')
      .doc(doc.id);
  return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('User')
          .doc(docid)
          .collection('Notes')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        final noteIs = doc.get('note_isSelected');
        final updoc = FirebaseFirestore.instance
            .collection('User')
            .doc(docid)
            .collection('Notes')
            .doc(doc.id);
        return Consumer(
          builder: (context, NoteProvider data, child) {
            return Column(
              children: [
                Card(
                  // color: note.color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    title: doc['note_title'] != ""
                        ? Text(
                            doc['note_title'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : Text(
                            '제목 없음',
                            maxLines: 1,
                          ),
                    subtitle: Text(
                      doc['note_body'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onLongPress: () {
                      data.ButtonChange();
                      upbool.update({'note_isSelected': true});
                    },
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                NoteViewPage(index: index, doc)),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      });
}

Widget SelectBuildCard(
  BuildContext context,
  QueryDocumentSnapshot doc,
  bool isSelected,
  int index,
) {
  FirebaseAuth auth = FirebaseAuth.instance;

  final docid = auth.currentUser!.uid;

  final upbool = FirebaseFirestore.instance
      .collection('User')
      .doc(docid)
      .collection('Notes')
      .doc(doc.id);
  return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('User')
          .doc(docid)
          .collection('Notes')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        final noteIs = doc.get('note_isSelected');
        final updoc = FirebaseFirestore.instance
            .collection('User')
            .doc(docid)
            .collection('Notes')
            .doc(doc.id);
        return Consumer(
          builder: (context, NoteProvider data, child) {
            final Is = data.getSelectedButton;
            return Column(
              children: [
                Card(
                  // color: note.color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ListTile(
                    leading: noteIs == true
                        ? Icon(
                            Icons.check_circle,
                            color: Colors.white,
                          )
                        : Icon(
                            Icons.circle_outlined,
                          ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    title: doc['note_title'] != ""
                        ? Text(
                            doc['note_title'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : Text(
                            '제목 없음',
                            maxLines: 1,
                          ),
                    subtitle: Text(
                      doc['note_body'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onLongPress: () {
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => SelectListPage(
                      //           index: index,
                      //           isSelected: isSelected,
                      //         )));
                    },
                    onTap: () {
                      if (noteIs == true) {
                        updoc.update({
                          'note_isSelected': false,
                        });
                      } else if (noteIs == false) {
                        updoc.update({
                          'note_isSelected': true,
                        });
                      }
                    },
                  ),
                ),
              ],
            );
          },
        );
      });
}

Widget SearchCard(
  BuildContext context,
  QueryDocumentSnapshot doc,
  bool isSelected,
  int index,
) {
  FirebaseAuth auth = FirebaseAuth.instance;

  final docid = auth.currentUser!.uid;

  final upbool = FirebaseFirestore.instance
      .collection('User')
      .doc(docid)
      .collection('Notes')
      .doc(doc.id);

  final buttonbool2 = context.read<NoteProvider>().getViewButton;

  return StreamBuilder(
    stream: buttonbool2 != true ? FirebaseFirestore.instance.collection('User').doc(docid)
      .collection('Notes').orderBy(
      'note_time', descending: false)
      .snapshots() : FirebaseFirestore.instance.collection('User').doc(docid)
      .collection('Notes').orderBy(
        'note_time', descending: true)
      .snapshots(),
    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
      final notes = snapshot.data?.docs;
      final noteslength = notes?.length ?? 0;
      var Notetitle =
          noteslength > 0 ? snapshot.data?.docs[index].get('note_title') : null;
      var Notebody =
          noteslength > 0 ? snapshot.data?.docs[index].get('note_body') : null;
      return Column(
        children: [
          Card(
            // color: note.color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              title: Notetitle != ""
                  ? Text(
                      Notetitle.toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  : Text(
                      '제목 없음',
                      maxLines: 1,
                    ),
              subtitle: Text(
                Notebody.toString(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onLongPress: () {
                context.read<NoteProvider>().ButtonChange();
                upbool.update({'note_isSelected': true});
              },
              onTap: () {
                // Navigator.pushNamed(context, NoteViewPage.routeName, arguments: index);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NoteViewPage(index: index, doc)),
                );
              },
            ),
          ),
        ],
      );
    },
  );
}
Widget SelectSearchCard(
    BuildContext context,
    QueryDocumentSnapshot doc,
    bool isSelected,
    int index,
    ) {
  FirebaseAuth auth = FirebaseAuth.instance;

  final docid = auth.currentUser!.uid;

  final upbool = FirebaseFirestore.instance
      .collection('User')
      .doc(docid)
      .collection('Notes')
      .doc(doc.id);
  return StreamBuilder(
    stream: FirebaseFirestore.instance
        .collection('User')
        .doc(docid)
        .collection('Notes')
        .orderBy('note_time', descending: false)
        .snapshots(),
    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
      final Is = context.read<NoteProvider>().getSelectedButton;
      final noteIs = doc.get('note_isSelected');
      final updoc = FirebaseFirestore.instance
          .collection('User')
          .doc(docid)
          .collection('Notes')
          .doc(doc.id);
      final notes = snapshot.data?.docs;
      final noteslength = notes?.length ?? 0;
      var Notetitle =
      noteslength > 0 ? snapshot.data?.docs[index].get('note_title') : null;
      var Notebody =
      noteslength > 0 ? snapshot.data?.docs[index].get('note_body') : null;
      return Column(
        children: [
          Card(
            // color: note.color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              leading: noteIs == true
                  ? Icon(
                Icons.check_circle,
                color: Colors.white,
              )
                  : Icon(
                Icons.circle_outlined,
              ),
              title: Notetitle != ""
                  ? Text(
                Notetitle.toString(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
                  : Text(
                '제목 없음',
                maxLines: 1,
              ),
              subtitle: Text(
                Notebody.toString(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onLongPress: () {
              },
              onTap: () {
                if (noteIs == true) {
                  updoc.update({
                    'note_isSelected': false,
                  });
                } else if (noteIs == false) {
                  updoc.update({
                    'note_isSelected': true,
                  });
                }
              },
            ),
          ),
        ],
      );
    },
  );
}

