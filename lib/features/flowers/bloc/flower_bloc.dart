import 'package:flutter/material.dart';

class FlowerBloc extends ChangeNotifier {
  FlowerBloc();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController recipientController = TextEditingController();
  final TextEditingController dedicationController = TextEditingController();

  void reset() {
    nameController.clear();
    recipientController.clear();
    dedicationController.clear();
    notifyListeners();
  }
}
