import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const TodoHomePage(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('sv')],
    );
  }
}

class TodoHomePage extends StatelessWidget {
  const TodoHomePage({super.key});

  final List<Map<String, dynamic>> items = const [
    {"text": "Write a book", "done": false},
    {"text": "Do homework", "done": false},
    {"text": "Tidy room", "done": true},
    {"text": "Watch TV", "done": false},
    {"text": "Nap", "done": false},
    {"text": "Shop groceries", "done": false},
    {"text": "Have fun", "done": false},
    {"text": "Meditate", "done": false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade300,
        title: const Text('TIG333 TODO', style: TextStyle(color: Colors.black87)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(160),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextField(
                  readOnly: true,
                  decoration: const InputDecoration(
                    hintText: 'What are you going to do?',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const Text('+ ADD', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _FilterBox(label: 'all', selected: true),
                    SizedBox(width: 8),
                    _FilterBox(label: 'done', selected: false),
                    SizedBox(width: 8),
                    _FilterBox(label: 'undone', selected: false),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(color: Colors.white),
          ListView(
            children: items.map((item) {
              return ListTile(
                leading: Checkbox(value: item["done"], onChanged: null),
                title: Text(
                  item["text"],
                  style: TextStyle(
                    decoration:
                        item["done"] ? TextDecoration.lineThrough : null,
                  ),
                ),
                trailing: const Icon(Icons.close, color: Colors.grey, size: 18),
              );
            }).toList(),
          ),
          Positioned(
            right: 20,
            bottom: 20,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.add, color: Colors.black54, size: 28),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBox extends StatelessWidget {
  final String label;
  final bool selected;
  const _FilterBox({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? Colors.grey.shade300 : Colors.white,
        border: Border.all(color: Colors.black54),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label),
    );
  }
}
