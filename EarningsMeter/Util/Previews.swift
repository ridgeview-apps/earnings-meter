 import SwiftUI

 enum PreviewOptionDeviceType: String, Identifiable {
     var id: String { rawValue }
     
     // Sample of devices for preview.
     //
     // Run "xcrun simctl list devicetypes" to see the full list and add here as required

     case iPhone_11_Pro = "iPhone 11 Pro"
     case iPhone_11_Pro_Max = "iPhone 11 Pro Max"
     case iPhone_SE_2nd_generation = "iPhone SE (2nd generation)"
     case iPad_Pro_9_7_inch = "iPad Pro (9.7-inch)"
     case iPod_touch_7th_generation = "iPod touch (7th generation)"
     
     struct PreviewSizeClass {
         let vertical: UserInterfaceSizeClass
         let horizontal: UserInterfaceSizeClass
         
         static let tallAndWide = PreviewSizeClass(vertical: .regular,
                                                   horizontal: .regular)
         
         static let tallAndThin = PreviewSizeClass(vertical: .regular,
                                                   horizontal: .compact)
         
         static let shortAndWide = PreviewSizeClass(vertical: .compact,
                                                    horizontal: .regular)
         
         static let shortAndThin = PreviewSizeClass(vertical: .compact,
                                                      horizontal: .compact)

     }
     
     var sizeClass: PreviewSizeClass {
         switch self {
         case .iPhone_SE_2nd_generation, .iPhone_11_Pro, .iPhone_11_Pro_Max, .iPod_touch_7th_generation:
             return .tallAndThin
         case .iPad_Pro_9_7_inch:
             return .tallAndWide
         }
     }
 }
 
 enum PreviewOption {
    case iPad_Pro_9_7_inch_Portrait
    case iPad_Pro_9_7_inch_Landscape
 }


 // MARK: - Preview options
 #if DEBUG
 extension View {
     
    func previewLandscapeIPad() -> some View {
        self.previewLayout(.fixed(width: 1024, height: 768))
    }
    
    func previewOption(deviceType: PreviewOptionDeviceType) -> some View {
        self.previewDevice(.init(rawValue: deviceType.rawValue))
            .previewDisplayName(deviceType.rawValue)
            .environment(\.verticalSizeClass, deviceType.sizeClass.vertical)
            .environment(\.horizontalSizeClass, deviceType.sizeClass.horizontal)
    }
    
    func previewOption(colorScheme: ColorScheme) -> some View {
        self.environment(\.colorScheme, colorScheme)
    }
    
    func previewOption(contentSize: ContentSizeCategory) -> some View {
        self.environment(\.sizeCategory, contentSize)
    }
    
    func previewOption(locale: Locale) -> some View {
        self.environment(\.locale, locale)
    }
    
 }
 #endif
