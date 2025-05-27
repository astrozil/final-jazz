
import 'package:flutter/material.dart';

Future<T?> showCustomBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
  BorderRadius borderRadius = const BorderRadius.vertical(top: Radius.circular(20)),
  Color? backgroundColor,
  double? elevation,
  bool isDismissible = true,
  bool enableDrag = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    backgroundColor: backgroundColor,
    elevation: elevation,
    shape: RoundedRectangleBorder(
      borderRadius: borderRadius,
    ),
    builder: builder,
  );
}
