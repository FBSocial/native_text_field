//
//  NativeTextField+TextField.swift
//  native_text_field
//
//  Created by lionel.hong on 2021/6/1.
//

import Foundation

extension NativeTextField : UITextFieldDelegate {
    
    func initTextField(frame: CGRect, args: [String: Any]?) {
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
        
        textField = UITextField(frame: frame)
        textField.attributedText = NSMutableAttributedString(string: initText,attributes: defaultAttributes)
        textField.delegate = self
        textField.font = defaultAttributes[.font] as? UIFont
        textField.textColor = defaultAttributes[.foregroundColor] as? UIColor ?? UIColor.black
        textField.textAlignment = string2textAlignment(str: textAlign)
        textField.backgroundColor = UIColor.clear
        textField.keyboardType = string2KeyboardType(str: keyboardType)
        textField.attributedPlaceholder = NSAttributedString(string: placeHolder, attributes: placeHolderStyleAttr)
        textField.isUserInteractionEnabled = !readOnly
        self.maxLength = maxLength
        self.allowRegExp = allowRegExp
        if done { textField.returnKeyType = .done }
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        textField.typingAttributes = defaultAttributes
        if allowRegExp.count > 0 {
            let re = try? NSRegularExpression(pattern: allowRegExp, options: NSRegularExpression.Options.caseInsensitive)
            let count = re?.matches(in: string, options: NSRegularExpression.MatchingOptions.withoutAnchoringBounds, range: NSRange(location: 0, length: string.count)).count ?? 0
            if count != string.count { return false }
        }
        
        if let text = textField.text, let _range = Range(range, in: text) {
            let newText = text.replacingCharacters(in: _range, with: string)
            if maxLength != 0 && newText.count > maxLength {
                let canInputLength = maxLength - textField.text!.count + range.length
                if canInputLength > 0 {
                    let value = text.replacingCharacters(in: _range, with: string.prefix(canInputLength))
                    textField.text = value
                    updateText(text: value)
                }
                return false
            }
            updateText(text: newText)
        }
        return true
    }
}
