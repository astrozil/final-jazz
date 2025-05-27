
import 'package:flutter/material.dart';

Widget buildHandleBar() {
  return Container(
    margin: const EdgeInsets.only(top: 8),
    height: 4,
    width: 40,
    decoration: BoxDecoration(
      color: Colors.grey[300],
      borderRadius: BorderRadius.circular(2),
    ),
  );
}