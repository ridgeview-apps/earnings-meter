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
