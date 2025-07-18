import 'dart:io';


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slide_to_act/slide_to_act.dart';
import '../COMPONENTS/text_field.dart';

import '../PROVIDERS/post_form_provider.dart';
import '../services/uploadPost.dart';
import 'package:image_picker/image_picker.dart';

class addPost extends StatefulWidget {
  final String? token;
  const addPost({super.key, required this.token});

  @override
  State<addPost> createState() => _addPostState();
}

class _addPostState extends State<addPost> {

  Future<void> pickImage() async {

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final formProvider = Provider.of<PostFormProvider>(context, listen: false);
      formProvider.setImageFile(File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final formProvider = Provider.of<PostFormProvider>(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.blue,
          backgroundColor: Colors.blue.withAlpha(12),
          title: const Text(
            "Create New Post",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/background.png',
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    MyTextField(
                      hintText: 'Title',
                      controller: formProvider.titleController,
                      icon: Icons.title,
                      maxlines: 0,
                    ),
                    const SizedBox(height: 12),
                    MyTextField(
                      hintText: 'Description',
                      controller: formProvider.descriptionController,
                      icon: Icons.line_style,
                      maxlines: 5,
                    ),
                    const SizedBox(height: 40),

                    /// ✅ Image Upload Section in White Box
                    Padding(
                      padding: const EdgeInsets.fromLTRB(32.0, 0.0, 0.0 ,0.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.84,
                        height: 220,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white, width: 5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Add an Image (optional):", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                            const SizedBox(height: 12),
                            formProvider.imageFile == null
                                ? Center(
                              child: OutlinedButton.icon(
                                onPressed: pickImage,
                                icon: Icon(Icons.photo),
                                label: Text("Choose from Gallery"),
                              ),
                            )
                                : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    formProvider.imageFile!,
                                    height: 90,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextButton.icon(
                                  onPressed: () => formProvider.setImageFile(null),
                                  icon: Icon(Icons.delete_outline, color: Colors.red),
                                  label: Text(
                                    "Remove Image",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),


                    const SizedBox(height: 100),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            await uploadPost(context, formProvider, false, widget.token);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade300,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text("Save as Draft"),
                        ),
                        const SizedBox(width: 20),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: SlideAction(
                            text: "Create Post",
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            innerColor: Colors.white,
                            outerColor: Colors.deepPurple,
                            sliderButtonIcon: const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.deepPurple,
                              size: 12,
                            ),
                            elevation: 2,
                            borderRadius: 12,
                            animationDuration: const Duration(milliseconds: 500),
                            onSubmit: () async {
                              await uploadPost(context, formProvider, true, widget.token);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
      ),
    );
  }
}