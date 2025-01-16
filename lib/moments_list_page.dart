import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'moments_form_page.dart';

import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';

class MomentsListPage extends StatefulWidget {
  const MomentsListPage({super.key});

  @override
  State<MomentsListPage> createState() => _MomentsListPage();
}

class _MomentsListPage extends State<MomentsListPage> {
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
                  moments[index]['pictures'].isEmpty? const Padding(padding: EdgeInsets.all(0)) :
                  ImageSlideshow(
                    /// Width of the [ImageSlideshow].
                    width: double.infinity,
                    /// Height of the [ImageSlideshow].
                    height: 200,
                    /// The page to show when first creating the [ImageSlideshow].
                    initialPage: 0,
                    /// The color to paint the indicator.
                    indicatorColor: Colors.blue,
                    /// The color to paint behind th indicator.
                    indicatorBackgroundColor: Colors.grey,
                    /// Called whenever the page in the center of the viewport changes.
                    onPageChanged: (value) {
                    },
                    /// Auto scroll interval.
                    /// Do not auto scroll with null or 0.
                    autoPlayInterval: 3000,
                    /// Loops back to first slide.
                    isLoop: moments[index]['pictures'].split(',').length!=1?true:false,
                    /// The widgets to display in the [ImageSlideshow].
                    /// Add the sample image file into the images folder
                    children: reImg(moments[index]['pictures'].split(',')),
                  ),
                  // moments[index]['pictures'].isEmpty? const Padding(padding: EdgeInsets.all(0)) :
                  // SizedBox(
                  //   height: ((moments[index]['pictures']?.split(',').length/3.floor()+1)*95).toDouble(),
                  //   child: GridView.builder(
                  //     padding: const EdgeInsets.all(8.0),
                  //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  //       crossAxisCount: 3, // 每行显示3个图片
                  //       crossAxisSpacing: 8.0,
                  //       mainAxisSpacing: 8.0,
                  //     ),
                  //     itemCount: moments[index]['pictures']?.split(',').length ?? 0,
                  //     itemBuilder: (context, index_) {
                  //       // 定义一个变量来存储图片文件
                  //       final imageFile = File(moments[index]['pictures'].split(',')[index_]);
                  //       // 异步获取图片尺寸
                  //       Future<Size> getImageSize() async {
                  //         final image = Image.file(imageFile);
                  //         final Completer<Size> completer = Completer();
                  //         image.image.resolve(ImageConfiguration.empty).addListener(
                  //           ImageStreamListener(
                  //                 (ImageInfo info, bool _) {
                  //               completer.complete(Size(info.image.width.toDouble(), info.image.height.toDouble()));
                  //             },
                  //           ),
                  //         );
                  //         return completer.future;
                  //       }
                  //       return FutureBuilder<Size>(
                  //         future: getImageSize(),
                  //         builder: (context, snapshot) {
                  //           if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                  //             // 获取缩放后的尺寸
                  //             final Size size = snapshot.data!;
                  //             final int cacheWidth = (size.width / 4).toInt();
                  //             final int cacheHeight = (size.height / 4).toInt();
                  //
                  //             // 返回缩放后的图片
                  //             return Image.file(
                  //               imageFile,
                  //               fit: BoxFit.cover,
                  //               cacheWidth: cacheWidth,
                  //               cacheHeight: cacheHeight,
                  //             );
                  //           } else {
                  //             // 图片尺寸正在加载，显示占位符
                  //             return const Placeholder();
                  //           }
                  //         },
                  //       );
                  //     },
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

List<Widget> reImg(List a){
  List<Widget> b=[];
  for(int i=0;i<a.length;i++){
    b.add(
      Image.file(
          File(a[i]),
          fit: BoxFit.cover
      ),
    );
  }
  return b;
}
