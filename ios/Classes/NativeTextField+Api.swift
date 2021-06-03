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
        channel.invokeMethod("submitText", arguments: textField?.text ?? textView.text)
    }
    
    func setText(text: String) {
        if textField != nil {
            textField.text = text
        } else {
            let needSetPlaceholder = textView.text.isEmpty || text.isEmpty;
            textView.text = text
            if needSetPlaceholder {
                textView.attributedPlaceholder = textView.attributedPlaceholder
            }
        }
    }
    
}
