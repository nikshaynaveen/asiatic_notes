// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, prefer_final_fields, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'models/note_model.dart';
import 'db_helper.dart';
import 'add_edit_note.dart';

class NotesList extends StatefulWidget {
  @override
  _NotesListState createState() => _NotesListState();
}

class _NotesListState extends State<NotesList> {
  late DatabaseHelper _dbHelper;
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  TextEditingController _searchController = TextEditingController();
  FocusNode _searchFocusNode = FocusNode(); // FocusNode for search bar

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final notes = await _dbHelper.getNotes();
    setState(() {
      _notes = notes;
      _filteredNotes = notes; // Initialize filtered notes with all notes
    });
  }

  void _navigateToAddNote() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditNotePage()),
    );
    _loadNotes();
  }

  void _editNote(Note note) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditNotePage(note: note)),
    );
    _loadNotes();
  }

  void _deleteNote(int id) async {
    await _dbHelper.deleteNote(id);
    _loadNotes();
  }

  Future<void> _showDeleteConfirmationDialog(int id) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Note'),
          content: Text('Are you sure you want to delete this note?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                _deleteNote(id); // Call delete function
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _filterNotes(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredNotes = _notes; // Show all notes if query is empty
      });
    } else {
      setState(() {
        _filteredNotes = _notes
            .where((note) =>
                note.title.toLowerCase().contains(query.toLowerCase()) ||
                note.content.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _filterNotes('');
    _searchFocusNode.unfocus(); // Unfocus after clearing the search
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose(); // Dispose FocusNode to avoid memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Unfocus when tapping outside
      },
      child: Scaffold(
        backgroundColor: Color(0xffffffff),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode, // Attach FocusNode
                    onChanged: _filterNotes,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xfff4f7fc),
                      hintText: '   Search your notes...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 12.0), // Adjust vertical padding
                      suffixIcon: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: _clearSearch,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),

                // Notes Grid
                Expanded(
                  child: _filteredNotes.isEmpty
                      ? Center(child: Text('No notes found'))
                      : MasonryGridView.builder(
                          gridDelegate:
                              SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2),
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          itemCount: _filteredNotes.length,
                          itemBuilder: (context, index) {
                            final note = _filteredNotes[index];
                            return GestureDetector(
                              onTap: () => _editNote(note),
                              child: Card(
                                elevation: 0,
                                color: Color(0xffffffff),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(color: Colors.grey.shade300),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              note.title,
                                              style: TextStyle(
                                                color: Color(0xff4b4c50),
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete,
                                                size: 20,
                                                color: Color(0xff4b4c50)),
                                            onPressed: () {
                                              if (note.id != null) {
                                                _showDeleteConfirmationDialog(note
                                                    .id!); // Using null check operator
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        note.content,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xff4b4c50),
                                        ),
                                        maxLines: null,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _navigateToAddNote,
          child: Icon(
            Icons.add,
            color: Color(0xff4b4c50),
          ),
        ),
      ),
    );
  }
}
