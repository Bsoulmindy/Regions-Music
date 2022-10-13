import 'package:flutter/material.dart';

void showMessage(Exception e, BuildContext context) {
  showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
            title: const Icon(Icons.info),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.75,
              child: Text(e.toString()),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, 'OK'),
                child: const Text('OK'),
              ),
            ],
          ));
}
