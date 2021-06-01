// You have generated a new plugin project without
// specifying the `--platforms` flag. A plugin project supports no platforms is generated.
// To add platforms, run `flutter create -t plugin --platforms <platforms> .` under the same
// directory. You can also find a detailed instruction on how to add platforms in the `pubspec.yaml` at https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';


class NativeTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String text;
  final TextStyle textStyle;
  final String placeHolder;
  final TextStyle placeHolderStyle;
  final int maxLength;
  final TextAlign textAlign;
  final TextInputType keyboardType; // 支持的类型是 .text/.number/.phone/.emailAddress
  final double width;
  final double height;
  final String allowRegExp;
  final VoidCallback onEditingComplete;
  final Function(String) onSubmitted;
  final Function(String) onChanged;
  final bool autoFocus;
  final bool readOnly;
  final double maxLines;


  const NativeTextField({
    this.controller,
    this.focusNode,
    this.text = '',
    this.textStyle,
    this.placeHolder = '',
    this.placeHolderStyle,
    this.maxLength = 5000,
    this.textAlign = TextAlign.start,
    this.width,
    this.height,
    this.onEditingComplete,
    this.onSubmitted,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.allowRegExp,
    this.maxLines = 1,
    this.autoFocus = false,
    this.readOnly = false,
  });

  @override
  _NativeTextFieldState createState() => _NativeTextFieldState();
}

class _NativeTextFieldState extends State<NativeTextField> {

  MethodChannel _channel;
  TextEditingController _controller;
  FocusNode _focusNode;
  Set _updateMap = {};

  Map createParams() {
    return {
      'width': widget.width ?? MediaQuery
          .of(context)
          .size
          .width,
      'height': widget.height ?? 40,
      'text': widget.text,
      'textStyle': {
        'color': (widget.textStyle?.color ?? Colors.black).value,
        'fontSize': widget.textStyle.fontSize,
        'height': widget.textStyle.height ?? 1.17
      },
      'placeHolder': widget.placeHolder,
      'placeHolderStyle': {
        'color': (widget.placeHolderStyle?.color ?? Colors.black).value,
        'fontSize': widget.placeHolderStyle.fontSize,
        'height': widget.placeHolderStyle.height ?? 1.35
      },
      'textAlign': widget.textAlign.toString(),
      'maxLength': widget.maxLength,
      'done': widget.onEditingComplete != null || widget.onSubmitted != null,
      'keyboardType': widget.keyboardType.toJson()['name'],
      'allowRegExp': widget.allowRegExp,
      'readOnly': widget.readOnly,
      'maxLines': widget.maxLines
    };
  }

  @override
  void initState() {
    if (widget.autoFocus)
      Future.delayed(const Duration(milliseconds: 300)).then((_) {
        _channel?.invokeMethod('updateFocus', true);
      });

    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();

    if (_controller.text.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 300)).then((value) {
        _channel.invokeMethod('setText', _controller.text);
      });
    }

    _controller.addListener(() {
      final text = _controller.text;
      if (_updateMap.contains(text)) {
        _updateMap.remove(text);
        return;
      }
      _channel.invokeMethod('setText', _controller.text);
    });
    super.initState();
  }

  Future<void> _handlerCall(MethodCall call) async {
    switch (call.method) {
      case 'updateFocus':
        final focus = call.arguments ?? false;
        if (focus) {
          _focusNode.requestFocus();
        } else {
          _focusNode.unfocus();
        }
        break;
      case 'updateText':
        final text = call.arguments ?? '';
        widget.onChanged?.call(text);
        _updateMap.add(text);
        _controller.text = text;
        break;
      case 'submitText':
        final text = call.arguments ?? '';
        widget.onSubmitted?.call(text);
        widget.onEditingComplete?.call();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return SizedBox(
        height: widget.height ?? 40,
        child: Focus(
          focusNode: _focusNode,
          onFocusChange: (focus) {
            _channel.invokeMethod('updateFocus', focus);
          },
          child: UiKitView(
            viewType: "com.fanbook.native_textfield",
            creationParams: createParams(),
            creationParamsCodec: const StandardMessageCodec(),
            onPlatformViewCreated: (viewId) {
              _channel = MethodChannel('com.fanbook.native_textfield_$viewId');
              _channel.setMethodCallHandler(_handlerCall);
            },
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
              new Factory<OneSequenceGestureRecognizer>(
                    () => new EagerGestureRecognizer(),
              ),
            ].toSet(),
          ),
        ),
      );
    }
    return Text('暂不支持该平台');
  }
}
