import 'dart:io';

import 'package:flutter/material.dart';

class PostFormProvider with ChangeNotifier {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  File? imageFile;

  void setImageFile(File? file) {
    imageFile = file;
    notifyListeners();
  }
  void clearFields() {
    titleController.clear();
    descriptionController.clear();
    imageFile = null;
    notifyListeners();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}