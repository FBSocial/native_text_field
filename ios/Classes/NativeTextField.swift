//
//  YYTextField.swift
//  Runner
//
//  Created by lionel.hong on 2021/5/11.
//

import Foundation
import Flutter

class NativeTextField : NSObject,FlutterPlatformView, UITextFieldDelegate {
    
    var viewId:Int64 = -1
    var textField:UITextField!
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
            _frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: width, height: 40)
        }
        super.init()
        
        channel = FlutterMethodChannel(name: "com.fanbook.native_textfield_\(viewId)", binaryMessenger: messenger)
        channel.setMethodCallHandler { [weak self] (call, result) in
            self?.handlerMethodCall(call, result)
        }
        
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
        
        textField = UITextField(frame: _frame)
        textField.attributedText = NSMutableAttributedString(string: initText,attributes: defaultAttributes)
        textField.delegate = self
        textField.textAlignment = string2textAlignment(str: textAlign)
        textField.backgroundColor = UIColor.clear
        textField.keyboardType = string2KeyboardType(str: keyboardType)
        textField.attributedPlaceholder = NSAttributedString(string: placeHolder, attributes: placeHolderStyleAttr)
        textField.isUserInteractionEnabled = !readOnly
        
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        self.maxLength = maxLength
        self.allowRegExp = allowRegExp
        if done { textField.returnKeyType = .done }
    }
    
    func handlerMethodCall(_ call: FlutterMethodCall, _ result: FlutterResult)  {
        switch call.method {
        case "updateFocus":
            if let focus = call.arguments as? Bool {
                if focus {
                    textField.becomeFirstResponder()
                } else {
                    textField.resignFirstResponder()
                }
            }
            break
        case "setText":
            if let text = call.arguments as? String , text != textField.text {
                setText(text: text)
            }
            break
        default:
            break
        }
    }
    
    func view() -> UIView {
        return textField
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .done {
            submitText()
            return false
        }
        return true
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateFocus(focus: false)
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        updateFocus(focus: true)
    }
    
    @objc func textFieldDidChange() {
        updateText(text: textField.text ?? "")
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if allowRegExp.count > 0 {
            let re = try? NSRegularExpression(pattern: allowRegExp, options: NSRegularExpression.Options.caseInsensitive)
            let count = re?.matches(in: string, options: NSRegularExpression.MatchingOptions.withoutAnchoringBounds, range: NSRange(location: 0, length: string.count)).count ?? 0
            if count != string.count { return false }
        }
        
        if let text = textField.text, let range = Range(range, in: text) {
            let newText = text.replacingCharacters(in: range, with: string)
            if maxLength != 0 && newText.count > maxLength {
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
        return [
            .font: UIFont.systemFont(ofSize: CGFloat(fontSize)),
            .foregroundColor: textColor,
        ]
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
