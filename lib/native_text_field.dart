// You have generated a new plugin project without
// specifying the `--platforms` flag. A plugin project supports no platforms is generated.
// To add platforms, run `flutter create -t plugin --platforms <platforms> .` under the same
// directory. You can also find a detailed instruction on how to add platforms in the `pubspec.yaml` at https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class NativeTextFieldController {
  MethodChannel channel;

  NativeTextFieldController({this.channel});

  void updateFocus(bool focus) {
    channel?.invokeMethod('updateFocus', focus);
  }
}

class NativeTextField extends StatefulWidget {
  final TextEditingController controller;
  final NativeTextFieldController nativeController;
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
  final int maxLines;
  final Color cursorColor;
  final bool disableFocusNodeListener; // 禁用focusNode的listener监听
  final bool disableGesture;

  const NativeTextField({
    this.controller,
    this.nativeController,
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
    this.cursorColor,
    this.autoFocus = false,
    this.readOnly = false,
    this.disableFocusNodeListener = false,
    this.disableGesture = false,
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
        'height': widget.textStyle.height ?? 1.17,
        'fontWeight':
        widget?.textStyle?.fontWeight?.index ?? FontWeight.normal.index,
      },
      'placeHolder': widget.placeHolder,
      'placeHolderStyle': {
        'color': (widget.placeHolderStyle?.color ?? Colors.black).value,
        'fontSize': widget.placeHolderStyle.fontSize,
        'height': widget.placeHolderStyle.height ?? 1.35,
        'fontWeight': widget?.placeHolderStyle?.fontWeight?.index ??
            FontWeight.normal.index,
      },
      'textAlign': widget.textAlign.toString(),
      'maxLength': widget.maxLength,
      'done': widget.onEditingComplete != null || widget.onSubmitted != null,
      'keyboardType': widget.keyboardType.toJson()['name'],
      'allowRegExp': widget.allowRegExp,
      'readOnly': widget.readOnly,
      'maxLines': widget.maxLines,
      'cursorColor': (widget.cursorColor ?? Colors.black).value,
    };
  }

  bool shouldFocus = false;

  @override
  void initState() {
    shouldFocus = widget.autoFocus;
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
        if (widget.disableFocusNodeListener) return;
        if (focus) {
          _focusNode.requestFocus();
        } else {
          _focusNode.unfocus();
        }
        break;
      case 'updateText':
        final text = call.arguments ?? '';
        _updateMap.add(text);
        _controller.text = text;
        widget.onChanged?.call(text);
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
    final gestureRecognizers = widget.disableGesture
        ? null
        : <Factory<OneSequenceGestureRecognizer>>[
      new Factory<OneSequenceGestureRecognizer>(
            () => new EagerGestureRecognizer(),
      ),
    ].toSet();
    if (Platform.isIOS) {
      return SizedBox(
        height: widget.height ?? 40,
        child: Focus(
          focusNode: _focusNode,
          onFocusChange: (focus) {
            if (_channel == null) {
              shouldFocus = _focusNode.hasFocus;
            }
            _channel?.invokeMethod('updateFocus', focus);
          },
          child: UiKitView(
            viewType: "com.fanbook.native_textfield",
            creationParams: createParams(),
            creationParamsCodec: const StandardMessageCodec(),
            onPlatformViewCreated: (viewId) async {
              _channel = MethodChannel('com.fanbook.native_textfield_$viewId');
              if (widget.nativeController != null)
                widget.nativeController.channel = _channel;
              _channel.setMethodCallHandler(_handlerCall);
              _channel.invokeMethod(
                  'updateFocus', shouldFocus || widget.autoFocus);
            },
            gestureRecognizers: gestureRecognizers,
          ),
        ),
      );
    } else if (Platform.isAndroid) {
      return SizedBox(
        height: widget.height ?? 40,
        child: Focus(
          focusNode: _focusNode,
          onFocusChange: (focus) {
            if (_channel == null) {
              shouldFocus = _focusNode.hasFocus;
            }
            _channel?.invokeMethod('updateFocus', focus);
          },
          child: PlatformViewLink(
            viewType: "com.fanbook.native_textfield",
            surfaceFactory: (context, controller) {
              return AndroidViewSurface(
                controller: controller,
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                  new Factory<OneSequenceGestureRecognizer>(
                        () => new EagerGestureRecognizer(),
                  ),
                ].toSet(),
                hitTestBehavior: PlatformViewHitTestBehavior.opaque,
              );
            },
            onCreatePlatformView: (params) {
              params.onPlatformViewCreated(params.id);
              return PlatformViewsService.initSurfaceAndroidView(
                id: params.id,
                viewType: "com.fanbook.native_textfield",
                layoutDirection: TextDirection.ltr,
                creationParams: createParams(),
                creationParamsCodec: const StandardMessageCodec(),
              )
                ..addOnPlatformViewCreatedListener((id) {
                  _channel = MethodChannel('com.fanbook.native_textfield_$id');
                  if (widget.nativeController != null)
                    widget.nativeController.channel = _channel;
                  _channel.setMethodCallHandler(_handlerCall);
                  Future.delayed(const Duration(milliseconds: 300))
                      .then((value) {
                    _channel.invokeMethod(
                        'updateFocus', shouldFocus || widget.autoFocus);
                  });
                })
                ..create();
            },
          ),
        ),
      );
    }
    return Text('暂不支持该平台');
  }
}
