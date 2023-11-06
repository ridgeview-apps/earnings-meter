 import SwiftUI

 public enum PreviewOptionDeviceType: String, Identifiable {
     public var id: String { rawValue }
     
     // Sample of devices for preview.
     //
     // Run "xcrun simctl list devicetypes" to see the full list and add here as required

     case iPhone_11_Pro = "iPhone 11 Pro"
     case iPhone_11_Pro_Max = "iPhone 11 Pro Max"
     case iPhone_SE_2nd_generation = "iPhone SE (2nd generation)"
     case iPad_Pro_9_7_inch = "iPad Pro (9.7-inch)"
     case iPod_touch_7th_generation = "iPod touch (7th generation)"
 }

 // MARK: - Preview options
 #if DEBUG
 public extension View {
     
     func previewLandscapeIPad() -> some View {
         self.previewLayout(.fixed(width: 1024, height: 768))
     }
          
     func previewOption(deviceType: PreviewOptionDeviceType) -> some View {
         self.previewDevice(.init(rawValue: deviceType.rawValue))
             .previewDisplayName(deviceType.rawValue)
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

public extension PreviewProvider {
    
    static func previewOnIPhoneAndIPad<Content: View>(
        iPhone: PreviewOptionDeviceType = .iPhone_11_Pro,
        iPad: PreviewOptionDeviceType = .iPad_Pro_9_7_inch,
        iPhoneOrientation: InterfaceOrientation = .portrait,
        iPadOrientation: InterfaceOrientation = .landscapeLeft,
        @ViewBuilder previewContent: () -> Content
    ) -> some View {
        Group {
            // iPhone
            Group {
                previewContent()
            }
            .previewOption(deviceType: iPhone)
            .previewInterfaceOrientation(iPhoneOrientation)
            
            // iPad
            Group {
                previewContent()
            }
            .previewOption(deviceType: iPad)
            .previewInterfaceOrientation(iPadOrientation)
            
        }
        .navigationViewStyle(.stack)
    }
}
 #endif
