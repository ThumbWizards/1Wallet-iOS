//
//  ChatView.swift
//  Timeless-wallet
//
//  Created by Parth Kshatriya on 29/10/21.
//

import SwiftUI

struct ChatView: View {
    var body: some View {
        ZStack {
            Color.backgroundColor
            NavigationLink(destination: SettingsView()) {
                Text("Open Setting")
                    .foregroundColor(.white)
            }
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
