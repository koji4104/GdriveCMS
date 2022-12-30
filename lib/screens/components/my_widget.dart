import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MyCircleIconButton extends ConsumerWidget {
  late Icon icon;
  void Function()? onPressed;
  MyCircleIconButton({required Icon icon, void Function()? onPressed}){
    this.icon = icon;
    this.onPressed = onPressed;
  }
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CircleAvatar(
      backgroundColor:Colors.blueAccent,
      radius:18.0,
      child:IconButton(
        icon:icon,
        iconSize:21.0,
        color:Colors.white,
        onPressed:onPressed,
      )
    );
  }
}