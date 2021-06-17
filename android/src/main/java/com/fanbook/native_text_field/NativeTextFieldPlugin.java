package com.fanbook.native_text_field;

import androidx.annotation.NonNull;

import com.fanbook.native_text_field.editview.NativeTextFieldFactory;

import io.flutter.embedding.engine.plugins.FlutterPlugin;

/**
 * NativeTextFieldPlugin
 */
public class NativeTextFieldPlugin implements FlutterPlugin {
    public static final String VIEW_TYPE_ID = "com.fanbook.native_textfield";

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        flutterPluginBinding
                .getPlatformViewRegistry()
                .registerViewFactory(VIEW_TYPE_ID, new NativeTextFieldFactory(flutterPluginBinding.getBinaryMessenger()));
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    }
}
