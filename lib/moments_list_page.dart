import 'package:flutter/material.dart';
import 'package:time_reservoir/show_pictures.dart';
import 'database_helper.dart';
import 'moments_form_page.dart';
// import 'show_pictures.dart';

class MomentsListPage extends StatefulWidget {
  const MomentsListPage({super.key});

  @override
  State<MomentsListPage> createState() => _MomentsListPage();
}

class _MomentsListPage extends State<MomentsListPage> {
  List<Map<String, dynamic>> moments = [];
  // final String _imagePaths="/storage/emulated/0/DCIM/Camera/IMG_20210504_192454_1.jpg"; // 用于存储图片路径

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
          ? const Center(child: Text('这里啥也没有', style: TextStyle(fontSize: 18)))
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
                    title: const Text('确认'),
                    content: const Text('你确定想要删除这一条吗？'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false), // 取消删除
                        child: const Text('删除'),
                      ),
                      TextButton(
                        onPressed: () {
                          _deleteMoments(moments[index]['id']);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Moments 删除')),
                          );
                          Navigator.of(context).pop(true);}, // 确认删除
                        child: const Text('删除'),
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
              child: Column(
                children: [
                  ListTile(
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
                  moments[index]['pictures']==null?Padding(padding: EdgeInsets.all(0)):
                  ShowPictures(imagePathsStr: moments[index]['pictures']),
                  Padding(padding: EdgeInsets.all(3))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}