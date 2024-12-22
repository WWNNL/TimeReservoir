import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'moments_form_page.dart';

class MomentsListPage extends StatefulWidget {
  const MomentsListPage({super.key});

  @override
  State<MomentsListPage> createState() => _StudentListPageState();
}

class _StudentListPageState extends State<MomentsListPage> {
  List<Map<String, dynamic>> moments = [];

  _refreshMoments() async {
    final data = await DatabaseHelper().getAll();
    setState(() => moments = data);
  }

  _deleteMoments(int id) async {
    await DatabaseHelper().delete(id);
    _refreshMoments();
  }

  @override
  void initState() {
    super.initState();
    _refreshMoments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Moments'),
        backgroundColor: Colors.grey, // Customize the app bar color
        iconTheme: const IconThemeData(color: Colors.white), // Set the back arrow color to white
        titleTextStyle: const TextStyle(color: Colors.white,
          fontSize: 20,
        ),
        actions: [ //导航栏右侧菜单
          // IconButton(icon: const Icon(Icons.calendar_month_outlined), onPressed:() {}),
          // IconButton(icon: const Icon(Icons.search), onPressed:() {}),
          IconButton(icon: const Icon(Icons.add), onPressed:() {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => const MomentsFormPage(),)).then((_) => _refreshMoments());
          }),
        ],
      ),
      body: moments.isEmpty
          ? const Center(child: Text('No moments available', style: TextStyle(fontSize: 18)))
          : ListView.builder(
        itemCount: moments.length,
        itemBuilder: (context, index) => Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Dismissible(
            key: Key(moments[index]['id'].toString()),
            direction: DismissDirection.endToStart, // Swiping from right to left
            confirmDismiss: (direction) async {
              return await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Confirm'),
                    content: const Text('Are you sure you want to delete this item?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false), // 取消删除
                        child: const Text('CANCEL'),
                      ),
                      TextButton(
                        onPressed: () {
                          _deleteMoments(moments[index]['id']);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Moments deleted')),
                          );
                          Navigator.of(context).pop(true);}, // 确认删除
                        child: const Text('DELETE'),
                      ),
                    ],
                  );
                },
              );
            },
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20), // Red background for delete action
              child: const Icon(Icons.delete, color: Colors.white, size: 40),
            ),
            child: Material(
              elevation: 10.0,
              shadowColor: Colors.blueGrey,
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(
                  moments[index]['texts'],
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text('${moments[index]['time']}'),
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (context) => MomentsFormPage(moments: moments[index]),
                )).then((_) => _refreshMoments()),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
