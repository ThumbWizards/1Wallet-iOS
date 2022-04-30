//
//  CharityListView.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 27/01/22.
//

import SwiftUI

struct CharityListView {
    // MARK: - Variables
    @StateObject private var viewModel = ViewModel()
    var charityThumb: ((String) -> Void)?
}

extension CharityListView: View {
    var body: some View {
        ZStack(alignment: .top) {
            Color.primaryBackground
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: .center, spacing: 0) {
                titleView
                    .padding(.vertical, 17)
                    .padding(.horizontal, 16)
                charityList
                    .padding(.top, 21)
            }
        }
    }
}

// MARK: - Subviews
extension CharityListView {
    private var titleView: some View {
        HStack {
            Button(action: { onTapBack() }) {
                Image.closeBackup
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 30)
            }
            Spacer()
            Text("Charities")
                .tracking(0)
                .foregroundColor(Color.white87)
                .font(.system(size: 18, weight: .semibold))
            Spacer()
            Button(action: { onTapBack() }) {
                Text("Done")
                    .foregroundColor(.timelessBlue)
                    .font(.sfProText(size: 17))
            }
        }
    }

    private var seeAll: some View {
        HStack {
            Spacer()
            Button(action: {
                onTapBack()
            }) {
                Text("See All")
                    .foregroundColor(.timelessRed)
                    .font(.sfProText(size: 17))
            }

        }
    }

    private var charityList: some View {
        ScrollView {
            LazyVGrid(columns: viewModel.columnGrid) {
                ForEach(viewModel.charityList, id: \.self) { imageUrl in
                    Button(action: {
                        charityThumb?(imageUrl)
                        onTapBack()
                    }) {
                        charityImage(.init(
                            width: UIScreen.main.bounds.width - 96,
                            height: UIScreen.main.bounds.width - 96),
                                     path: imageUrl)
                            .cornerRadius(12)
                            .clipped()
                            .frame(width: UIScreen.main.bounds.width - 96, height: UIScreen.main.bounds.width - 96)
                    }
                }
            }
        }
    }

    func charityImage(_ size: CGSize, path: String) -> AnyView {
        let image = MediaResourceModel(path: path,
                                       altText: nil,
                                       pathPrefix: nil,
                                       mediaType: nil,
                                       thumbnail: nil)
        return MediaResourceView(for: MediaResource(for: image,
                                                       targetSize: TargetSize(width: Int(size.width),
                                                                              height: Int(size.height))),
                                    placeholder: ProgressView()
                                        .progressViewStyle(.circular)
                                        .eraseToAnyView(),
                                    isPlaying: .constant(true))
            .scaledToFill()
            .frame(size)
            .eraseToAnyView()
    }
}

// MARK: - Functions
extension CharityListView {
    private func onTapBack() {
        dismiss()
        pop()
    }
}

struct CharityListView_Previews: PreviewProvider {
    static var previews: some View {
        CharityListView()
    }
}
