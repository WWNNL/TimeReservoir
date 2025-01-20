import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

class ShowPictures extends StatefulWidget {
  final String imagePathsStr; // 用于存储图片路径

  const ShowPictures({super.key, required this.imagePathsStr});

  @override
  State<ShowPictures> createState() => _ShowPictures();
}

class _ShowPictures extends State<ShowPictures> {
  late List<String> imagePaths;

  @override
  void initState() {
    super.initState();
    imagePaths=widget.imagePathsStr.split(',');
    requestStoragePermission();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4.0, // 图片之间的水平间距
      runSpacing: 4.0, // 图片之间的垂直间距
      children: imagePaths.map((path) {
        return FutureBuilder(
          future: _getImageSize(path),
          builder: (BuildContext context, AsyncSnapshot<Size> snapshot) {
            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
              // 图片加载完成，获取到尺寸
              Size size = snapshot.data!;
              double scalingSize=0.08;
              return SizedBox(
                width: size.width*scalingSize, // 使用图片的原始宽度
                height: size.height*scalingSize, // 使用图片的原始高度
                child: Image.file(
                    File(path),
                    fit: BoxFit.cover
                )
              );
            } else {
              // 图片正在加载，可以显示一个占位符
              return Container(
                width: 100, // 占位符宽度
                height: 100, // 占位符高度
                color: Colors.grey, // 占位符颜色
              );
            }
          },
        );
      }).toList(),
    );
  }

// 定义一个方法来获取图片尺寸
  Future<Size> _getImageSize(String imagePath) async {
    final image = Image.file(File(imagePath)).image.resolve(ImageConfiguration());
    final Completer<Size> completer = Completer<Size>();
    image.addListener(ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(Size(info.image.width.toDouble(), info.image.height.toDouble()));
    }));
    return completer.future;
  }

  Future<void> requestStoragePermission() async {
    // 请求存储权限
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    status = await Permission.manageExternalStorage.status;
    if (!status.isGranted) {
      status = await Permission.manageExternalStorage.request();
    }
    //
    // if (status.isGranted) {
    //   print('存储权限已授予');
    // } else {
    //   print('存储权限被拒绝');
    // }
  }
}
