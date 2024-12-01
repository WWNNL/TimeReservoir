import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '时光水库',
      home: Scaffold(
        backgroundColor: const Color(0xffc8d6e5), // 设置背景颜色
        body: const MyHomePage(),
        appBar: AppBar( //导航栏
          leading:IconButton(icon: const Icon(Icons.list), onPressed: () {}),
          title: const Text("TimeReservoir"),
          actions: <Widget>[ //导航栏右侧菜单
            IconButton(icon: const Icon(Icons.calendar_month_outlined), onPressed:() {}),
            IconButton(icon: const Icon(Icons.search), onPressed:() {}),
            IconButton(icon: const Icon(Icons.add), onPressed:() {}),
          ],
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget{
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState()=>_MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  var str=0;

  void addOnPressed(){
    setState(() {
      str++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(icon: const Icon(Icons.add), onPressed: addOnPressed),
            Text("$str"),
          ],
        )
      );
  }
}