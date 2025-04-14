import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final TextEditingController _controller = TextEditingController();
  final Box<String> notesBox = Hive.box<String>('notes');

  void _addNote() {
    if (_controller.text.isNotEmpty) {
      notesBox.add(_controller.text);
      _controller.clear();
    }
  }

  void _editNoteDialog(int index) {
    _controller.text = notesBox.getAt(index)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit Note'),
        content: TextField(controller: _controller),
        actions: [
          TextButton(
            onPressed: () {
              notesBox.putAt(index, _controller.text);
              _controller.clear();
              Navigator.pop(context);
            },
            child: Text('Save'),
          )
        ],
      ),
    );
  }

  void _deleteNote(int index) {
    notesBox.deleteAt(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hive Notes')),
      body: ValueListenableBuilder(
        valueListenable: notesBox.listenable(),
        builder: (context, Box<String> box, _) {
          if (box.values.isEmpty) return Center(child: Text('No notes yet.'));
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final note = box.getAt(index);
              return ListTile(
                title: Text(note ?? ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _editNoteDialog(index),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteNote(index),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(hintText: 'Enter a note'),
                onSubmitted: (value) => _addNote(), // <-- This enables Enter key submission
              ),
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: _addNote,
            ),
          ],
        ),
      ),
    );
  }
}