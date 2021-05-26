//
//  YYTextField+Api.swift
//  flutter_text_field
//
//  Created by lionel.hong on 2021/5/25.
//

import Foundation


extension NativeTextField {
    
    func updateFocus(focus: Bool) {
        channel.invokeMethod("updateFocus", arguments: focus)
    }
    
    func updateValue() {
    }
    
    func updateText(text: String) {
        channel.invokeMethod("updateText", arguments: text)
    }
    
    func submitText() {
        channel.invokeMethod("submitText", arguments: textField.text)
    }
    
    func setText(text: String) {
        textField.text = text
    }
    
}
