import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyFlowersPage extends StatefulWidget {
  @override
  _MyFlowersPageState createState() => _MyFlowersPageState();
}

class _MyFlowersPageState extends State<MyFlowersPage> {
  List<FlowerNote> _flowerNotes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kendi Çiçeklerim'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        itemCount: _flowerNotes.length,
        itemBuilder: (context, index) {
          final note = _flowerNotes[index];
          return ListTile(
            title: Text(note.flowerName),
            subtitle: Text(DateFormat.yMMMd().format(note.date)),
            onTap: () {
              _editNote(index);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        child: Icon(Icons.add),
      ),
    );
  }

  void _addNote() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddFlowerNotePage()),
    );
    if (result != null) {
      setState(() {
        _flowerNotes.add(result);
      });
    }
  }

  void _editNote(int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditFlowerNotePage(_flowerNotes[index]),
      ),
    );
    if (result != null) {
      setState(() {
        _flowerNotes[index] = result;
      });
    }
  }
}

class FlowerNote {
  String flowerName;
  DateTime date;
  String note;

  FlowerNote({
    required this.flowerName,
    required this.date,
    required this.note,
  });
}

class AddFlowerNotePage extends StatefulWidget {
  @override
  _AddFlowerNotePageState createState() => _AddFlowerNotePageState();
}

class _AddFlowerNotePageState extends State<AddFlowerNotePage> {
  final _flowerNameController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Çiçek Notu Ekle'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _flowerNameController,
              decoration: InputDecoration(labelText: 'Çiçek Adı'),
            ),
            SizedBox(height: 20),
            Text(
              'Tarih: ${DateFormat.yMMMd().format(_selectedDate)}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _presentDatePicker,
              child: Text('Tarih Seç'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(labelText: 'Not'),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveNote,
              child: Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  void _presentDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _saveNote() {
    final flowerName = _flowerNameController.text;
    final note = _noteController.text;
    if (flowerName.isNotEmpty && note.isNotEmpty) {
      final newNote = FlowerNote(
        flowerName: flowerName,
        date: _selectedDate,
        note: note,
      );
      Navigator.pop(context, newNote);
    }
  }
}

class EditFlowerNotePage extends StatefulWidget {
  final FlowerNote flowerNote;

  EditFlowerNotePage(this.flowerNote);

  @override
  _EditFlowerNotePageState createState() => _EditFlowerNotePageState();
}

class _EditFlowerNotePageState extends State<EditFlowerNotePage> {
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _noteController.text = widget.flowerNote.note;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Çiçek Notunu Düzenle'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Çiçek Adı: ${widget.flowerNote.flowerName}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(labelText: 'Not'),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveNote,
              child: Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveNote() {
    final note = _noteController.text;
    if (note.isNotEmpty) {
      final updatedNote = FlowerNote(
        flowerName: widget.flowerNote.flowerName,
        date: widget.flowerNote.date,
        note: note,
      );
      Navigator.pop(context, updatedNote);
    }
  }
}
