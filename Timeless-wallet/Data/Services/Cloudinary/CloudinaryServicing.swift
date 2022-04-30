//
//  CloudinaryServicing.swift
//  Timeless-iOS
//
//  Created by Vo Trong Nghia on 26/03/2021.
//  Copyright © 2021 Timeless. All rights reserved.
//

import Foundation
import Cloudinary
import Combine

protocol CloudinaryServicing: AnyObject {
    func uploadImage(image: UIImage, onComplete: @escaping (String?, Error?) -> Void)
}

// MARK: - Default Implementation
extension CloudinaryServicing {
    var client: CLDCloudinary {
        let config = CLDConfiguration(cloudName: "timeless", secure: true)
        return CLDCloudinary(configuration: config)
    }

    func uploadImage(image: UIImage, onComplete: @escaping (String?, Error?) -> Void) {
        if let data = image.jpegData(compressionQuality: 1.0) {
            var isComplete = false
            let uploader = client.createUploader().upload(
                data: data, uploadPreset: "1wallet_profile_avatar",
                completionHandler: { result, error in
                    isComplete = true
                    onComplete(result?.secureUrl, error)
                }
            )
            DispatchQueue.main.asyncAfter(deadline: .now() + 60) {
                if !isComplete {
                    uploader.cancel()
                    onComplete(nil, BackendAPIError.unknown)
                }
            }
        }
    }
}
