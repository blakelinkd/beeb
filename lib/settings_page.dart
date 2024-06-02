import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _hostnameController = TextEditingController();
  final TextEditingController _portController = TextEditingController();

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
        _hostnameController.text = settings['hostname'] ?? '';
        _portController.text = settings['port'] ?? '';
      }
    } catch (e) {
      print('Failed to load settings: $e');
    }
  }

  void _saveSettings() {
    final settings = {
      'hostname': _hostnameController.text,
      'port': _portController.text,
    };
    Navigator.pop(context, settings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _hostnameController,
              decoration: const InputDecoration(
                labelText: 'API Server Hostname',
              ),
            ),
            TextField(
              controller: _portController,
              decoration: const InputDecoration(
                labelText: 'API Server Port',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveSettings,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
