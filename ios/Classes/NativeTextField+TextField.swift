//
//  NativeTextField+TextField.swift
//  native_text_field
//
//  Created by lionel.hong on 2021/6/1.
//

import Foundation

extension NativeTextField: UITextFieldDelegate {
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
        let cursorColor = (args?["cursorColor"] as? Int) ?? 0

        defaultAttributes = textStyle2Attribute(textStyle: textStyle, defaultAttr: defaultAttributes)
        let placeHolderStyleAttr = textStyle2Attribute(textStyle: placeHolderStyle, defaultAttr: defaultAttributes)

        textField = UITextField(frame: frame)
        textField.attributedText = NSMutableAttributedString(string: initText, attributes: defaultAttributes)
        textField.delegate = self
        textField.font = defaultAttributes[.font] as? UIFont
        textField.tintColor = UIColor(color: cursorColor)
        textField.textColor = defaultAttributes[.foregroundColor] as? UIColor ?? UIColor.black
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
        let selectedRange = textField.markedTextRange
        let position = textField.position(from: selectedRange?.start ?? UITextPosition(), offset: 0)

        // ??????????????????
        if selectedRange != nil && position != nil {
            return
        }

        let textContent: String = textField.text!
        let len = textContent.count
        if len > maxLength {
            let reqIndex = textContent.index(textContent.startIndex, offsetBy: maxLength)
            setText(text: String(textContent[..<reqIndex]))
        }
        updateText(text: textField.text ?? "")
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString text: String) -> Bool {
        /// ?????? ?????? ????????????
        if text == "\n" && textField.returnKeyType == .done {
            submitText()
            return false
        }

        /// ?????????????????????
        if text.isEmpty {
            return true
        }

        /// ????????????????????????
        if allowRegExp.count > 0 {
            let re = try? NSRegularExpression(pattern: allowRegExp, options: NSRegularExpression.Options.caseInsensitive)
            let count = re?.matches(in: text, options: NSRegularExpression.MatchingOptions.withoutAnchoringBounds, range: NSRange(location: 0, length: text.count)).count ?? 0
            if count != text.count { return false }
        }

        let markedTextRange = textField.markedTextRange
        let position = textField.position(from: markedTextRange?.start ?? UITextPosition(), offset: 0)

        // ??????????????????
        if markedTextRange != nil && position != nil {
            return true
        }

        textField.typingAttributes = defaultAttributes

//        let comcatstr = textField.text.replacingCharacters(in: Range(range, in: textField.text!)!, with: text)
        var comcatstr = "";
        if let b_text = textField.text,
            let textRange = Range(range, in: b_text) {
            comcatstr = b_text.replacingCharacters(in: textRange,with: text)
        }
        let canInputLen = maxLength - comcatstr.count

        if canInputLen >= 0 {
            return true
        } else {
            let len = text.count + canInputLen
            // ?????????text.length + caninputlen < 0????????????rg.length?????????????????????????????????
            let rg = NSRange(location: 0, length: max(len, 0))

            if rg.length > 0 {
                var tempStr: String = ""
                // ?????????????????????????????????asc???(???????????????????????????false)
                let canBeASC: Bool = text.canBeConverted(to: String.Encoding.ascii)
                if canBeASC {
                    let textIndex = text.index(text.startIndex, offsetBy: rg.length)
                    tempStr = String(text[..<textIndex]) // ?????????ascii?????????????????????????????????
                } else {
                    var tempStrIndex = 0
                    var trimString = "" // ??????????????????
                    let range = text.startIndex ..< text.endIndex

                    // ?????????????????????????????????????????????????????????emoji????????????unicode????????????
                    text.enumerateSubstrings(in: range, options: String.EnumerationOptions.byComposedCharacterSequences) { substring, _, _, stop in
                        if tempStrIndex >= rg.length {
                            stop = true
                            return
                        }
                        if substring == nil {
                            return
                        }
                        trimString = trimString.appending(substring!)
                        tempStrIndex += 1
                    }

                    tempStr = trimString
                }
                // rang??????????????????????????????????????????(??????????????????????????????????????????true?????????didchange??????)
                setText(text: textField.text!.replacingCharacters(in: Range(range, in: textField.text!)!, with: tempStr))
                DispatchQueue.main.async {
                    textField.selectedTextRange = textField.textRange(from: textField.endOfDocument, to: textField.endOfDocument)
                    self.updateText(text: textField.text!)
                }
            }
            return false
        }
    }
}
