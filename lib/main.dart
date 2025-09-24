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

enum _Filter { all, done, undone }

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  final TextEditingController _controller = TextEditingController();

  // Samma initialdata som tidigare, men nu som state
  final List<Map<String, dynamic>> _items = [
    {"text": "Write a book", "done": false},
    {"text": "Do homework", "done": false},
    {"text": "Tidy room", "done": true},
    {"text": "Watch TV", "done": false},
    {"text": "Nap", "done": false},
    {"text": "Shop groceries", "done": false},
    {"text": "Have fun", "done": false},
    {"text": "Meditate", "done": false},
  ];

  _Filter _filter = _Filter.all;

  List<Map<String, dynamic>> get _visibleItems {
    switch (_filter) {
      case _Filter.done:
        return _items.where((e) => e["done"] == true).toList();
      case _Filter.undone:
        return _items.where((e) => e["done"] != true).toList();
      case _Filter.all:
        return _items;
    }
  }

  void _addItem() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _items.insert(0, {"text": text, "done": false});
      _controller.clear();
    });
  }

  void _toggleItem(Map<String, dynamic> item, bool? value) {
    setState(() {
      item["done"] = value ?? false;
    });
  }

  void _removeItem(Map<String, dynamic> item) {
    setState(() {
      _items.remove(item);
    });
  }

  void _setFilter(_Filter f) {
    setState(() {
      _filter = f;
    });
  }

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
                  controller: _controller,
                  onSubmitted: (_) => _addItem(),
                  decoration: const InputDecoration(
                    hintText: 'What are you going to do?',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              // "+ ADD" behåller look men gör den klickbar
              InkWell(
                onTap: _addItem,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.0),
                  child: Text('+ ADD', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _FilterBox(
                      label: 'all',
                      selected: _filter == _Filter.all,
                      onTap: () => _setFilter(_Filter.all),
                    ),
                    const SizedBox(width: 8),
                    _FilterBox(
                      label: 'done',
                      selected: _filter == _Filter.done,
                      onTap: () => _setFilter(_Filter.done),
                    ),
                    const SizedBox(width: 8),
                    _FilterBox(
                      label: 'undone',
                      selected: _filter == _Filter.undone,
                      onTap: () => _setFilter(_Filter.undone),
                    ),
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
            children: _visibleItems.map((item) {
              return ListTile(
                leading: Checkbox(
                  value: item["done"] as bool,
                  onChanged: (v) => _toggleItem(item, v),
                ),
                title: Text(
                  item["text"] as String,
                  style: TextStyle(
                    decoration: (item["done"] as bool)
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey, size: 18),
                  onPressed: () => _removeItem(item),
                  tooltip: 'Remove',
                ),
              );
            }).toList(),
          ),
          // Behåll din runda knapp-look men gör den klickbar
          Positioned(
            right: 20,
            bottom: 20,
            child: GestureDetector(
              onTap: _addItem,
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
          ),
        ],
      ),
    );
  }
}

class _FilterBox extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _FilterBox({required this.label, required this.selected, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.grey.shade300 : Colors.white,
          border: Border.all(color: Colors.black54),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label),
      ),
    );
  }
}
