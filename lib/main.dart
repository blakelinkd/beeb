import 'package:beeb/typing_bubbles.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'settings_page.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beeb',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Beeb Chat'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<String> _messages = [];
  String _hostname = '10.0.2.2';
  String _port = '5000';
  bool _isWaiting = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/settings.json');
      if (await file.exists()) {
        final contents = await file.readAsString();
        final settings = jsonDecode(contents);
        setState(() {
          _hostname = settings['hostname'] ?? '10.0.2.2';
          _port = settings['port'] ?? '5000';
        });
      }
    } catch (e) {
      print('Failed to load settings: $e');
    }
  }

  Future<void> _sendMessage() async {
  final text = _controller.text;
  if (text.isNotEmpty) {
    setState(() {
      _messages.add('You: $text');
      _isWaiting = true;  // Show typing bubbles
    });
    _controller.clear();
    _scrollToBottom();
    try {
      final response = await http.post(
        Uri.parse('http://$_hostname:$_port/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': text}),
      );

      setState(() {
        _isWaiting = false;  // Hide typing bubbles
      });

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final responseText = responseData['text'];
        setState(() {
          _messages.add('Server: $responseText');
        });
        _scrollToBottom();
      } else {
        print('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isWaiting = false;  // Hide typing bubbles in case of error
      });
      print('Error sending message: $e');
    }
  }
}

  void _scrollToBottom() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  });
}

  void _navigateToSettings() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsPage(),
      ),
    );

    if (result != null && result is Map<String, String>) {
      setState(() {
        _hostname = result['hostname']!;
        _port = result['port']!;
      });
      _saveSettings(result);
    }
  }

  Future<void> _saveSettings(Map<String, String> settings) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/settings.json');
      await file.writeAsString(jsonEncode(settings));
    } catch (e) {
      print('Failed to save settings: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber[800],
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _navigateToSettings,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
  child: ListView.builder(
    padding: const EdgeInsets.all(8),
    itemCount: _messages.length + (_isWaiting ? 1 : 0),  // Add 1 for typing bubbles
    itemBuilder: (context, index) {
      if (index == _messages.length && _isWaiting) {
        return const TypingBubbles();  // Show typing bubbles at the end
      }
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.amber[(index % 3 + 1) * 100],
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(_messages[index]),
      );
    },
  ),
),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter message',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
