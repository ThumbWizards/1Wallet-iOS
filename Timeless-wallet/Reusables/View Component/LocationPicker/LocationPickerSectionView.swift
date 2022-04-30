//
//  LocationPickerSectionView.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 11/15/21.
//

import SwiftUI

struct LocationPickerSectionView {
    var title: String
}

extension LocationPickerSectionView: View {
    var body: some View {
        HStack {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(Color.white40)
                .padding(.leading, 24)
                .lineLimit(1)
            Spacer(minLength: 0)
        }
    }
}
