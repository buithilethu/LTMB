import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';
import '../database/note_database_helper.dart';
import 'note_detail_screen.dart';
import 'note_form_screen.dart';
import 'login_screen.dart';
import '../widgets/note_item.dart';

class NoteListScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;

  const NoteListScreen({Key? key, required this.onThemeToggle})
      : super(key: key);

  @override
  _NoteListScreenState createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  final NoteDatabaseHelper _dbHelper = NoteDatabaseHelper();
  List<Note> _notes = [];
  bool _isLoading = true;
  bool _isGridView = true;
  String _searchQuery = '';
  int? _priorityFilter;
  bool _sortByPriority = true;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndNotes();
  }

  Future<void> _loadUserIdAndNotes() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('userId');
      _isLoading = true;
    });
    if (_userId != null) {
      await _refreshNoteList();
    }
  }

  Future<void> _refreshNoteList() async {
    if (_userId == null) return;

    setState(() {
      _isLoading = true;
    });

    List<Note> notes;

    if (_searchQuery.isNotEmpty) {
      notes = await _dbHelper.searchNotes(_searchQuery, _userId!);
    } else if (_priorityFilter != null) {
      notes = await _dbHelper.getNotesByPriority(_priorityFilter!, _userId!);
    } else {
      notes = await _dbHelper.getAllNotes(_userId!);
    }

    if (_sortByPriority) {
      notes.sort((a, b) => b.priority.compareTo(a.priority));
    } else {
      notes.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
    }

    setState(() {
      _notes = notes;
      _isLoading = false;
    });
  }

  void _deleteNote(int id) async {
    if (_userId == null) return;
    await _dbHelper.deleteNote(id, _userId!);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã xóa ghi chú')),
    );
    _refreshNoteList();
  }

  void _showDeleteConfirmation(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa ghi chú'),
        content: const Text('Bạn có chắc muốn xóa ghi chú này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteNote(id);
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('userId');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) =>
              LoginScreen(onThemeToggle: widget.onThemeToggle)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ghi chú của tôi'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'refresh') {
                _refreshNoteList();
              } else if (value == 'sort_priority') {
                setState(() {
                  _sortByPriority = true;
                  _refreshNoteList();
                });
              } else if (value == 'sort_time') {
                setState(() {
                  _sortByPriority = false;
                  _refreshNoteList();
                });
              } else if (value == 'filter_high') {
                setState(() {
                  _priorityFilter = 3;
                  _refreshNoteList();
                });
              } else if (value == 'filter_medium') {
                setState(() {
                  _priorityFilter = 2;
                  _refreshNoteList();
                });
              } else if (value == 'filter_low') {
                setState(() {
                  _priorityFilter = 1;
                  _refreshNoteList();
                });
              } else if (value == 'filter_clear') {
                setState(() {
                  _priorityFilter = null;
                  _refreshNoteList();
                });
              } else if (value == 'toggle_theme') {
                widget.onThemeToggle();
              } else if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: Text('Làm mới'),
              ),
              const PopupMenuItem(
                value: 'sort_priority',
                child: Text('Sắp xếp theo độ ưu tiên'),
              ),
              const PopupMenuItem(
                value: 'sort_time',
                child: Text('Sắp xếp theo thời gian'),
              ),
              const PopupMenuItem(
                value: 'filter_high',
                child: Text('Chỉ ưu tiên cao'),
              ),
              const PopupMenuItem(
                value: 'filter_medium',
                child: Text('Chỉ ưu tiên trung bình'),
              ),
              const PopupMenuItem(
                value: 'filter_low',
                child: Text('Chỉ ưu tiên thấp'),
              ),
              const PopupMenuItem(
                value: 'filter_clear',
                child: Text('Xóa bộ lọc'),
              ),
              const PopupMenuItem(
                value: 'toggle_theme',
                child: Text('Chuyển chế độ tối'),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Text('Đăng xuất'),
              ),
            ],
          ),
        ],
      ),
      body: _userId == null
          ? const Center(child: Text('Lỗi: Không tìm thấy người dùng'))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Tìm kiếm ghi chú',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                          _refreshNoteList();
                        },
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                      _refreshNoteList();
                    },
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _notes.isEmpty
                          ? const Center(child: Text('Không có ghi chú nào'))
                          : _isGridView
                              ? GridView.builder(
                                  padding: const EdgeInsets.all(8.0),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.8,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                  ),
                                  itemCount: _notes.length,
                                  itemBuilder: (context, index) {
                                    return NoteItem(
                                      note: _notes[index],
                                      onTap: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                NoteDetailScreen(
                                                    noteId: _notes[index].id!),
                                          ),
                                        );
                                        _refreshNoteList();
                                      },
                                      onEdit: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                NoteFormScreen(
                                                    noteId: _notes[index].id),
                                          ),
                                        );
                                        _refreshNoteList();
                                      },
                                      onDelete: () => _showDeleteConfirmation(
                                          _notes[index].id!),
                                    );
                                  },
                                )
                              : ListView.builder(
                                  itemCount: _notes.length,
                                  itemBuilder: (context, index) {
                                    return NoteItem(
                                      note: _notes[index],
                                      isListView: true,
                                      onTap: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                NoteDetailScreen(
                                                    noteId: _notes[index].id!),
                                          ),
                                        );
                                        _refreshNoteList();
                                      },
                                      onEdit: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                NoteFormScreen(
                                                    noteId: _notes[index].id),
                                          ),
                                        );
                                        _refreshNoteList();
                                      },
                                      onDelete: () => _showDeleteConfirmation(
                                          _notes[index].id!),
                                    );
                                  },
                                ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NoteFormScreen(),
            ),
          );
          _refreshNoteList();
        },
        child: const Icon(Icons.add),
        tooltip: 'Thêm ghi chú',
      ),
    );
  }
}
