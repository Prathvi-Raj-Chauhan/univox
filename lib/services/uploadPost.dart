

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';




import '../MODELS/postModel.dart';
import '../PAGES/post_page.dart';
import '../PROVIDERS/post_form_provider.dart';

final baseUrl = "https://univox-backend-r0u6.onrender.com";

Future<void> uploadPost(BuildContext context, PostFormProvider formProvider, bool isPublished, String? token) async {
  Map<String, dynamic> decodedToken = JwtDecoder.decode(token ?? '');
  final uri = Uri.parse("$baseUrl/post/");
  final request = http.MultipartRequest("POST", uri);
  request.fields['createdBy'] = decodedToken['_id'];
  request.fields['title'] = formProvider.titleController.text;
  request.fields['postContent'] = formProvider.descriptionController.text;
  request.fields['isPublic'] = isPublished.toString();

  if (formProvider.imageFile != null) {
    final image = await http.MultipartFile.fromPath(
      'coverImage',
      formProvider.imageFile!.path,
    );
    request.files.add(image);
  }

  try{
    final response = await request.send();
    final resBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final json = jsonDecode(resBody);
      final newPost = json['post']; // contains the full post from server

      formProvider.clearFields();

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PostPage(
            post: Post.fromJson(newPost),
            token: token,
          ),
        ),
      );


    }
    else if (response.statusCode == 400) {
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              title: Text('Missing Fields'),
              content: Text("Some Fields are missing"),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context), child: Text("OK")),
              ],
            ),
      );

      formProvider.clearFields();
    }
    else{
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Uploading Failed"),
          content: Text("Some Error Occured"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("OK")),
          ],
        ),
      );
    }
  }catch(_){
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Network Error"),
        content: Text("Could not connect to server"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("OK")),
        ],
      ),
    );
  }


}
