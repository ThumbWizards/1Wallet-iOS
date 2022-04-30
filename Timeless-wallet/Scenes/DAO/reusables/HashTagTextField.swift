//
//  HashTagTextField.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 07/02/22.
//

import SwiftUI

struct HashTagTextField: UIViewRepresentable {
    typealias UIViewType = UITextField
    @Binding var text: String
    var placeholder: String
    var hashTag: ((String) -> Void)?
    let textField = UITextField()
    @Binding var focusState: Bool

    func makeUIView(context: Context) -> UITextField {
        textField.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textField.textColor = .white
        textField.tintColor = .timelessBlue
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: textField.frame.size.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.textAlignment = .left
        textField.clipsToBounds = true
        textField.text = text
        textField.delegate = context.coordinator
        context.coordinator.addDoneButtonOnKeyboard()
        textField.placeholder = placeholder
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
        if $focusState.wrappedValue == true {
            if !uiView.isFirstResponder {
                //This triggers attribute cycle if not dispatched
                DispatchQueue.main.async {
                    uiView.becomeFirstResponder()
                }
            }
        }
        if context.coordinator.focusState.wrappedValue != $focusState.wrappedValue {
            context.coordinator.focusState = $focusState
        }
    }

    func makeCoordinator() -> HashTagTextField.Coodinator {
        return Coordinator(textBinding: $text,
                           placeHolder: self.placeholder,
                           hashTag: hashTag,
                           textField: textField,
                           focusState: $focusState)
    }

    final class Coodinator: NSObject {
        var textBinding: Binding<String>
        var placeholder: String
        var hashTag: ((String) -> Void)?
        var textField: UITextField
        var focusState: Binding<Bool>

        init(textBinding: Binding<String>,
             placeHolder: String,
             hashTag: ((String) -> Void)?,
             textField: UITextField,
             focusState: Binding<Bool>) {
            self.textBinding = textBinding
            self.placeholder = placeHolder
            self.hashTag = hashTag
            self.textField = textField
            self.focusState = focusState
        }

        func addDoneButtonOnKeyboard() {
            let doneToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
            doneToolbar.barStyle = .default
            let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonAction))
            done.tintColor = .timelessBlue
            let items = [flexSpace, done]
            doneToolbar.items = items
            doneToolbar.sizeToFit()
            textField.inputAccessoryView = doneToolbar
        }

        @objc func doneButtonAction() {
            if !(textField.text ?? "").isEmpty {
                hashTag?(textField.text ?? "")
                textBinding.wrappedValue = ""
            }
            focusState = Binding.constant(false)
            textField.resignFirstResponder()
        }
    }
}

// MARK: - functions
extension HashTagTextField.Coodinator: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if let text = textField.text {
            if string == " " || string == "," {
                if !text.isEmpty {
                    self.textBinding.wrappedValue = ""
                    print("new hashtag--", text)
                    hashTag?(text)
                }
                return false
            } else {
                return true
            }
        }
        return false
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        focusState.wrappedValue = true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        focusState = Binding.constant(false)
        if !(textField.text ?? "").isEmpty {
            self.textBinding.wrappedValue = ""
            hashTag?(textField.text ?? "")
        }

        return true
    }
}
