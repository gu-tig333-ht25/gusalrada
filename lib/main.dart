import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
 runApp(
   ChangeNotifierProvider(
     create: (_) => TodoStore()..init(),
     child: const TodoApp(),
   ),
 );
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

class TodoStore extends ChangeNotifier {
 static const _base = 'https://todoapp-api.apps.k8s.gu.se';
 static const _key = '4b9a2bbe-d660-4ebd-a8b3-e98587cfbaa4';

 final List<Map<String, dynamic>> _items = [];

 _Filter _filter = _Filter.all;
 Future<void> _reloadFromServer() async {
   final r = await http.get(Uri.parse('$_base/todos?key=$_key'));
   if (r.statusCode == 200) {
     final List data = jsonDecode(r.body);
     _items
       ..clear()
       ..addAll(data.map<Map<String, dynamic>>((e) => {
         'id': e['id'],
         'text': e['title'],
         'done': e['done'] == true,
       }));
     notifyListeners();
   }
 }

 Future<void> init() async {
   await _reloadFromServer();
 }

 List<Map<String, dynamic>> get visibleItems {
   switch (_filter) {
     case _Filter.done:
       return _items.where((e) => e["done"] == true).toList();
     case _Filter.undone:
       return _items.where((e) => e["done"] != true).toList();
     case _Filter.all:
       return _items;
   }
 }

 _Filter get filter => _filter;

 Future<void> addItem(String text) async {
   final t= text.trim();
   if (t.isEmpty) return;
   final res= await http.post(
     Uri.parse('$_base/todos?key=$_key'),
     headers: {'Content-Type': 'application/json'},
     body: jsonEncode({'title': t, 'done': false}),
   );
   if (res.statusCode >= 200 && res.statusCode < 300) {
     await _reloadFromServer ();
   }   
 }

 Future<void> toggleItem(Map<String, dynamic> item, bool value) async {
   final id = item['id'] as String?;
   final text = item['text'] as String;
   if (id == null) return;

   final res = await http.put(
     Uri.parse('$_base/todos/$id?key=$_key'),
     headers: {'Content-Type': 'application/json'},
     body: jsonEncode({'title': text, 'done': value}),
   );
   if (res.statusCode >= 200 && res.statusCode < 300) {
     await _reloadFromServer();
   }
 }

 Future<void> removeItem(Map<String, dynamic> item) async {
   final id = item['id'] as String?;
   if (id == null) return;

   final res = await http.delete(Uri.parse('$_base/todos/$id?key=$_key'));
   if (res.statusCode >= 200 && res.statusCode < 300) {
     await _reloadFromServer();
   }
 }

 void setFilter(_Filter f) {
   if (_filter == f) return;
   _filter = f;
   notifyListeners();
 }
}

class TodoHomePage extends StatefulWidget {
 const TodoHomePage({super.key});

 @override
 State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
 final TextEditingController _controller = TextEditingController();

 List<Map<String, dynamic>> get _visibleItems =>
     context.watch<TodoStore>().visibleItems;

 void _addItem() {
   context.read<TodoStore>().addItem(_controller.text);
   _controller.clear();
 }

 void _toggleItem(Map<String, dynamic> item, bool? value) {
   context.read<TodoStore>().toggleItem(item, value ?? false);
 }

 void _removeItem(Map<String, dynamic> item) {
   context.read<TodoStore>().removeItem(item);
 }

 void _setFilter(_Filter f) {
   context.read<TodoStore>().setFilter(f);
 }

 @override
 Widget build(BuildContext context) {
   final currentFilter = context.watch<TodoStore>().filter;

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
                     selected: currentFilter == _Filter.all,
                     onTap: () => _setFilter(_Filter.all),
                   ),
                   const SizedBox(width: 8),
                   _FilterBox(
                     label: 'done',
                     selected: currentFilter == _Filter.done,
                     onTap: () => _setFilter(_Filter.done),
                   ),
                   const SizedBox(width: 8),
                   _FilterBox(
                     label: 'undone',
                     selected: currentFilter == _Filter.undone,
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
