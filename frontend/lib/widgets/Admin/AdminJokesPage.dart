import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config.dart';
import '../../constants/colors.dart';

class Joke {
  final String id;
  final String content;
  final String reson;
  final DateTime createdAt;

  Joke({
    required this.id,
    required this.content,
    required this.reson,
    required this.createdAt,
  });

  factory Joke.fromJson(Map<String, dynamic> json) {
    return Joke(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      content: json['content'] ?? '',
      reson: json['reson'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class AdminJokesPage extends StatefulWidget {
  const AdminJokesPage({Key? key}) : super(key: key);

  @override
  State<AdminJokesPage> createState() => _AdminJokesPageState();
}

class _AdminJokesPageState extends State<AdminJokesPage> {
  List<Joke> jokes = [];
  bool isLoading = true;
  String errorMessage = '';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadJokes();
  }

  Future<void> _loadJokes() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse(adminJokesUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> jokesJson = data['jokes'] ?? [];
          setState(() {
            jokes = jokesJson.map((json) => Joke.fromJson(json)).toList();
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = data['message'] ?? 'Failed to load jokes';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to load jokes: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading jokes: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _deleteJoke(String jokeId) async {
    try {
      final response = await http.delete(
        Uri.parse('$adminJokesUrl/$jokeId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        _loadJokes(); // Reload the list
        _showSnackBar('Joke deleted successfully', Colors.green);
      } else {
        final data = json.decode(response.body);
        _showSnackBar(data['message'] ?? 'Failed to delete joke', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Error deleting joke: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showDeleteDialog(Joke joke) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Joke'),
          content: Text('Are you sure you want to delete "${joke.content}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteJoke(joke.id);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showAddJokeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AddJokeDialog(
          rootContext: context,
          onJokeAdded: () {
            _loadJokes();
          },
        );
      },
    );
  }

  void _showEditJokeDialog(Joke joke) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return EditJokeDialog(
          rootContext: context,
          joke: joke,
          onJokeUpdated: () {
            _loadJokes();
          },
        );
      },
    );
  }

  List<Joke> get filteredJokes {
    return jokes.where((joke) {
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        if (!joke.reson.toLowerCase().contains(query) &&
            !joke.content.toLowerCase().contains(query)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Islamic Jokes Management',
          style: TextStyle(fontWeight: FontWeight.bold), // العنوان Bold
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: _showAddJokeDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.islamicGreen500,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              icon: const Icon(Icons.add, color: Colors.white, size: 20),
              label: const Text(
                "Add New Joke",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search jokes...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),

          // Content
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                size: 64, color: Colors.red[300]),
                            const SizedBox(height: 16),
                            Text(
                              errorMessage,
                              style: TextStyle(
                                  color: Colors.red[600], fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadJokes,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : filteredJokes.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.sentiment_neutral,
                                    size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'No jokes found',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 16),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredJokes.length,
                            itemBuilder: (context, index) {
                              final joke = filteredJokes[index];
                              return _buildJokeCard(joke);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildJokeCard(Joke joke) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    joke.content,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _showEditJokeDialog(joke);
                        break;
                      case 'delete':
                        _showDeleteDialog(joke);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Content
            Text(
              joke.content,
              style: const TextStyle(fontSize: 14),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // Reason
            Text(
              joke.reson,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                fontStyle: FontStyle.italic,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            const SizedBox(height: 8),

            // Date
            Text(
              'Created: ${_formatDate(joke.createdAt)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}



// Add Joke Dialog
class AddJokeDialog extends StatefulWidget {
  final VoidCallback onJokeAdded;
  final BuildContext rootContext;
  const AddJokeDialog({Key? key, required this.onJokeAdded, required this.rootContext}) : super(key: key);

  @override
  State<AddJokeDialog> createState() => _AddJokeDialogState();
}

class _AddJokeDialogState extends State<AddJokeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _reasonController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _contentController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submitJoke() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final jokeData = {
        'content': _contentController.text.trim(),
        'reson': _reasonController.text.trim(),
      };

      final response = await http.post(
        Uri.parse(adminJokesUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(jokeData),
      );

     if (response.statusCode == 201) {
  widget.onJokeAdded();
  Navigator.of(context).pop();
  ScaffoldMessenger.of(widget.rootContext).showSnackBar(   // <-- استعمل rootContext
    const SnackBar(
      content: Text('Joke created successfully'),
      backgroundColor: Colors.green,
    ),
  );
}
else {
        final data = json.decode(response.body);
        ScaffoldMessenger.of(widget.rootContext).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Failed to create joke'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating joke: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Joke'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Joke Content',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Please enter the joke content' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  border: OutlineInputBorder(),
                  hintText: 'Why?',
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitJoke,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Add Joke'),
        ),
      ],
    );
  }
}


// Edit Joke Dialog
class EditJokeDialog extends StatefulWidget {
  final Joke joke;
  final VoidCallback onJokeUpdated;
  final BuildContext rootContext;

  const EditJokeDialog({
    Key? key,
    required this.joke,
    required this.onJokeUpdated,
    required this.rootContext,
  }) : super(key: key);

  @override
  State<EditJokeDialog> createState() => _EditJokeDialogState();
}

class _EditJokeDialogState extends State<EditJokeDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _contentController;
  late TextEditingController _reasonController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.joke.content);
    _reasonController = TextEditingController(text: widget.joke.reson);
  }

  @override
  void dispose() {
    _contentController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _updateJoke() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final jokeData = {
        'content': _contentController.text.trim(),
        'reson': _reasonController.text.trim(),
      };

      final response = await http.put(
        Uri.parse('$adminJokesUrl/${widget.joke.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(jokeData),
      );

      if (response.statusCode == 200) {
        widget.onJokeUpdated();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(widget.rootContext).showSnackBar(
          const SnackBar(
            content: Text('Joke updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final data = json.decode(response.body);
        ScaffoldMessenger.of(widget.rootContext).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Failed to update joke'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating joke: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Joke'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Joke Content',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Please enter the joke content'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  border: OutlineInputBorder(),
                  hintText: 'Why is this joke funny?',
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _updateJoke,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Update Joke'),
        ),
      ],
    );
  }
}

