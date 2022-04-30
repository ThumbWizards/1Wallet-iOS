//
//  RemoteImage.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 29/11/21.
//

import SwiftUI

struct RemoteImage: View {
    private enum LoadState {
        case loading, success, failure
    }

    private class Loader: ObservableObject {
        var data = Data()
        var state = LoadState.loading

        init(url: URL?) {
            guard let parsedURL = url else {
                self.state = .failure
                return
            }
            URLSession.shared.dataTask(with: parsedURL) { [weak self] data, _, _ in
                guard let weakSelf = self else {
                    return
                }
                if let data = data, !data.isEmpty {
                    weakSelf.data = data
                    weakSelf.state = .success
                } else {
                    weakSelf.state = .failure
                }

                DispatchQueue.main.async { [weak self] in
                    guard let weakSelf = self else {
                        return
                    }
                    weakSelf.objectWillChange.send()
                }
            }
            .resume()
        }
    }

    @StateObject private var loader: Loader
    var loading: Image
    var failure: Image

    var body: some View {
        selectImage()
            .resizable()
            .aspectRatio(contentMode: .fill)
    }

    init(url: URL?, loading: Image = Image.photo, failure: Image = Image.photo) {
        _loader = StateObject(wrappedValue: Loader(url: url))
        self.loading = loading
        self.failure = failure
    }

    private func selectImage() -> Image {
        switch loader.state {
        case .loading:
            return loading
        case .failure:
            return failure
        default:
            if let image = UIImage(data: loader.data) {
                return Image(uiImage: image)
            } else {
                return failure
            }
        }
    }
}
