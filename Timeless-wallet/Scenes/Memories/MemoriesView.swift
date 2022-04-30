//
//  MemoriesView.swift
//  Timeless-wallet
//
//  Created by Parth Kshatriya on 26/10/21.
//

import SwiftUI

struct MemoriesView: View {
    var body: some View {
        ZStack {
            Color.red
                .cornerRadius(15)
            Text("Memories")
                .foregroundColor(.white)
        }
    }
}

struct MemoriesView_Previews: PreviewProvider {
    static var previews: some View {
        MemoriesView()
    }
}
