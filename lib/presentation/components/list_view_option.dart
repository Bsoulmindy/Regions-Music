import 'package:flutter/material.dart';

class ListViewOption extends StatelessWidget {
  final String text;
  final VoidCallback onLongPress;
  final VoidCallback onTap;

  const ListViewOption({
    super.key,
    required this.text,
    required this.onLongPress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
              child: Container(
            margin: const EdgeInsets.all(8),
            decoration:
                BoxDecoration(border: Border.all(color: Colors.grey, width: 2)),
            child: Material(
                child: InkWell(
              onLongPress: onLongPress,
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Text(
                  text,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            )),
          )),
        ],
      ),
    );
  }
}
