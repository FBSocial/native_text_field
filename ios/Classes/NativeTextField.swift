//
//  YYTextField.swift
//  Runner
//
//  Created by lionel.hong on 2021/5/11.
//

import Foundation
import Flutter
import UIKit

class NativeTextField : NSObject,FlutterPlatformView {
    
    var viewId:Int64 = -1
    var textField:UITextField!
    var textView:PlaceholderTextView!
    var channel:FlutterMethodChannel!
    var maxLength:Int = 0
    var allowRegExp = ""//" |[a-zA-Z]|[\u{4e00}-\u{9fa5}]|[0-9]"
    
    var defaultAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.light),
        .foregroundColor: UIColor.black,
    ]
    
    init(frame: CGRect, viewId: Int64, args:Any?,  messenger: FlutterBinaryMessenger) {
        // 处理通信
        self.viewId = viewId
        // 页面初始化
        let args = args as? [String: Any]
        var _frame = frame
        if _frame.size.width == 0 {
            let width = (args?["width"] as? CGFloat) ?? UIScreen.main.bounds.size.width
            let height = args?["height"] as? CGFloat
            _frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: width, height: height ?? 40)
        }
        super.init()
        
        channel = FlutterMethodChannel(name: "com.fanbook.native_textfield_\(viewId)", binaryMessenger: messenger)
        channel.setMethodCallHandler { [weak self] (call, result) in
            self?.handlerMethodCall(call, result)
        }
        
        let maxLines = (args?["maxLines"] as? Int) ?? 1
        if maxLines == 1 {
            initTextField(frame: _frame, args: args)
        } else {
            initTextView(frame: _frame, args: args)
        }
        
    }
    
    func handlerMethodCall(_ call: FlutterMethodCall, _ result: FlutterResult)  {
        switch call.method {
        case "updateFocus":
            if let focus = call.arguments as? Bool {
                if focus {
                    (textField ?? textView).becomeFirstResponder()
                } else {
                    (textField ?? textView).resignFirstResponder()
                }
            }
            break
        case "setText":
            if let text = call.arguments as? String , text != textField?.text ?? textView?.text ?? "" {
                print("set: \(text)")
                setText(text: text)
            }
            break
        default:
            break
        }
    }
    
    func view() -> UIView {
        return textField ?? textView
    }

    
    
}

extension NativeTextField : UITextViewDelegate {
    
    func initTextView(frame: CGRect, args: [String: Any]?) {
        let initText = (args?["text"] as? String) ?? ""
        let textStyle = (args?["textStyle"] as? [String: Any])
        let placeHolderStyle = (args?["placeHolderStyle"] as? [String: Any])
        let placeHolder = (args?["placeHolder"] as? String) ?? ""
        let maxLength = (args?["maxLength"] as? Int) ?? 5000
        let done = (args?["done"] as? Bool) ?? false
        let textAlign = args?["textAlign"] as? String
        let keyboardType = args?["keyboardType"] as? String
        let allowRegExp = (args?["allowRegExp"] as? String) ?? ""
        let readOnly = (args?["readOnly"] as? Bool) ?? false
        
        defaultAttributes = textStyle2Attribute(textStyle: textStyle, defaultAttr: defaultAttributes)
        let placeHolderStyleAttr = textStyle2Attribute(textStyle: placeHolderStyle, defaultAttr: defaultAttributes)
        
        
        textView = PlaceholderTextView(frame: frame)
        textView.attributedText = NSMutableAttributedString(string: initText,attributes: defaultAttributes)
        textView.delegate = self
        textView.font = defaultAttributes[.font] as? UIFont
        textView.textAlignment = string2textAlignment(str: textAlign)
        textView.textColor = defaultAttributes[.foregroundColor] as? UIColor ?? UIColor.black
        textView.backgroundColor = UIColor.clear
        textView.keyboardType = string2KeyboardType(str: keyboardType)
        textView.attributedPlaceholder = NSAttributedString(string: placeHolder, attributes: placeHolderStyleAttr)
        textView.isUserInteractionEnabled = !readOnly
        self.maxLength = maxLength
        self.allowRegExp = allowRegExp
        if done { textView.returnKeyType = .done }
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        updateFocus(focus: true)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        updateFocus(focus: false)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updateText(text: textView.text ?? "")
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        textView.typingAttributes = defaultAttributes
        if text == "\n" && textView.returnKeyType == .done {
            submitText()
            return false
        }
        if let _text = textView.text, let _range = Range(range, in: _text) {
            let newText = _text.replacingCharacters(in: _range, with: text)
            if maxLength != 0 && newText.count > maxLength && text.count != 0 {
                let canInputLength = maxLength - textView.text!.count + range.length
                if canInputLength > 0 {
                    let value = _text.replacingCharacters(in: _range, with: text.prefix(canInputLength))
                    textView.text = value
                    updateText(text: value)
                }
                return false
            }
            
        }
        return true
    }
    
    
}

extension NativeTextField {
    func textStyle2Attribute(textStyle :[String: Any]?, defaultAttr :[NSAttributedString.Key: Any]?) -> [NSAttributedString.Key: Any] {
        guard let textStyle = textStyle else {
            return defaultAttr ?? [:]
        }
        let textColorValue = (textStyle["color"] as? Int) ?? 0
        let fontSize = (textStyle["fontSize"] as? Int) ?? 14
        let height = (textStyle["height"] as? Double) ?? 1.17
        let textColor = UIColor.init(color: textColorValue)
        let weight = (textStyle["fontWeight"] as? Int) ?? 3
        
        return [
            .font: UIFont.systemFont(ofSize: CGFloat(fontSize), weight: convertWeight(fontWeight:weight)),
            .foregroundColor: textColor,
        ]
    }
    
    /// Flutter 为 int  Swift 是CGFloat (并且对应的值是完全不一样的,所以要做对应关系)
    func convertWeight( fontWeight:Int) -> UIFont.Weight {
        if fontWeight == 0 {
            return UIFont.Weight.ultraLight
        }else if fontWeight == 1 {
            return UIFont.Weight.thin
        }else if fontWeight == 2 {
            return UIFont.Weight.light
        }else if fontWeight == 3 {
            return UIFont.Weight.regular
        }else if fontWeight == 4 {
            return UIFont.Weight.medium
        }else if fontWeight == 5 {
            return UIFont.Weight.semibold
        }else if fontWeight == 6 {
            return UIFont.Weight.bold
        }else if fontWeight == 7 {
            return UIFont.Weight.heavy
        }else if fontWeight == 8 {
            return UIFont.Weight.black
        }
        return .regular
    }
    
    func string2textAlignment(str: String?) -> NSTextAlignment {
        guard let str = str else {
            return .left
        }
        switch str {
        case "TextAlign.left":
            return .left
        case "TextAlign.right":
            return .right
        case "TextAlign.center":
            return .center
        case "TextAlign.justify":
            return .justified
        case "TextAlign.end":
            return .right
        default:
            return .left
        }
    }
    
    func string2KeyboardType(str: String?) -> UIKeyboardType {
        guard let str = str else {
            return .default
        }
        switch str {
        case "TextInputType.text":
            return .default
        case "TextInputType.number":
            return .numberPad
        case "TextInputType.phone":
            return .phonePad
        case "TextInputType.emailAddress":
            return .emailAddress
        default:
            return .default
        }
    }
    
}
