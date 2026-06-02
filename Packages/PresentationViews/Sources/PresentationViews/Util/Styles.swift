import RidgeviewCore
import SwiftUI

public extension Color {
    
    static func assetCatalogColor(named colorName: String) -> Color {
        Color("Colors/\(colorName)", bundle: .module)
    }
    
    static let redOne = assetCatalogColor(named: "redOne")
    static let redTwo = assetCatalogColor(named: "redTwo")
    static let redThree = assetCatalogColor(named: "redThree")
    static let greyOne = assetCatalogColor(named: "greyOne")
    static let adaptiveGreyOne = assetCatalogColor(named: "adaptiveGreyOne")
    static let darkGrey1 = Color.rgb(62, 62, 62)
}

public extension Font {
    
    static func digitFont(size: CGFloat) -> Font {
        Font.custom("Digital-7Mono", size: size, relativeTo: .title)
    }
    
    static func registerCustomFonts() {
        do {
            try registerFont(named: "digital-7-mono")
        } catch {
            print("Error registering fonts")
        }
    }
    
    enum FontError: Swift.Error {
       case failedToRegisterFont
    }

    private static func registerFont(named name: String, in bundle: Bundle = .module) throws {
        guard let asset = NSDataAsset(name: "Fonts/\(name)", bundle: bundle) else {
            throw FontError.failedToRegisterFont
        }
        let fontURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(name).ttf")
        try asset.data.write(to: fontURL, options: .atomic)
        var error: Unmanaged<CFError>?
        guard CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, &error) else {
            throw FontError.failedToRegisterFont
        }
    }
}
