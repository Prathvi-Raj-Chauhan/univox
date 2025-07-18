import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:convert';

import '../MODELS/postModel.dart';


final baseUrl = "https://univox-backend-r0u6.onrender.com";
class PostProvider with ChangeNotifier {
  List<Post> _posts = [];
  bool _isLoading = false;

  List<Post> get posts => _posts; // get method to make _post read only accessible outside because it is made private here
  bool get isLoading => _isLoading;

  Future<void> fetchPosts() async {
    _isLoading = true;
    notifyListeners();

    try {
      var response = await http.get(Uri.parse('$baseUrl/post/'));

      if (response.statusCode == 200 || response.statusCode == 201) {
        List<dynamic> data = jsonDecode(response.body); // we get json response from backend each object is stored in list of json which we have decoded here in list named data
        _posts = data.map((item) => Post.fromJson(item)).toList(); // now in data we iterate through each item in the list. Post.fromJson(item): Converts each JSON map into a Post object using your Post.fromJson() (factory constructor).toList(): Collects the converted Post objects into a new List<Post>, which is stored in _posts.

      } else {
        _posts = [];
        // You can log or handle errors here
      }
    } catch (e) {
      _posts = [];
      // Handle error (network, parsing etc.)
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearPosts() {
    _posts = [];
    notifyListeners();
  }

  Future<void> upvotePost(String postId, String token) async {
    final userId = JwtDecoder.decode(token)['_id'];
    final res = await http.post(
      Uri.parse('$baseUrl/post/upvote/$postId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId}),
    );
    if (res.statusCode == 200) {
      final updatedPost = Post.fromJson(json.decode(res.body));
      updatePost(updatedPost); // 🔁 only update the one post // // took chat gpt help
      // await fetchPosts(); // or update post in-place
    } else {
      print('Upvote failed: ${res.body}');
    }
    notifyListeners();
  }

  Future<void> downvotePost(String postId, String token) async {
    final userId = JwtDecoder.decode(token)['_id'];
    final res = await http.post(
      Uri.parse('$baseUrl/post/downvote/$postId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId}),
    );
    if (res.statusCode == 200) {
      final updatedPost = Post.fromJson(json.decode(res.body));
      updatePost(updatedPost); // 🔁 only update the one post // took chat gpt help
      // await fetchPosts();
    } else {
      print('Downvote failed: ${res.body}');
    }
    notifyListeners();
  }

  void updatePost(Post updatedPost) { //Instead of setting the whole list again or doing a full refresh in fetchPosts, update only the relevant post in-place after upvote/downvote:
    final index = _posts.indexWhere((p) => p.id == updatedPost.id);
    if (index != -1) { // took chat gpt help
      _posts[index] = updatedPost;
      notifyListeners(); // ✅ triggers rebuild only for affected widgets (with correct keys)
    }
  }

}
