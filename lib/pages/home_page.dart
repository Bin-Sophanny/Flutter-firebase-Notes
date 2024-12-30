import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebasecrud/services/firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController textController = TextEditingController();

  void openNoteBox({String? docID, String? initialText}) {
  // Set the initial text of the controller
  textController.text = initialText ?? '';

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(docID == null ? 'Add Note' : 'Edit Note'),
      content: TextField(
        controller: textController,
        decoration: const InputDecoration(hintText: 'Enter your note here'),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            if (textController.text.trim().isNotEmpty) {
              if (docID == null) {
                firestoreService.addNote(textController.text.trim());
              } else {
                firestoreService.updateNotes(docID, textController.text.trim());
              }
              textController.clear();
              Navigator.pop(context);
            } else {
              // Show a warning if the note is empty.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Note cannot be empty')),
              );
            }
          },
          child: Text(docID == null ? 'Add' : 'Update'),
        ),
        TextButton(
          onPressed: () {
            textController.clear();
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
      ],
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openNoteBox(),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getNotes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            List noteList = snapshot.data!.docs;

            return ListView.builder(
              itemCount: noteList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = noteList[index];
                String docID = document.id;
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                String noteText = data['note'];

                return ListTile(
                  title: Text(noteText),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => openNoteBox(docID: docID, initialText: noteText),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          firestoreService.deleteNotes(docID);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Note deleted')),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text("No notes available"));
          }
        },
      ),
    );
  }
}
