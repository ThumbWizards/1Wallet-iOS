//
//  ARPreviewVC.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 03/01/22.
//

import UIKit
import QuickLook
import ARKit

class ARPreviewVC: QLPreviewController {

    // MARK: - Variable
    var objectUrl: URL!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func show(controller: UIViewController, with url: URL) {
        self.dataSource = self
        self.objectUrl = url
        self.reloadData()
        if let navController = controller.navigationController {
            navController.pushViewController(self, animated: true)
        } else {
            controller.show(self, sender: nil)
        }
    }
}

extension ARPreviewVC: QLPreviewControllerDataSource {
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        let item = ARQuickLookPreviewItem(fileAt: objectUrl)
        // TODO: - make canonicalWebPageURL dynamic 
        item.canonicalWebPageURL = URL(string: "www.google.com")
        return item
    }

    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
}
