//
//  ViewMask.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 29/10/2021.
//

import SwiftUI

func holeShapeMask(in rect: CGRect) -> Path {
    var shape = Rectangle().path(in: rect)
    shape.addPath(Circle().path(in: rect))
    return shape
}
