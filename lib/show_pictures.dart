import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'dart:io';

class ShowPictures extends StatefulWidget {
  final String imagePathsStr; // 用于存储图片路径

  const ShowPictures({super.key, required this.imagePathsStr});

  @override
  State<ShowPictures> createState() => _ShowPictures();
}

class _ShowPictures extends State<ShowPictures> {
  // 维护四列的图片数据和高度信息
  final List<List<String>> _columns = [[], [], [], []];
  final List<double> _columnHeights = [0, 0, 0, 0];
  final double _spacing = 0.0;
  late List<String> imagePaths;

  @override
  void initState() {
    super.initState();
    imagePaths=widget.imagePathsStr.split(',');
    requestStoragePermission();
    _distributeImages();
  }
  
  // 动态分配图片到最短列
  void _distributeImages() {
    for (var path in widget.imagePathsStr.split(',')) {
      // 找到当前最矮的列
      int shortestIndex = _columnHeights.indexOf(_columnHeights.reduce(min));
      _columns[shortestIndex].add(path);

      // 假设图片高度（占位计算，实际需要异步获取后更新）
      _columnHeights[shortestIndex] += 200; // 初始预估高度
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnWidth = (constraints.maxWidth - 3 * _spacing) / 4;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(4, (index) {
            return _buildImageColumn(columnWidth, _columns[index]);
          }),
        );
      },
    );
  }

  Widget _buildImageColumn(double width, List<String> paths) {
    return SizedBox(
      width: width,
      child: Column(
        children: [
          for (var path in paths)
            FutureBuilder(
              future: _getImageSize(path),
              builder: (context, snapshot) {
                final itemHeight = snapshot.hasData
                    ? (width * snapshot.data!.height / snapshot.data!.width)
                    : width; // 默认正方形占位
                return Padding(
                  padding: EdgeInsets.only(bottom: _spacing),
                  child: Container(
                    width: width,
                    height: itemHeight,
                    color: Colors.grey[300],
                    child: snapshot.hasData
                        ? Image.file(
                      File(path),
                      fit: BoxFit.cover,
                      cacheWidth: (width * MediaQuery.of(context).devicePixelRatio).round(),
                    )
                        : const Center(child: CircularProgressIndicator()),
                  ),
                );
              },
            )
        ],
      ),
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
