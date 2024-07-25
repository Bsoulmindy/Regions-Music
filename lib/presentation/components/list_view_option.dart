import 'package:flutter/material.dart';

class ListViewOption extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Widget leading;
  final Widget? trailing;

  const ListViewOption({
    super.key,
    required this.text,
    required this.onTap,
    required this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      trailing: trailing,
      title: Text(text, style: const TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }
}
