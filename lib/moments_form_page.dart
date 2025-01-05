import 'dart:async';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'database_helper.dart';

class MomentsFormPage extends StatefulWidget {
  final Map<String, dynamic>? moments;

  const MomentsFormPage({super.key, this.moments});

  @override
  State<MomentsFormPage> createState() => _StudentFormPageState();
}

class _StudentFormPageState extends State<MomentsFormPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController textController = TextEditingController();
  List<String>? _imagePaths; // 用于存储图片路径

  @override
  void initState() {
    super.initState();
    if (widget.moments != null) {
      textController.text = widget.moments!['texts'];
      _imagePaths = widget.moments!['pictures'].split(',');
    }
  }

  void _updateImagePaths(List<String> imagePaths) {
    setState(() {
      _imagePaths = imagePaths;
    });
  }

  _saveMoments() async {
    if (_formKey.currentState!.validate()) {
      DateTime dateTime = DateTime.now();
      // 将图片路径列表转换为以逗号分隔的字符串
      String pictures = _imagePaths?.join(',') ?? '';

      Map<String, dynamic> moments = {
        'texts': textController.text,
        'time': dateTime.toString().substring(0, 19),
        'pictures': pictures, // 保存逗号分隔的图片路径字符串
      };

      if (widget.moments == null) {
        await DatabaseHelper().insert(moments);
      } else {
        await DatabaseHelper().update(widget.moments!['id'], moments);
      }

      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moments Form'),
        backgroundColor: Colors.grey, // Customize the app bar color
        iconTheme: const IconThemeData(color: Colors.white), // Set the back arrow color to white
        titleTextStyle: const TextStyle(color: Colors.white,
          fontSize: 20,
        ),
        actions: [
          ElevatedButton(
            onPressed: _saveMoments,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade400, // Customize button color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0), // Rounded corners for the button
              ),
            ),
            child: const Text('完成',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.all(5)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView( // Allows scrolling if the keyboard appears
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, // Makes sure the form fields stretch across the screen
              children: [
                const Padding(padding: EdgeInsets.all(4.0)),
                TextFormField(
                  maxLines: 99,
                  minLines: 1,
                  controller: textController,
                  decoration: const InputDecoration(
                    labelText: 'Texts',
                    // prefixIcon: Icon(Icons.text_fields),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入文本';
                    }
                    return null;
                  },
                ),
                const Padding(padding: EdgeInsets.all(2)),
                ImageGrid(onImagePathsUpdated: _updateImagePaths),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ImageGrid extends StatefulWidget {
  final Function(List<String>) onImagePathsUpdated; // 回调函数

  const ImageGrid({super.key, required this.onImagePathsUpdated});

  @override
  State<ImageGrid> createState() => _ImageGridState();
}

class _ImageGridState extends State<ImageGrid> {
  List<XFile>? _imageFiles; // 用于存储选择的图片文件

  // 打开图片选择器
  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _imageFiles = images;
      });
      // 更新图片路径
      widget.onImagePathsUpdated(images.map((image) => image.path).toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            ElevatedButton(
              onPressed: _pickImages,
              style: ElevatedButton.styleFrom(// Customize button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0), // Rounded corners for the button
                ),
              ),
              child: const Text('选择图片',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: _imageFiles?.length.toDouble()==null?40:(_imageFiles!.length.toDouble()/3.floor()+1)*100,
          child: GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 每行显示3个图片
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: _imageFiles?.length ?? 0,
            itemBuilder: (context, index) {
              // 定义一个变量来存储图片文件
              final imageFile = File(_imageFiles![index].path);
              // 异步获取图片尺寸
              Future<Size> getImageSize() async {
                final image = Image.file(imageFile);
                final Completer<Size> completer = Completer();
                image.image.resolve(ImageConfiguration.empty).addListener(
                  ImageStreamListener(
                        (ImageInfo info, bool _) {
                      completer.complete(Size(info.image.width.toDouble(), info.image.height.toDouble()));
                    },
                  ),
                );
                return completer.future;
              }
              return FutureBuilder<Size>(
                future: getImageSize(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                    // 获取缩放后的尺寸
                    final Size size = snapshot.data!;
                    final int cacheWidth = (size.width / 1).toInt();
                    final int cacheHeight = (size.height / 1).toInt();

                    // 返回缩放后的图片
                    return Image.file(
                      imageFile,
                      fit: BoxFit.cover,
                      cacheWidth: cacheWidth,
                      cacheHeight: cacheHeight,
                    );
                  } else {
                    // 图片尺寸正在加载，显示占位符
                    return const Placeholder();
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
