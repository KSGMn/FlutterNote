import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_note_example/data/noteProvider.dart';

class CategoryManager extends StatefulWidget {




  CategoryManager({Key? key}) : super(key: key);

  @override
  State<CategoryManager> createState() => _CategoryManagerState();
}

class _CategoryManagerState extends State<CategoryManager> {
  final categorycontroller = TextEditingController();


  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;

    final docid = auth.currentUser!.uid;

    final CollectionReference ref =
    FirebaseFirestore.instance.collection('User').doc(docid).collection(
        'Category');

    return SafeArea(
      child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('User')
              .doc(docid)
              .collection('Category')
              .orderBy('category_time', descending: false)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            final ctg = snapshot.data?.docs;
            final ctglenght = ctg?.length ?? 0;
            final FireCategorys = FirebaseFirestore.instance.collection('User')
                .doc(docid)
                .collection('Category');
            final wherecategory = snapshot.data?.docs.where((element) =>
            element.get('category_isSelected') == true);
            final wherecategorylength = wherecategory?.length;
            final wherecategoryindex = snapshot.data?.docs.indexWhere(
                    (element) => element.get('category_isSelected') == true);
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('User').doc(docid).collection('Notes').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> nsnapshot) {
                final FireNotes = FirebaseFirestore.instance
                    .collection('User')
                    .doc(docid)
                    .collection('Notes');
                final notes = nsnapshot.data?.docs;
                final wherenote = notes
                    ?.where((element) => element.get('note_isSelected') == true);
                return WillPopScope(
                  onWillPop: context.read<NoteProvider>().getSelectedButton == false ? () async {
                    ctg!.forEach((doc) {
                      FirebaseFirestore.instance.collection('User').doc(docid).collection('Category').doc(doc.id).update({
                        'category_isSelected' : false,
                      });
                    });

                    return true;
                  }
                      : () async {
                    context.read<NoteProvider>().Buttonfalse();
                    ctg!.forEach((doc) {
                      FirebaseFirestore.instance.collection('User').doc(docid).collection('Category').doc(doc.id).update({
                        'category_isSelected' : false,
                      });
                    });

                    return false;
                  },
                  child: Scaffold(
                    appBar: AppBar(
                      elevation: 0,
                      title: Text('카테고리 관리'),
                      actions: [
                        IconButton(
                            onPressed: () {
                              categorycontroller.clear();
                              _displayCategoryAdd();
                            },
                            icon: Icon(Icons.add)),
                      ],
                      leading:  context.read<NoteProvider>().getSelectedButton == true ? IconButton(
                          onPressed: (){
                            context.read<NoteProvider>().Buttonfalse();
                            wherecategory!.forEach((element) {
                              FirebaseFirestore.instance.collection('User').doc(docid).collection('Category').doc(element.id).update({
                                'category_isSelected' : false,
                              });
                            });
                          }, icon: Icon(Icons.arrow_back))
                          : null,
                    ),
                    body: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                              itemCount: ctglenght,
                              itemBuilder: (context, index) {
                                return context.read<NoteProvider>().getSelectedButton != true ? CategoryCard(
                                    context, ctg![index], index, snapshot) : SelectCategoryCard(context, ctg![index]);
                              }),
                        ),
                      ],
                    ),
                    bottomNavigationBar: context.read<NoteProvider>().getSelectedButton != true ? null : BottomAppBar(
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
                                    wherecategorylength == 0 ? null : _confirmDelete(snapshot,nsnapshot,context);
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
                                    FirebaseAuth auth = FirebaseAuth.instance;
                                    final docid = auth.currentUser!.uid;
                                    wherecategorylength == ctglenght ?
                                    ctg!.forEach((doc) {
                                      FirebaseFirestore.instance.collection('User').doc(docid).collection('Category').doc(doc.id).update({
                                        'category_isSelected' : false,
                                      });
                                    }) : ctg!.forEach((doc) {
                                      FirebaseFirestore.instance.collection('User').doc(docid).collection('Category').doc(doc.id).update({
                                        'category_isSelected' : true,
                                      });
                                    });
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      wherecategorylength == ctglenght ? Icon(Icons.check_circle,color: Colors.white,) : Icon(Icons.circle_outlined),
                                      wherecategorylength == ctglenght ? Text('선택 해제') : Text('전체 선택'),
                                    ],
                                  ),
                                ),
                                wherecategorylength == 1 ? MaterialButton(
                                  onPressed: () {
                                    categorycontroller.clear();
                                    _displayCategoryUpdate(snapshot,wherecategoryindex!,nsnapshot,ctg);
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.edit,
                                      ),
                                      Text('업데이트'),
                                    ],
                                  ),
                                ) : MaterialButton(
                                  onPressed: null,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.edit,
                                        color: Colors.grey,
                                      ),
                                      Text('업데이트'),
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
              }
            );
          }
      ),
    );
  }

  void _displayCategoryAdd() {
    FocusManager.instance.primaryFocus?.unfocus();
    FirebaseAuth auth = FirebaseAuth.instance;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('카테고리 추가',
            style: TextStyle(fontSize: 13.5),
          ),
          content: TextField(
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: '제목을 입력하세요',
            ),
            maxLines: null,
            controller: categorycontroller,
            keyboardType: TextInputType.multiline,
          ),
          actions: [
            TextButton(
                onPressed: () {
                  FirebaseAuth auth = FirebaseAuth.instance;

                  final docid = auth.currentUser!.uid;

                  final CollectionReference ref =
                  FirebaseFirestore.instance.collection('User')
                      .doc(docid)
                      .collection('Category');

                  ref.add({
                    'category_title': categorycontroller.text,
                    'category_isSelected': false,
                    'category_time': Timestamp.now(),
                    'category_auth': auth.currentUser!.uid,
                  }).whenComplete(() => Navigator.pop(context));
                },
                child: Text('저장')),
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('취소'))
          ],
        );
      },
    );
  }

  Widget CategoryCard(BuildContext context, QueryDocumentSnapshot doc,
      int index, AsyncSnapshot<QuerySnapshot> snapshot) {
    final FireCategorys = FirebaseFirestore.instance.collection('User').doc(
        doc.id).collection('Category');
    FirebaseAuth auth = FirebaseAuth.instance;
    final docid = auth.currentUser!.uid;
    final updoc = FirebaseFirestore.instance.collection('User')
        .doc(docid)
        .collection('Category')
        .doc(doc.id);
    final Is = doc.get('category_isSelected');
    final wherecategory = snapshot.data!.docs.where((element) =>
    element.get('category_isSelected') == true);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: SizedBox(
        child: Column(
            children: [
              ListTile(
                title: Text(
                  doc['category_title'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {},
                onLongPress: () {
                  wherecategory.forEach((QueryDocumentSnapshot doc) {
                    FireCategorys.doc(doc.id).update({
                      'category_isSelected': false,
                    });
                  });
                  updoc.update({
                    'category_isSelected': true,
                  });
                 context.read<NoteProvider>().ButtonChange();
                },
              ),
              Container(
                height: 1,
                color: Colors.grey,
              )
            ]
        ),
      ),
    );
  }


// ------------------------선택 페이지----------------------------------

  void _displayCategoryUpdate(AsyncSnapshot<QuerySnapshot> snapshot, int index,
      AsyncSnapshot<QuerySnapshot> notesnapshot, ctg) {
    final wherecategory = snapshot.data?.docs.where(
            (element) => element.get('category_isSelected') == true);
    FocusManager.instance.primaryFocus?.unfocus();

    final Cname = wherecategory?.toList()[0].get('category_title').toString();

    final wherenotes = notesnapshot.data!.docs.where((element) =>
    element.get('note_category') == Cname);

    FirebaseAuth auth = FirebaseAuth.instance;

    final docid = auth.currentUser!.uid;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          title: Text('카테고리 편집',
            style: TextStyle(fontSize: 13.5),
          ),
          content: TextField(
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: snapshot.data!.docs[index]
                  .get('category_title')
                  .toString(),
            ),
            maxLines: null,
            controller: categorycontroller,
            keyboardType: TextInputType.multiline,
          ),
          actions: [
            TextButton(
                onPressed: () {
                  wherecategory?.forEach((doc) {
                    FirebaseFirestore.instance.collection('User').doc(docid)
                        .collection('Category').doc(doc.id)
                        .update({
                      'category_title': categorycontroller.text,
                    });
                    wherenotes.forEach((doc) {
                      FirebaseFirestore.instance.collection('User').doc(docid)
                          .collection('Notes').doc(doc.id)
                          .update({
                        'note_category': categorycontroller.text,
                      });
                    });
                  });
                  ctg!.forEach((doc) {
                    FirebaseFirestore.instance.collection('User').doc(docid).collection('Category').doc(doc.id).update({
                      'category_isSelected' : false,
                    });
                  });
                  context.read<NoteProvider>().Buttonfalse();
                  Navigator.pop(context);
                },
                child: Text('저장')),
            TextButton(
                onPressed: () {
                  categorycontroller.clear();
                  Navigator.pop(context);
                },
                child: Text('취소'))
          ],
        );
      },
    );
  }


  Widget SelectCategoryCard(BuildContext context, QueryDocumentSnapshot doc) {
    FirebaseAuth auth = FirebaseAuth.instance;
    final docid = auth.currentUser!.uid;
    final updoc = FirebaseFirestore.instance.collection('User')
        .doc(docid)
        .collection('Category')
        .doc(doc.id);
    final Is = doc.get('category_isSelected');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: SizedBox(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Is ? Icon(
                      Icons.check_circle,
                      color: Colors.white,
                    )
                        : Icon(
                      Icons.circle_outlined,
                    ),
                  ],
                ),
                title: Text(
                  doc['category_title'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  if (Is == true) {
                    updoc.update({
                      'category_isSelected': false,
                    });
                  } else if (Is == false) {
                    updoc.update({
                      'category_isSelected': true,
                    });
                  }
                },
                onLongPress: () {

                },
              ),
              Container(
                height: 1,
                color: Colors.grey,
              )
            ]
        ),),
    );
  }


  void _confirmDelete(AsyncSnapshot<QuerySnapshot> snapshot,
      AsyncSnapshot<QuerySnapshot> notesnapshot, context) {
    final wherecategory = snapshot.data!.docs.where((element) =>
    element.get('category_isSelected') == true);

    final Cname = wherecategory.toList()[0].get('category_title').toString();


    final wherenotes = notesnapshot.data!.docs.where((element) =>
    element.get('note_category') == Cname);


    final Csnote = snapshot.data!.docs.where((element) =>
    element.get('category_isSelected') == true);

    FirebaseAuth auth = FirebaseAuth.instance;

    final docid = auth.currentUser!.uid;

    final ctg = snapshot.data?.docs;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          title: Text('카테고리 삭제'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('하위 노트도 삭제됩니다.'),
              SizedBox(
                height: 16,
              ),
              Text('카테고리를 ${Csnote.length}개 삭제할까요?')
            ],
          ),
          actions: [
            TextButton(
              child: Text('아니오'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              onPressed: () {
                Csnote.forEach((doc) {
                  FirebaseFirestore.instance.collection('User').doc(docid)
                      .collection('Category').doc(doc.id)
                      .delete();
                });
                wherenotes.forEach((doc) {
                  FirebaseFirestore.instance.collection('User').doc(docid)
                      .collection('Notes').doc(doc.id)
                      .delete();
                });
                Navigator.pop(context);
              },
              child: Text('예'),
            )
          ],
        );
      },
    );
  }
}

