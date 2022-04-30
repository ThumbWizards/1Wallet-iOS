//
//  LocationPickerItemView.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 11/15/21.
//

import SwiftUI

struct LocationPickerItemView {
    var data: TimeZoneModel
    var onSelected: ((TimeZoneModel) -> Void)?
}

extension LocationPickerItemView: View {
    var body: some View {
        HStack {
            rightView
            Spacer(minLength: 0)
        }
        .background(Color.almostClear)
        .onTapGesture {
            self.onSelected?(self.data)
        }
    }

    var rightView: some View {
        VStack(alignment: .leading, spacing: 4) {
                Text(data.city)
                .foregroundColor(Color.white87)
                .font(.system(size: 14, weight: .regular))
                .lineLimit(1)

            Text(data.country)
                .foregroundColor(Color.white40)
                .font(.system(size: 12, weight: .regular))
                .lineLimit(1)
        }
    }
}
