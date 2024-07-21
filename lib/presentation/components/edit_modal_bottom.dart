import 'package:flutter/material.dart';

class EditModalBottom extends StatelessWidget {
  final VoidCallback onChange;
  final String change;
  final String delete;
  final VoidCallback onDelete;

  const EditModalBottom(
      {super.key,
      required this.onChange,
      required this.change,
      required this.delete,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        Material(
            child: InkWell(
                onTap: onChange,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey))),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.settings,
                        size: 32,
                      ),
                      Expanded(
                          child: Container(
                              padding: const EdgeInsets.only(left: 32),
                              child: Text(change,
                                  style: const TextStyle(fontSize: 32))))
                    ],
                  ),
                ))),
        Material(
            child: InkWell(
          onTap: onDelete,
          child: Container(
            padding: const EdgeInsets.all(32),
            child: Row(
              children: [
                const Icon(
                  Icons.delete,
                  size: 32,
                ),
                Expanded(
                    child: Container(
                        padding: const EdgeInsets.only(left: 32),
                        child:
                            Text(delete, style: const TextStyle(fontSize: 32))))
              ],
            ),
          ),
        )),
      ],
    );
  }
}
