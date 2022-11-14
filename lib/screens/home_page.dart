import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../global.dart';
import '../helpers/cloud_firestore_helper.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<FormState> insertRecordFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> updateRecordFormKey = GlobalKey<FormState>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  final TextEditingController updateTitleController = TextEditingController();
  final TextEditingController updateNoteController = TextEditingController();

  String? title;
  String? note;
  String? time;

  String? updateTitle;
  String? updateNote;
  String? updateTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Note Keeper"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Center(child: Text("ADD NEW NOTE")),
                  content: Form(
                    key: insertRecordFormKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                            controller: titleController,
                            onSaved: (val) {
                              title = val;
                            },
                            validator: (val) =>
                                (val!.isEmpty) ? "Please enter title" : null,
                            decoration: const InputDecoration(
                              labelText: "Title",
                            )),
                        const SizedBox(height: 8),
                        TextFormField(
                            controller: noteController,
                            onSaved: (val) {
                              note = val;
                            },
                            validator: (val) =>
                                (val!.isEmpty) ? "Please enter note" : null,
                            decoration: const InputDecoration(
                              labelText: "Note",
                            )),
                        const SizedBox(height: 14),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                  actions: [
                    OutlinedButton(
                        onPressed: () {
                          titleController.clear();
                          noteController.clear();

                          setState(() {
                            title = null;
                            note = null;
                            time = null;
                          });

                          Navigator.of(context).pop();
                        },
                        child: const Text("Cancel")),
                    ElevatedButton(
                        onPressed: () async {
                          if (insertRecordFormKey.currentState!.validate()) {
                            insertRecordFormKey.currentState!.save();
                            time =
                                "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year} ${DateTime.now().hour}:${DateTime.now().minute}";

                            await CloudFireStoreHelper.cloudFireStoreHelper
                                .insertRecord(
                              id: Global.currentNoteId!,
                              title: title!,
                              note: note!,
                              time: time!,
                            );

                            titleController.clear();
                            noteController.clear();

                            setState(() {
                              title = null;
                              note = null;
                              time = null;
                            });

                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text("Add Note")),
                  ],
                );
              });
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: CloudFireStoreHelper.cloudFireStoreHelper.selectRecord(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("Error:${snapshot.error}"),
            );
          } else if (snapshot.hasData) {
            QuerySnapshot? documents = snapshot.data;

            List<QueryDocumentSnapshot> data = documents!.docs;

            if (data.isEmpty) {
              Global.currentNoteId = '1';
              return Center(
                child: Text(
                  "No Notes Yet...",
                  style: GoogleFonts.ubuntu(
                    fontSize: 24,
                  ),
                ),
              );
            } else {
              int noteId = int.parse(data.last.id);
              noteId++;
              Global.currentNoteId = noteId.toString();

              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: data.length,
                itemBuilder: (context, i) {
                  return Slidable(
                    endActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  updateTitleController.text = data[i]['title'];
                                  updateNoteController.text = data[i]['note'];

                                  return AlertDialog(
                                    title: const Center(
                                      child: Text("Update Record"),
                                    ),
                                    content: Form(
                                      key: updateRecordFormKey,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextFormField(
                                            controller: updateTitleController,
                                            decoration: const InputDecoration(
                                                labelText: 'Title',
                                                hintText:
                                                    'Enter Your new title here'),
                                            onSaved: (val) {
                                              updateTitle = val!;
                                            },
                                            validator: (val) => (val!.isEmpty)
                                                ? 'Please enter your title...'
                                                : null,
                                          ),
                                          const SizedBox(height: 8),
                                          TextFormField(
                                            controller: updateNoteController,
                                            decoration: const InputDecoration(
                                                labelText: 'Note',
                                                hintText:
                                                    'Enter Your new note here'),
                                            onSaved: (val) {
                                              updateNote = val!;
                                            },
                                            validator: (val) => (val!.isEmpty)
                                                ? 'Please enter your note...'
                                                : null,
                                          ),
                                          const SizedBox(height: 8),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      ElevatedButton(
                                          onPressed: () async {
                                            if (updateRecordFormKey
                                                .currentState!
                                                .validate()) {
                                              updateRecordFormKey.currentState!
                                                  .save();

                                              updateTime =
                                                  "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year} ${DateTime.now().hour}:${DateTime.now().minute}";

                                              await CloudFireStoreHelper
                                                  .cloudFireStoreHelper
                                                  .updateRecord(
                                                      id: data[i].id,
                                                      title: updateTitle!,
                                                      note: updateNote!,
                                                      time: updateTime!);

                                              updateTitleController.clear();
                                              updateNoteController.clear();

                                              setState(() {
                                                updateTitle = null;
                                                updateNote = null;
                                                updateTime = null;
                                              });

                                              Navigator.of(context).pop();
                                            }
                                          },
                                          child: const Text("Update Note")),
                                      OutlinedButton(
                                          onPressed: () {
                                            updateTitleController.clear();
                                            updateNoteController.clear();

                                            setState(() {
                                              updateTitle = null;
                                              updateNote = null;
                                              updateTime = null;
                                            });

                                            Navigator.of(context).pop();
                                          },
                                          child: const Text("Cancel")),
                                    ],
                                  );
                                });
                          },
                          icon: Icons.edit,
                          backgroundColor: Colors.green,
                        ),
                        SlidableAction(
                          onPressed: (context) async {
                            await CloudFireStoreHelper.cloudFireStoreHelper
                                .deleteRecord(id: data[i].id);
                          },
                          icon: Icons.delete,
                          backgroundColor: Colors.red,
                        ),
                      ],
                    ),
                    child: Card(
                      child: ListTile(
                        leading: Text(data[i].id),
                        title: Text("${data[i]['title']}"),
                        subtitle: Text("${data[i]['note']}"),
                        trailing: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("${data[i]['time'].split(' ')[0]}"),
                            Text("${data[i]['time'].split(' ').last}"),
                          ],
                        ),
                        //isThreeLine: true,
                      ),
                    ),
                  );
                },
              );
            }
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
