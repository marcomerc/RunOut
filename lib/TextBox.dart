import 'package:flutter/material.dart';


class TextBox extends StatelessWidget {
  TextEditingController _text;

  TextBox(TextEditingController distance){
    _text=distance;

  }


  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      color: Colors.white,
      child: TextField(
        controller: _text,
        decoration:
        InputDecoration(border: InputBorder.none, hintText: 'Distance'),
      ),
    );
  }
}