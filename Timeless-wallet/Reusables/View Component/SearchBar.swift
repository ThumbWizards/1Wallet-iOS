//
//  SearchBar.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 11/15/21.
//

import SwiftUI

struct SearchBar {
    @State private var isEditing = false
    @Binding var text: String
    @State private var textField: UITextField?
    var clearButtonImage: Image?
    var placeholder = ""
    var cornerRadius: CGFloat = 8
    var accentColor = Color.timelessBlue
    var backgroundColor = Color.searchBarItem
    var leftIconColor = Color.searchBarItem
    var rightIconColor = Color.searchBarItem
    var isDisableAutocorrection = false

    var editingChanged: ((Bool) -> Void)?
    var commitClosure: (() -> Void)?
}

extension SearchBar: View {
    var body: some View {
        GeometryReader { _ in
            HStack {
                Image.search
                    .resizable()
                    .frame(width: 14, height: 14)
                    .foregroundColor(self.leftIconColor)
                ZStack(alignment: .leading) {
                    if self.text.isEmpty {
                        Text(placeholder)
                            .font(.system(size: 17))
                            .foregroundColor(.white40)
                    }

                    TextField("", text: self.$text, onEditingChanged: { onEdit in
                        self.isEditing = onEdit
                        self.editingChanged?(onEdit)
                    }, onCommit: {
                        self.commitClosure?()
                    })
                    .font(.system(size: 17))
                    .disableAutocorrection(self.isDisableAutocorrection)
                }
                if !self.text.isEmpty {
                    Button(action: {
                        self.text = ""
                    }) {
                        Image.multiplyCircleFill
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(self.rightIconColor)
                    }
                }
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
            .background(self.backgroundColor.opacity(0.12))
            .cornerRadius(self.cornerRadius)
        }
        .introspectTextField { textField in
            if self.textField == nil {
                self.textField = textField
            }
        }
        .padding(.horizontal, 16)
        .background(
            Color.almostClear
                .padding(.leading, -27)
                .padding(.top, -8)
                .onTapGesture {
                    textField?.becomeFirstResponder()
                }
        )
        .accentColor(accentColor)
    }
}
