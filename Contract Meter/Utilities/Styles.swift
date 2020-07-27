//
//  Styles.swift
//  Earnings Meter
//
//  Created by Shilan Patel on 12/05/2020.
//  Copyright © 2020 Shilan Patel. All rights reserved.
//
import SwiftUI

extension Color {
    static let redOne = Color("redOne")
    static let redTwo = Color("redTwo")
    static let greyOne = Color("greyOne")
    static let disabledText = Color.white.opacity(0.25)
}

extension UIColor {
    static let redOne = UIColor(named: "redOne")!
}

extension Font {
    static func digitFont(size: CGFloat) -> Font {
        Font.custom("Digital-7Mono", size: size)
    }
}
