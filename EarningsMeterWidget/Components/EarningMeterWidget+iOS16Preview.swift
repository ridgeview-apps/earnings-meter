// *****************************************************************************
// Why is the iOS 16 preview code here?
//
// (1) As of Xcode 15.0 / iOS 17, widgets can only be previewed using the #Preview macro
// (2) The #Preview macro doesn't work for iOS 16 previews (you have to use PreviewProvider instead)
// (3) You can't mix & match PreviewProvider AND #Preview macro code within the same file (the preview pane gets confused), hence iOS 16 code moved here
// (4) Apple acknowledges this is an iOS 16 bug (though a fix is probably unlikely - see: https://developer.apple.com/forums/thread/731182)
// (5) Be warned that previewing on iOS 16 is VERY flaky (due to the above)
// *****************************************************************************

import Models
import SwiftUI
import WidgetKit

// Recommend previewing on an iPhone 8 device (i.e. one which doesn't support iOS 17)
struct WidgetPreviewIOS16: PreviewProvider {
    
    static var previews: some View {
        MainWidgetView(entry: .placeholder)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            .previewDisplayName("Small")
        MainWidgetView(entry: .placeholder)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .previewDisplayName("Medium")
        MainWidgetView(entry: .placeholder)
            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
            .previewDisplayName("Acc. circular")
        MainWidgetView(entry: .placeholder)
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
            .previewDisplayName("Acc. rectangular")
    }
}
