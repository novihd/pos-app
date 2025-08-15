import 'package:flutter/material.dart';

class UIHelper {
  static void showSnackBar({required BuildContext context, required String message, required Color color}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }
}