//
//  Storyboarded.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 26/10/21.
//

import UIKit

/// Storyboards
enum Storyboard: String {
    case chat = "Chat"
    case upComingEvent = "UpComingEvent"
}

///// Instantiate View Controller
extension UIViewController {
    class func instantiate<T: UIViewController>(appStoryboard: Storyboard) -> T? {
        let storyboard = UIStoryboard(name: appStoryboard.rawValue, bundle: nil)
        let identifier = String(describing: self)
        return storyboard.instantiateViewController(withIdentifier: identifier) as? T
    }
}
