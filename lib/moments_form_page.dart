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

  @override
  void initState() {
    super.initState();
    if (widget.moments != null) {
      textController.text = widget.moments!['texts'];
    }
  }

  _saveMoments() async {
    if (_formKey.currentState!.validate()) {
      DateTime dateTime = DateTime.now();

      Map<String, dynamic> moments = {
        'texts': textController.text,
        'time': dateTime.toString().substring(0, 19),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
