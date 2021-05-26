//
//  YYTextFieldPlugin.m
//  flutter_text_field
//
//  Created by lionel.hong on 2021/5/11.
//

#import "NativeTextFieldPlugin.h"
#if __has_include(<native_text_field/native_text_field-Swift.h>)
#import <native_text_field/native_text_field-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "native_text_field-Swift.h"
#endif

@implementation NativeTextFieldPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftYYTextFieldPlugin registerWithRegistrar:registrar];

}

@end
