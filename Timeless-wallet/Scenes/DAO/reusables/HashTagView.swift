//
//  HashTagView.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 27/01/22.
//

import SwiftUI

struct HashTagView {
    // MARK: - Variables
    var background: Color
    var foreground: Color
    var text: String
}

extension HashTagView: View {
    var body: some View {
        Text("#\(text)")
            .font(.sfProText(size: 16))
            .tracking(-0.38)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(background)
            .foregroundColor(foreground)
            .cornerRadius(6)
    }
}
