import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../MODELS/commentModel.dart';

final baseUrl = dotenv.env['BACKEND_URL'];
class CommentsProvider extends ChangeNotifier{

  List<Comment> _comments = [];
  bool _isLoading = false;

  List<Comment> get comments => _comments; // get method to make _post read only accessible outside because it is made private here
  bool get isLoading => _isLoading;

  Future<void> fetchComments(String postID) async{
    _isLoading = true;
    notifyListeners();
    var response = await http.get(Uri.parse('$baseUrl/comment/$postID'));

    if(response.statusCode == 200 || response.statusCode == 201){
      List<dynamic> data = jsonDecode(response.body);
      _comments = data.map((item) => Comment.fromJson(item)).toList();
    }
    else{
      _comments = [];
    }

    _isLoading = false;
    notifyListeners();

  }

  void clearComments(){
    _comments = [];
    notifyListeners();
  }

}