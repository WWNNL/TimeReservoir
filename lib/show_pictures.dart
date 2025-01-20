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
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        // 计算每行最多显示4个图片时的单个图片宽度
        final itemWidth = (maxWidth - 3 * 4) / 4; // 4个图片有3个间距
        return Wrap(
          spacing: 4.0, // 水平间距
          runSpacing: 4.0, // 垂直间距
          children: imagePaths.map((path) {
            return FutureBuilder(
              future: _getImageSize(path),
              builder: (context, AsyncSnapshot<Size> snapshot) {
                // 统一占位符尺寸（保持与实际图片相同布局）
                final placeholder = SizedBox(
                  width: itemWidth,
                  height: itemWidth, // 默认正方形占位
                  child: Container(color: Colors.grey),
                );
                if (!snapshot.hasData || snapshot.connectionState != ConnectionState.done) {
                  return placeholder;
                }
                final Size size = snapshot.data!;
                final aspectRatio = size.width / size.height;
                return SizedBox(
                  width: itemWidth,
                  height: itemWidth / aspectRatio,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.file(
                      File(path),
                      fit: BoxFit.cover, // 填充容器并保持比例
                      cacheWidth: (itemWidth * WidgetsBinding.instance.window.devicePixelRatio).round(),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
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
