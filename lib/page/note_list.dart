import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_note_example/data/noteProvider.dart';
import 'package:provider_note_example/page/Search_list.dart';
import 'package:provider_note_example/page/category_manager.dart';
import 'package:provider_note_example/page/categorylist_note_view.dart';
import 'package:provider_note_example/page/note_edit.dart';
import 'package:provider_note_example/page/note_view.dart';

class NoteListPage extends StatefulWidget {
  int? index;

  NoteListPage({Key? key}) : super(key: key);

  @override
  State<NoteListPage> createState() => _NoteListPageState();
}

class _NoteListPageState extends State<NoteListPage> {
  final categorycontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;

    final docid = auth.currentUser!.uid;

    final buttonbool2 = context.read<NoteProvider>().getViewButton;

    return StreamBuilder<QuerySnapshot>(
        stream: buttonbool2 != true
            ? FirebaseFirestore.instance
                .collection('User')
                .doc(docid)
                .collection('Notes')
                .orderBy('note_time', descending: false)
                .snapshots()
            : FirebaseFirestore.instance
                .collection('User')
                .doc(docid)
                .collection('Notes')
                .orderBy('note_time', descending: true)
                .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> nsnapshot) {
          final FireNotes = FirebaseFirestore.instance
              .collection('User')
              .doc(docid)
              .collection('Notes');
          final notes = nsnapshot.data?.docs;
          final wherenote =
              notes?.where((element) => element.get('note_isSelected') == true);
          final noteslength = notes?.length ?? 0;
          final wherenotelength = wherenote?.length ?? 0;
          FirebaseAuth auth = FirebaseAuth.instance;
          return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Buttonbool')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                final buttonbool = snapshot.data?.docs[0].get('bool');
                return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('User')
                        .doc(docid)
                        .collection('Category')
                        .where('category_isSelected', isEqualTo: true)
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      final ctgt = snapshot.data?.docs;
                      final Cname =
                          ctgt?.length == 1 ? ctgt![0]['category_title'] : null;
                      final Cnotes = notes
                          ?.where((element) =>
                              element.get('note_category') == Cname)
                          .toList();
                      final Cnoteslength = Cnotes?.length ?? 0;
                      final ctgtlenghth = ctgt?.length ?? 0;
                      final whereCnote = snapshot.data?.docs.where((element) =>
                          element.get('category_isSelected') == true);
                      return WillPopScope(
                        onWillPop: context
                                    .read<NoteProvider>()
                                    .getSelectedButton ==
                                false
                            ? () async {
                                wherenote!.forEach((QueryDocumentSnapshot doc) {
                                  FireNotes.doc(doc.id).update({
                                    'note_isSelected': false,
                                  });
                                });

                                return true;
                              }
                            : () async {
                                context.read<NoteProvider>().Buttonfalse();
                                wherenote!.forEach((QueryDocumentSnapshot doc) {
                                  FireNotes.doc(doc.id).update({
                                    'note_isSelected': false,
                                  });
                                });

                                return false;
                              },
                        child: SafeArea(
                          child: Scaffold(
                            appBar: AppBar(
                              title: context
                                          .read<NoteProvider>()
                                          .getSelectedButton !=
                                      true
                                  ? ctgtlenghth == 1
                                      ? Text(Cname.toString())
                                      : Text('Note')
                                  : Text(wherenotelength < 1
                                      ? 'Note'
                                      : '선택된 노트${wherenotelength}개'),
                              centerTitle: true,
                              elevation: 0.0,
                              actions: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    PopupMenuButton(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15)),
                                        ),
                                        itemBuilder: (context) {
                                          return [
                                            PopupMenuItem(
                                              onTap: () async {
                                                if (buttonbool == true) {
                                                  FirebaseFirestore.instance
                                                      .collection('Buttonbool')
                                                      .doc('buttonbool')
                                                      .update({
                                                    'bool': false,
                                                  });
                                                }
                                                if (buttonbool == false) {
                                                  FirebaseFirestore.instance
                                                      .collection('Buttonbool')
                                                      .doc('buttonbool')
                                                      .update({
                                                    'bool': true,
                                                  });
                                                }
                                              },
                                              child: buttonbool != true
                                                  ? Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Icon(Icons.list),
                                                        Container(width: 15),
                                                        Text(
                                                          '리스트로 보기',
                                                        ),
                                                      ],
                                                    )
                                                  : Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Icon(Icons.grid_view),
                                                        Container(width: 15),
                                                        Text(
                                                          '크게 보기',
                                                        ),
                                                      ],
                                                    ),
                                            ),
                                            PopupMenuItem(
                                              onTap: () async {
                                                if (buttonbool2 == true) {
                                                  context
                                                      .read<NoteProvider>()
                                                      .ViewButtonfalse();
                                                }
                                                if (buttonbool2 == false) {
                                                  context
                                                      .read<NoteProvider>()
                                                      .ViewButtonChange();
                                                }
                                              },
                                              child: buttonbool2 != true
                                                  ? Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Icon(Icons
                                                            .arrow_downward),
                                                        Container(width: 15),
                                                        Text(
                                                          '내림차순 보기',
                                                        ),
                                                      ],
                                                    )
                                                  : Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Icon(
                                                            Icons.arrow_upward),
                                                        Container(width: 15),
                                                        Text(
                                                          '오름차순 보기',
                                                        ),
                                                      ],
                                                    ),
                                            ),
                                          ];
                                        }),
                                  ],
                                ),
                                IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SearchListPage()));
                                      context
                                          .read<NoteProvider>()
                                          .Buttonfalse();
                                    },
                                    icon: Icon(Icons.search)),
                                // IconButton(
                                //     onPressed: () {
                                //       if(auth.currentUser != null) {
                                //         print(auth.currentUser!.uid);
                                //       }
                                //     },
                                //     icon: Icon(Icons.abc)),
                              ],
                              leading: context
                                          .read<NoteProvider>()
                                          .getSelectedButton ==
                                      true
                                  ? IconButton(
                                      onPressed: () {
                                        context
                                            .read<NoteProvider>()
                                            .Buttonfalse();
                                        wherenote!.forEach(
                                            (QueryDocumentSnapshot doc) {
                                          FireNotes.doc(doc.id).update({
                                            'note_isSelected': false,
                                          });
                                        });
                                      },
                                      icon: Icon(Icons.arrow_back))
                                  : null,
                            ),
                            drawer: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('User')
                                  .doc(docid)
                                  .collection('Category')
                                  .orderBy('category_time', descending: false)
                                  .snapshots(),
                              builder: (context,
                                  AsyncSnapshot<QuerySnapshot> snapshot) {
                                final ctg = snapshot.data?.docs;
                                final ctglenght = ctg?.length ?? 0;
                                return StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('User')
                                        .snapshots(),
                                    builder: (context,
                                        AsyncSnapshot<QuerySnapshot> snapshot) {
                                      final useremail = auth.currentUser!.email;
                                      final nameindex = snapshot.data?.docs
                                          .indexWhere((element) =>
                                              element.get('user_id') ==
                                              useremail);
                                      final username = snapshot
                                          .data?.docs[nameindex!]
                                          .get('user_name');
                                      return Drawer(
                                        elevation: 0,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            UserAccountsDrawerHeader(
                                                otherAccountsPictures: [
                                                  IconButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      icon: Icon(
                                                        Icons.settings,
                                                        color: Colors.white,
                                                      )),
                                                ],
                                                currentAccountPicture:
                                                    CircleAvatar(
                                                        backgroundColor:
                                                            Colors.grey[850],
                                                        child: FittedBox(
                                                          child: Icon(
                                                            Icons
                                                                .account_circle,
                                                            color: Colors.white,
                                                            size: 80,
                                                          ),
                                                        )),
                                                accountName:
                                                    Text(username.toString()),
                                                // accountName: Text(FirebaseAuth.instance.currentUser!.displayName!),
                                                accountEmail: Text(useremail!)),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              CategoryManager()));
                                                },
                                                child: Text('카테고리 관리'),
                                              ),
                                            ),
                                            Expanded(
                                              child: ListView.separated(
                                                itemCount: ctglenght + 1,
                                                itemBuilder: (context, index) {
                                                  if (index == 0 ||
                                                      index == ctglenght + 1) {
                                                    return Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 6.0),
                                                      child: SizedBox(
                                                        child: Column(
                                                          children: [
                                                            InkWell(
                                                              child: ListTile(
                                                                  title: ctgtlenghth ==
                                                                          1
                                                                      ? Text(
                                                                          'All',
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.grey[500],
                                                                          ),
                                                                        )
                                                                      : Text(
                                                                          'All',
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                          ))),
                                                              onTap: () {
                                                                whereCnote!
                                                                    .forEach(
                                                                        (element) {
                                                                  FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          'User')
                                                                      .doc(
                                                                          docid)
                                                                      .collection(
                                                                          'Category')
                                                                      .doc(element
                                                                          .id)
                                                                      .update({
                                                                    'category_isSelected':
                                                                        false,
                                                                  });
                                                                });
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                            ),
                                                            Container(
                                                              height: 1,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                  return CategoryCard(context,
                                                      ctg![index - 1], index);
                                                },
                                                separatorBuilder:
                                                    (context, index) {
                                                  return Container();
                                                },
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      8, 0, 8, 6),
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  FirebaseAuth.instance
                                                      .signOut();
                                                  Navigator.popUntil(context,
                                                      (route) => route.isFirst);
                                                },
                                                child: Text('로그아웃'),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    });
                              },
                            ),
                            body: StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('User')
                                    .doc(docid)
                                    .collection('Category')
                                    .where('category_isSelected',
                                        isEqualTo: true)
                                    .snapshots(),
                                builder: (context,
                                    AsyncSnapshot<QuerySnapshot> snapshot) {
                                  return Consumer<NoteProvider>(
                                    builder:
                                        (context, NoteProvider data, child) {
                                      return ctgtlenghth == 1
                                          ? buttonbool == true
                                              ? Cnoteslength != 0
                                                  ? Categorylistbuild(
                                                      Cnotes!, ctgtlenghth)
                                                  : Center(
                                                      child: Text('노트를 추가하세요'),
                                                    )
                                              : Cnoteslength != 0
                                                  ? CategoryListgridbuild(
                                                      Cnotes!, ctgtlenghth)
                                                  : Center(
                                                      child: Text('노트를 추가하세요'),
                                                    )
                                          : buttonbool == true
                                              ? noteslength != 0
                                                  ? listbuild(
                                                      notes!, noteslength)
                                                  : Center(
                                                      child: Text('노트를 추가하세요'),
                                                    )
                                              : noteslength != 0
                                                  ? gridbuild(
                                                      notes!, noteslength)
                                                  : Center(
                                                      child: Text('노트를 추가하세요'),
                                                    );
                                    },
                                  );
                                }),
                            // body: Consumer<NoteProvider>(
                            //   builder: (context, NoteProvider data, child){
                            //     return data.listNote.length !=0 ? ListView.builder(
                            //       itemCount: data.listNote.length,
                            //         itemBuilder: (context, index) => CardList(data.listNote[index], index,false,),
                            //     ): Center(child: Text('노트를 추가하세요'),);
                            //   },
                            // ),
                            bottomNavigationBar: context
                                        .read<NoteProvider>()
                                        .getSelectedButton ==
                                    false
                                ? null
                                : BottomAppBar(
                                    child: Container(
                                      height: 60,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Row(
                                            // crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              MaterialButton(
                                                onPressed: () {
                                                  wherenotelength == 0
                                                      ? null
                                                      : _confirmDelete(
                                                          nsnapshot, context);
                                                },
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
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
                                                          FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'User')
                                                              .doc(docid)
                                                              .collection(
                                                                  'Notes')
                                                              .doc(doc.id)
                                                              .update({
                                                            'note_isSelected':
                                                                false,
                                                          });
                                                        })
                                                      : notes!.forEach((doc) {
                                                          FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'User')
                                                              .doc(docid)
                                                              .collection(
                                                                  'Notes')
                                                              .doc(doc.id)
                                                              .update({
                                                            'note_isSelected':
                                                                true,
                                                          });
                                                        });
                                                },
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    wherenotelength ==
                                                            noteslength
                                                        ? Icon(
                                                            Icons.check_circle,
                                                            color: Colors.white,
                                                          )
                                                        : Icon(Icons
                                                            .circle_outlined),
                                                    wherenotelength ==
                                                            noteslength
                                                        ? Text('선택 해제')
                                                        : Text('전체 선택'),
                                                  ],
                                                ),
                                              ),
                                              MaterialButton(
                                                onPressed: () {
                                                  _displayCategoryMoveDialog(
                                                      context);
                                                },
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
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
                            floatingActionButton: FloatingActionButton(
                              child: Icon(Icons.add),
                              onPressed: () {
                                final args =
                                    ModalRoute.of(context)!.settings.arguments;
                                final Id = args != null ? args as String : null;

                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => NoteEditPage(
                                              id: Id,
                                            )));
                                // Navigator.pushNamed(context, '/edit');
                              },
                            ),
                          ),
                        ),
                      );
                    });
              });
        });
  }

  Widget gridbuild(List notes, Cnoteslength) {
    return OrientationBuilder(builder: (context, orientation) {
      return GridView.builder(
        padding: EdgeInsets.fromLTRB(10, 4, 10, 0),
        itemCount: notes.length,
        itemBuilder: (context, index) => context
                    .read<NoteProvider>()
                    .getSelectedButton !=
                true
            ? GridBuildCard(context, notes[index], false, index, Cnoteslength)
            : SelectGridBuildCard(context, notes[index], false, index),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: orientation == Orientation.portrait ? 2 : 4,
          childAspectRatio: 1,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
        ),
      );
    });
  }

  Widget listbuild(List notes, Cnoteslength) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 0),
      child: ListView.builder(
          itemCount: notes.length,
          itemBuilder: (context, index) =>
              context.read<NoteProvider>().getSelectedButton != true
                  ? BuildCard(context, notes[index], false, index, Cnoteslength)
                  : SelectBuildCard(
                      context,
                      notes[index],
                      false,
                    )),
    );
  }

  Widget CategoryListgridbuild(List notes, ctgtlength) {
    return OrientationBuilder(builder: (context, orientation) {
      return GridView.builder(
        padding: EdgeInsets.fromLTRB(10, 4, 10, 0),
        itemCount: notes.length,
        itemBuilder: (context, index) =>
            context.read<NoteProvider>().getSelectedButton != true
                ? GridBuildCard(context, notes[index], false, index, ctgtlength)
                : SelectGridBuildCard(context, notes[index], false, index),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: orientation == Orientation.portrait ? 2 : 4,
          childAspectRatio: 1,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
        ),
      );
    });
  }

  Widget Categorylistbuild(List notes, ctgtlength) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 0),
      child: ListView.builder(
          itemCount: notes.length,
          itemBuilder: (context, index) =>
              context.read<NoteProvider>().getSelectedButton != true
                  ? BuildCard(context, notes[index], false, index, ctgtlength)
                  : SelectBuildCard(
                      context,
                      notes[index],
                      false,
                    )),
    );
  }

  Widget CategoryCard(
    BuildContext context,
    QueryDocumentSnapshot doc,
    int index,
  ) {
    final auth = FirebaseAuth.instance;
    final docid = auth.currentUser!.uid;
    final updoc = FirebaseFirestore.instance
        .collection('User')
        .doc(docid)
        .collection('Category')
        .doc(doc.id);
    final Is = doc.get('category_isSelected');
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('User')
            .doc(docid)
            .collection('Category')
            .snapshots(),
        builder: (context, snapshot) {
          final whereCnote = snapshot.data?.docs
              .where((element) => element.get('category_isSelected') == true);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: SizedBox(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Is != true
                          ? Text(
                              doc['category_title'],
                              style: TextStyle(
                                color: Colors.grey[500],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          : Text(
                              doc['category_title'],
                              style: TextStyle(
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                      onTap: () {
                        if (Is == false) {
                          updoc.update({
                            'category_isSelected': true,
                          });
                          whereCnote!.forEach((element) {
                            FirebaseFirestore.instance
                                .collection('User')
                                .doc(docid)
                                .collection('Category')
                                .doc(element.id)
                                .update({
                              'category_isSelected': false,
                            });
                          });
                        }
                        Navigator.pop(context);
                      },
                    ),
                    Container(
                      height: 1,
                      color: Colors.grey,
                    )
                  ]),
            ),
          );
        });
  }
}

Widget BuildCard(BuildContext context, QueryDocumentSnapshot doc,
    bool isSelected, int index, ctgtlength) {
  FirebaseAuth auth = FirebaseAuth.instance;

  final docid = auth.currentUser!.uid;

  final upbool = FirebaseFirestore.instance
      .collection('User')
      .doc(docid)
      .collection('Notes')
      .doc(doc.id);
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
            context.read<NoteProvider>().ButtonChange();
            upbool.update({'note_isSelected': true});
            // Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //         builder: (context) =>
            //             SelectListPage(
            //               index: index,
            //               isSelected: isSelected,
            //             )));
          },
          onTap: () {
            if (ctgtlength == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        CategoryNoteViewPage(index: index, doc)),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => NoteViewPage(index: index, doc)),
              );
            }
          },
        ),
      ),
    ],
  );
}

Widget GridBuildCard(BuildContext context, QueryDocumentSnapshot doc,
    bool isSelected, int index, ctgtlength) {
  FirebaseAuth auth = FirebaseAuth.instance;

  final docid = auth.currentUser!.uid;

  final upbool = FirebaseFirestore.instance
      .collection('User')
      .doc(docid)
      .collection('Notes')
      .doc(doc.id);
  return InkWell(
    borderRadius: BorderRadius.circular(8.0),
    onTap: () {
      if (ctgtlength == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CategoryNoteViewPage(index: index, doc)),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => NoteViewPage(index: index, doc)),
        );
      }
    },
    onLongPress: () {
      context.read<NoteProvider>().ButtonChange();
      upbool.update({'note_isSelected': true});
      // Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //         builder: (context) =>
      //             SelectListPage(
      //               index: index,
      //               isSelected: isSelected,
      //             )));
    },
    child: Card(
      color: Colors.grey[800],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              doc['note_title'] != ""
                  ? Text(
                      doc['note_title'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  : Text(
                      '제목 없음',
                      maxLines: 1,
                    ),
              SizedBox(
                height: 16.0,
              ),
              Expanded(
                child: Text(
                  doc['note_body'],
                  overflow: TextOverflow.fade,
                ),
              ),
            ]),
      ),
    ),
  );
}

// --------------------선택 페이지----------------------------------

void _confirmDelete(
    AsyncSnapshot<QuerySnapshot> snapshot, BuildContext context) {
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
              Navigator.pop(context);
              // if (Snote == true) {
              //   FirebaseFirestore.instance.collection('Notes').doc(doc.id).delete();
              //   Navigator.push(context,
              //       MaterialPageRoute(builder: (context) => NoteListPage()));
              // }
            },
            child: Text('예'),
          )
        ],
      );
    },
  );
}

void _displayCategoryMoveDialog(BuildContext context) {
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
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                          child: ListTile(
                            title: Text('All'),
                          ),
                          onTap: () {},
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
  String Ctitle = doc['category_title'];

  return Column(children: [
    ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
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
                builder: (context, AsyncSnapshot<QuerySnapshot> nsnapshot) {
                  final FireNotes = FirebaseFirestore.instance
                      .collection('User')
                      .doc(docid)
                      .collection('Notes');
                  final notes = nsnapshot.data?.docs;
                  final wherenote = notes?.where(
                      (element) => element.get('note_isSelected') == true);
                  final wherenotelength = wherenote?.length ?? 0;
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    title: Text('${Ctitle} 카테고리로 이동'),
                    content: Text('선택된 카테고리로 노트${wherenotelength}개를 이동할까요?'),
                    actions: [
                      TextButton(
                        child: Text('아니오'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      TextButton(
                        onPressed: () {
                          wherenote!.forEach((doc) {
                            FirebaseFirestore.instance
                                .collection('User')
                                .doc(docid)
                                .collection('Notes')
                                .doc(doc.id)
                                .update({
                              'note_category': Ctitle,
                              'note_isSelected': false,
                            });
                          });
                          context.read<NoteProvider>().Buttonfalse();
                          wherenote!.forEach((QueryDocumentSnapshot doc) {
                            FireNotes.doc(doc.id).update({
                              'note_isSelected': false,
                            });
                          });
                          Navigator.popUntil(context, (route) => route.isFirst);
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

Widget Selectgridbuild(List notes, Cnoteslength) {
  return OrientationBuilder(builder: (context, orientation) {
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(10, 4, 10, 0),
      itemCount: notes.length,
      itemBuilder: (context, index) =>
          GridBuildCard(context, notes[index], false, index, Cnoteslength),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: orientation == Orientation.portrait ? 2 : 4,
        childAspectRatio: 1,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
      ),
    );
  });
}

Widget SelectBuildCard(
    BuildContext context, QueryDocumentSnapshot doc, bool isSelected) {
  FirebaseAuth auth = FirebaseAuth.instance;

  final docid = auth.currentUser!.uid;

  return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('User')
          .doc(docid)
          .collection('Notes')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        final Is = doc.get('note_isSelected');
        final updoc = FirebaseFirestore.instance
            .collection('User')
            .doc(docid)
            .collection('Notes')
            .doc(doc.id);
        return Consumer<NoteProvider>(
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
                    leading: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Is == true
                            ? Icon(
                                Icons.check_circle,
                                color: Colors.white,
                              )
                            : Icon(
                                Icons.circle_outlined,
                                // Icons.check_circle_outline,
                                // color: Colors.black26,
                              ),
                      ],
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
                    onTap: () {
                      if (Is == true) {
                        updoc.update({
                          'note_isSelected': false,
                        });
                      } else if (Is == false) {
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

Widget SelectGridBuildCard(
  BuildContext context,
  QueryDocumentSnapshot doc,
  bool isSelected,
  int index,
) {
  FirebaseAuth auth = FirebaseAuth.instance;

  final docid = auth.currentUser!.uid;

  final Is = doc.get('note_isSelected');
  final updoc = FirebaseFirestore.instance
      .collection('User')
      .doc(docid)
      .collection('Notes')
      .doc(doc.id);

  return InkWell(
    borderRadius: BorderRadius.circular(8.0),
    onTap: () {
      if (Is == true) {
        updoc.update({
          'note_isSelected': false,
        });
      } else if (Is == false) {
        updoc.update({
          'note_isSelected': true,
        });
      }
    },
    onLongPress: () {},
    child: Card(
      color: Colors.grey[800],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Is == true
                  ? Icon(
                      Icons.check_circle,
                      color: Colors.white,
                    )
                  : Icon(
                      Icons.circle_outlined,
                    ),
              SizedBox(
                height: 10,
              ),
              doc['note_title'] != ""
                  ? Text(
                      doc['note_title'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  : Text(
                      '제목 없음',
                      maxLines: 1,
                    ),
              SizedBox(
                height: 16.0,
              ),
              Expanded(
                child: Text(
                  doc['note_body'],
                  overflow: TextOverflow.fade,
                ),
              ),
            ]),
      ),
    ),
  );
}
