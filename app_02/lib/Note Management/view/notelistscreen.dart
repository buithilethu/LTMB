import 'package:flutter/material.dart';
import '../database/databasehelper.dart';
import '../model/note.dart';
import '../view/notedetailscreen.dart';
import '../view/noteformscreen.dart';
import '../widgets/noteitem.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  late List<Note> notes;
  bool isLoading = false;
  bool isGridView = false;

  @override
  void initState() {
    super.initState();
    refreshNotes();
  }

  Future refreshNotes() async {
    setState(() => isLoading = true);
    notes = await NoteDatabaseHelper.instance.getAllNotes();
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ghi chú"),
        actions: [
          IconButton(
            icon: Icon(isGridView ? Icons.list : Icons.grid_view),
            onPressed: () => setState(() => isGridView = !isGridView),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'refresh') refreshNotes();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'refresh', child: Text('Refresh')),
              const PopupMenuItem(value: 'filter', child: Text('Filter by Priority')),
            ],
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notes.isEmpty
          ? const Center(child: Text('Không có ghi chú'))
          : buildNotes(),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NoteFormScreen()),
          );
          refreshNotes();
        },
      ),
    );
  }

  Widget buildNotes() {
    return isGridView
        ? GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        return NoteItem(
          note: notes[index],
          onTap: () => _showDetail(notes[index]),
          onDelete: () => _deleteNote(notes[index]),
        );
      },
    )
        : ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        return NoteItem(
          note: notes[index],
          onTap: () => _showDetail(notes[index]),
          onDelete: () => _deleteNote(notes[index]),
        );
      },
    );
  }

  void _showDetail(Note note) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NoteDetailScreen(note: note)),
    );
    refreshNotes();
  }

  void _deleteNote(Note note) async {
    await NoteDatabaseHelper.instance.deleteNote(note.id!);
    refreshNotes();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Xóa ghi chú')),
    );
  }
}