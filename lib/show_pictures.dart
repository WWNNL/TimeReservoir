import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'package:photo_view/photo_view.dart';

class ShowPictures extends StatefulWidget {
  final String imagePathsStr;

  const ShowPictures({super.key, required this.imagePathsStr});

  @override
  State<ShowPictures> createState() => _ShowPictures();
}

class _ShowPictures extends State<ShowPictures> {
  final List<List<String>> _columns = [[], [], [], []];
  final List<double> _columnHeights = [0, 0, 0, 0];
  final double _spacing = 0.0;
  late List<String> imagePaths;

  @override
  void initState() {
    super.initState();
    imagePaths = widget.imagePathsStr.split(',');
    requestStoragePermission();
    _distributeImages();
  }

  void _distributeImages() {
    for (var path in imagePaths) {
      int shortestIndex = _columnHeights.indexOf(_columnHeights.reduce(min));
      _columns[shortestIndex].add(path);
      _columnHeights[shortestIndex] += 200;
    }
  }

  // 全屏预览方法
  void _showFullImage(BuildContext context, String imagePath) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('预览')),
          body: PhotoView(
            imageProvider: FileImage(File(imagePath)),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          ),
        ),
      ),
    );
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
                    : width;
                return GestureDetector(
                  onTap: () => _showFullImage(context, path),
                  child: Padding(
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
                  ),
                );
              },
            )
        ],
      ),
    );
  }

  Future<Size> _getImageSize(String imagePath) async {
    final image = Image.file(File(imagePath)).image.resolve(ImageConfiguration());
    final Completer<Size> completer = Completer<Size>();
    image.addListener(ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(Size(info.image.width.toDouble(), info.image.height.toDouble()));
    }));
    return completer.future;
  }

  Future<void> requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) status = await Permission.storage.request();
    status = await Permission.manageExternalStorage.status;
    if (!status.isGranted) status = await Permission.manageExternalStorage.request();
  }
}
