# Flutter Hive Notes App

## What This App Does

- Create notes
- View all your notes in a list
- Edit existing notes
- Delete notes 

All notes are stored locally on the device using Hive
## Project Structure

- `main.dart` - Sets up the app and Hive database
- `notes_page.dart` - Contains all the UI and logic for managing notes

## How It Works 

### Setting Up Hive (main.dart)

```dart
void main() async {
  // This ensures Flutter bindings are initialized before we do anything else
  WidgetsFlutterBinding.ensureInitialized();
  
  // Get the app's documents directory 
  final appDocDir = await getApplicationDocumentsDirectory();
  
  // Initialize Hive with our storage location
  await Hive.initFlutter(appDocDir.path);
  
  // Open a box (like a table in SQL) to store our string notes
  await Hive.openBox<String>('notes');
  
  // Launch the app!
  runApp(MyApp());
}
```


### The UI & Logic (notes_page.dart)


#### Displaying Notes

I used a `ValueListenableBuilder` wrapped around the Hive box to automatically rebuild whenever the data changes:

```dart
ValueListenableBuilder(
  valueListenable: notesBox.listenable(),
  builder: (context, Box<String> box, _) {
    // Show a message if there are no notes
    if (box.values.isEmpty) 
      return Center(child: Text('No notes yet.'));
    
    // Otherwise build a list of notes
    return ListView.builder(
      itemCount: box.length,
      itemBuilder: (context, index) {
        final note = box.getAt(index);
        return ListTile(
          title: Text(note ?? ''),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Edit and delete buttons...
            ],
          ),
        );
      },
    );
  },
)
```

This approach means the UI automatically updates whenever you add, edit, or delete a note 

#### Adding Notes

I added a text field and button at the bottom of the screen

```dart
void _addNote() {
  if (_controller.text.isNotEmpty) {
    notesBox.add(_controller.text);
    _controller.clear();
  }
}
```

I made so you can hit Enter to add a note

```dart
TextField(
  controller: _controller,
  decoration: InputDecoration(hintText: 'Enter a note'),
  onSubmitted: (value) => _addNote(),
)
```

#### Editing Notes

```dart
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
```


#### Deleting Notes

Deleting is super simple thanks to Hive:

```dart
void _deleteNote(int index) {
  notesBox.deleteAt(index);
}
```



## Dependencies

This project relies on:
- flutter: The UI framework
- hive_flutter: For local data storage
- path_provider: To access the device's file system

