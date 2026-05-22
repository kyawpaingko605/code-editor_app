import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const CodeEditorApp());
}

class CodeEditorApp extends StatelessWidget {
  const CodeEditorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Code Editor',
      theme: ThemeData.dark(),
      home: const EditorScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final TextEditingController _codeController = TextEditingController();
  String _output = '';
  bool _isLoading = false;
  String _selectedLanguage = 'python';

  final List<String> _languages = ['python', 'javascript', 'java', 'cpp'];

  Future<void> _runCode() async {
    setState(() {
      _isLoading = true;
      _output = 'Running...';
    });

    try {
      const apiUrl = 'https://api.onecompiler.com/v1/run';
      const apiKey = 'oc_44q32grvr_44q32grwd_996842f5d83767dc8d9dbca260f028c55c8774694ac30046';

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': apiKey,
        },
        body: jsonEncode({
          'language': _selectedLanguage,
          'files': [
            {'content': _codeController.text}
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final stdout = data['stdout'] ?? '';
        final stderr = data['stderr'] ?? '';
        setState(() {
          _output = stderr.isNotEmpty ? 'Error:\n$stderr' : stdout;
        });
      } else {
        setState(() {
          _output = 'API Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _output = 'Connection Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Code Editor'),
        actions: [
          DropdownButton<String>(
            value: _selectedLanguage,
            dropdownColor: Colors.grey[900],
            items: _languages.map((lang) {
              return DropdownMenuItem(
                value: lang,
                child: Text(lang.toUpperCase()),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedLanguage = value!;
              });
            },
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _runCode,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Run'),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.black,
              child: TextField(
                controller: _codeController,
                maxLines: null,
                expands: true,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  color: Colors.white,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Write your code here...',
                  hintStyle: TextStyle(color: Colors.grey),
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey[900],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.grey[850],
                    child: const Text(
                      'Output:',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : SingleChildScrollView(
                              child: SelectableText(
                                _output.isEmpty ? '▶️ Run your code' : _output,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 13,
                                  color: Colors.greenAccent,
                                ),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
