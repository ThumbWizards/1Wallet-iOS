//
//  ImagePicker.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 17/11/2021.
//

import SwiftUI
import UIKit

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var isVisible: Bool
    @Binding var image: Image?
    @Binding var uiImg: UIImage?
    var sourceType: UIImagePickerController.SourceType

    func makeCoordinator() -> Coordinator {
        Coordinator(isVisible: $isVisible, image: $image, uiImg: $uiImg)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {

    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        @Binding var isVisible: Bool
        @Binding var image: Image?
        @Binding var uiImg: UIImage?

        init(isVisible: Binding<Bool>, image: Binding<Image?>, uiImg: Binding<UIImage?>) {
            _isVisible = isVisible
            _image = image
            _uiImg = uiImg
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiimage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                image = Image(uiImage: uiimage)
                print(image as Any)
                isVisible = false
                uiImg = uiimage
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            isVisible = false
        }
    }
}
