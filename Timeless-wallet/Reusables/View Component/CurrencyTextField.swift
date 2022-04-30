//
//  CurrencyTextField.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 29/12/21.
//

import SwiftUI
import web3swift

struct CurrencyTextField: UIViewRepresentable {
    typealias UIViewType = UITextField
    @Binding var focusState: SwapView.ViewModel.FocusState
    @Binding var text: String
    @Binding var amountState: SendView.ViewModel.AmountType
    var textFieldType: SwapView.ViewModel.FocusState = .none
    var placeholder: String
    var formatedCurrency: ((Double) -> Void)?

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.keyboardType = .decimalPad
        textField.font = UIFont.systemFont(ofSize: 22, weight: .regular)
        textField.textColor = .white.withAlphaComponent(0.6)
        textField.tintColor = .timelessBlue
        textField.textAlignment = .right
        textField.clipsToBounds = true
        textField.text = text
        textField.delegate = context.coordinator
        textField.placeholder = placeholder
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        if focusState == textFieldType {
            textField.becomeFirstResponder()
        }
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
        if $focusState.wrappedValue == textFieldType {
            if !uiView.isFirstResponder {
                // This triggers attribute cycle if not dispatched
                DispatchQueue.main.async {
                    uiView.becomeFirstResponder()
                }
            }
        }
        if context.coordinator.focusState.wrappedValue != $focusState.wrappedValue {
            context.coordinator.focusState = $focusState
        }
        if context.coordinator.amountState.wrappedValue != $amountState.wrappedValue {
            context.coordinator.amountState = $amountState
            uiView.placeholder = context.coordinator.amountState.wrappedValue == .usd ? "$0" : "0"
        }
    }

    func makeCoordinator() -> CurrencyTextField.Coodinator {
        return Coordinator(textBinding: $text,
                           placeHolder: self.placeholder,
                           formatedCurrency: formatedCurrency,
                           textFieldType: textFieldType,
                           focusState: $focusState,
                           amountState: $amountState)
    }

    final class Coodinator: NSObject {
        var textBinding: Binding<String>
        var focusState: Binding<SwapView.ViewModel.FocusState>
        var amountState: Binding<SendView.ViewModel.AmountType>
        var placeholder: String
        var formatedCurrency: ((Double) -> Void)?
        var textFieldType: SwapView.ViewModel.FocusState

        init(textBinding: Binding<String>,
             placeHolder: String,
             formatedCurrency: ((Double) -> Void)?,
             textFieldType: SwapView.ViewModel.FocusState,
             focusState: Binding<SwapView.ViewModel.FocusState>,
             amountState: Binding<SendView.ViewModel.AmountType>
        ) {
            self.textBinding = textBinding
            self.placeholder = placeHolder
            self.formatedCurrency = formatedCurrency
            self.textFieldType = textFieldType
            self.focusState = focusState
            self.amountState = amountState
        }
    }
}

// MARK: - functions
extension CurrencyTextField.Coodinator {
    func isMoreThan4FractionPoints(value: String) -> Bool {
        guard let decimalSeparator = Locale.current.decimalSeparator, value.contains(decimalSeparator) else {
            return false
        }
        let arrString = value.components(separatedBy: decimalSeparator)
        return arrString[1].count > 4 ? true : false
    }

    private func formatInputs(text: String) {
        guard let decimalSeparator = Locale.current.decimalSeparator,
              text.contains(decimalSeparator) else {
                  let text = text.replacingOccurrences(of: "$", with: "")
                  guard !text.isEmpty else {
                      textBinding.wrappedValue = ""
                      formatedCurrency?(0)
                      return
                  }
                  if text.replacingOccurrences(of: "0", with: "").isEmpty {
                      textBinding.wrappedValue = ""
                      formatedCurrency?(0)
                  } else {
                      let value = String(Int(text) ?? 0)
                      textBinding.wrappedValue = amountState.wrappedValue == .usd ? "$" + value : value
                      let formattedCurrency = Utils.formatStringToDouble(value)
                      formatedCurrency?(formattedCurrency)
                  }
                  return
              }
        if text == decimalSeparator {
            textBinding.wrappedValue = "0\(decimalSeparator)"
            formatedCurrency?(0)
        }
        let strings = text.components(separatedBy: decimalSeparator)
        let prev = String(Int(strings[0].filter("0123456789".contains)) ?? 0)
        if strings[1].count > amountState.wrappedValue.fraction {
            let decimal = String(strings[1].prefix(amountState.wrappedValue.fraction))
            let strValue = "\(prev)\(decimalSeparator)\(decimal)"
            textBinding.wrappedValue = amountState.wrappedValue == .usd ? "$" + strValue : strValue
            formatedCurrency?(Utils.formatStringToDouble(strValue))
            Utils.playHapticEvent()
        } else {
            let strValue = "\(prev)\(decimalSeparator)\(strings[1])"
            textBinding.wrappedValue = amountState.wrappedValue == .usd ? "$" + strValue : strValue
            formatedCurrency?(Utils.formatStringToDouble(strValue))
        }
    }
}

// MARK: - TextView delegate
extension CurrencyTextField.Coodinator: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if amountState.wrappedValue == SendView.ViewModel.AmountType.maxAmount {
            return false
        }
        let newPosition = textField.endOfDocument
        textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        focusState.wrappedValue = textFieldType
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        focusState.wrappedValue = .none
    }

    func textFieldDidChangeSelection(_ textField: UITextField) {
        if amountState.wrappedValue != SendView.ViewModel.AmountType.maxAmount {
            formatInputs(text: textField.text ?? "")
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isBlank {
            return true
        } else if let amount = Double(textField.text ?? "") {
            return amount < 100_000_000
        }
        return true
    }
}
