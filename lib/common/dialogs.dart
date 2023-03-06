import 'package:flutter/material.dart';

void showErrorDialog(String err, BuildContext context)  {
  showDialog(context: context, builder: (ctx) {
    return AlertDialog(
      title: const Text("Oops"),
      content: Text(err.toString()),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("OKKK"),
        )
      ],
    );
  });
}