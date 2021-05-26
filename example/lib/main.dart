import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:native_text_field/native_text_field.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  TextEditingController _controller = TextEditingController();
  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: NativeTextField(
            controller: _controller,
            focusNode: _focusNode,
            text: '1233',
            autoFocus: true,
            textStyle: Theme.of(context)
                .textTheme
                .bodyText2
                .copyWith(color: Colors.black, fontSize: 14),
            placeHolder: '请输入....',
            placeHolderStyle: Theme.of(context)
                .textTheme
                .bodyText1
                .copyWith(color: Colors.redAccent, fontSize: 18),
            maxLength: 5000,
            onChanged: (str) {
              print('onChanged: $str');
            },
            onSubmitted: (str) {
              print('onSubmitted: $str');
            },
            onEditingComplete: () {
              print('onEditingComplete');
            },
          ),
        ),
      ),
    );
  }
}
