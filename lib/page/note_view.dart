import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_note_example/data/noteProvider.dart';
import 'package:provider_note_example/page/note_edit.dart';
import 'package:provider_note_example/page/note_list.dart';


class NoteViewPage extends StatefulWidget {

  static const routeName = '/view';

  final int index;


  final QueryDocumentSnapshot doc;

  // NoteViewPage(this.index);

  NoteViewPage(this.doc,{Key? key,required this.index}) : super(key: key);

  @override
  State<NoteViewPage> createState() => _NoteViewPageState();
}

class _NoteViewPageState extends State<NoteViewPage> {


  @override
  Widget build(BuildContext context) {

    FirebaseAuth auth = FirebaseAuth.instance;

    final docid = auth.currentUser!.uid;

    // final note = context.read<NoteProvider>().getNote(widget.index);
    final note = FirebaseFirestore.instance.collection('User').doc(docid).collection('Notes').doc(widget.doc.id);

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
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot){
          final Sdd = snapshot.data?.docs;
         // DocumentSnapshot doc = docdata?.length > 1 ? docdata[widget.index] : null;
          final Sddlength = Sdd?.length ?? 0;
          final noteTitle = Sddlength > 0 ? Sdd![widget.index].get('note_title') : null;
          final noteBody = Sddlength > 0 ? Sdd![widget.index].get('note_body') : null;
          // final doc = Sdd![widget.index];

          return  Scaffold(
            appBar: AppBar(
              foregroundColor: Colors.white,
              title: noteTitle != "" ? Text(noteTitle.toString())
              : Text('제목 없음'),
              // title: Text(note.title),
              centerTitle: true,
              elevation: 0,
              actions: [
                IconButton(
                    onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => NoteEditPage(id: widget.doc.id,)));
                  //     .then((value) {
                  //       setState(() {});
                  // });
                },
                    icon: Icon(Icons.edit)),
                IconButton(
                    onPressed: () {
                      _confirmDelete(widget.doc);
                    },
                    icon: Icon(Icons.delete)),
              ],
            ),
            body: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onDoubleTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => NoteEditPage(id: widget.doc.id,)))
                    .then((value) {setState(() {});
                });
              },
              child: SizedBox.expand(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(noteBody.toString(),
                        style: TextStyle(
                          fontSize: 16,
                        ),),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      ),
    );
  }
  void _confirmDelete(QueryDocumentSnapshot doc) {

    FirebaseAuth auth = FirebaseAuth.instance;

    final docid = auth.currentUser!.uid;

    showDialog(context: context, builder: (context){
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        title: Text('노트 삭제'),
        content: Text('노트를 삭제할까요?'),
        actions: [
          TextButton(
            child: Text('아니오'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(onPressed: (){
            FirebaseFirestore.instance.collection('User').doc(docid).collection('Notes').doc(doc.id).delete();
            Navigator.push(context, MaterialPageRoute(builder: (context) => NoteListPage()));
            // Navigator.popUntil(context, (route) => route.isFirst);
          }, child: Text('예'),)
        ],
      );
    },);
  }
}
