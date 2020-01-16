//
//  Previews.swift
//  Earnings Meter
//
//  Created by Shilan Patel on 17/06/2020.
//  Copyright © 2020 Shilan Patel. All rights reserved.
//

import Foundation
import SwiftUI

struct UIElementPreview<Value: View>: View {

    private let dynamicTypeSizes: [ContentSizeCategory] = [.extraSmall, .large, .extraExtraExtraLarge]

    /// Filter out "base" to prevent a duplicate preview.
    private let localizations = Bundle.main.localizations.map(Locale.init).filter { $0.identifier != "base" }

    private let viewToPreview: Value

    init(_ viewToPreview: Value) {
        self.viewToPreview = viewToPreview
    }

    var body: some View {
        Group {
            self.viewToPreview
                .previewDevice(.init(rawValue: "iPhone SE"))
                .previewDisplayName("iPhone SE")
                .environment(\.verticalSizeClass, .regular)
                .environment(\.horizontalSizeClass, .compact)
            
            self.viewToPreview
                .previewDevice(.init(rawValue: "iPad Pro (9.7-inch)"))
                .previewDisplayName("iPad Pro (9.7-inch)")
                .environment(\.horizontalSizeClass, .regular)
                .environment(\.verticalSizeClass, .regular)
                        
            self.viewToPreview
                .previewLayout(PreviewLayout.sizeThatFits)
                .padding()
                .previewDisplayName("Default preview 1")

            self.viewToPreview
                .previewLayout(PreviewLayout.sizeThatFits)
                .padding()
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .dark)
                .previewDisplayName("Dark Mode")

            ForEach(localizations, id: \.identifier) { locale in
                self.viewToPreview
                    .previewLayout(PreviewLayout.sizeThatFits)
                    .padding()
                    .environment(\.locale, locale)
                    .previewDisplayName(Locale.current.localizedString(forIdentifier: locale.identifier))
            }

            ForEach(dynamicTypeSizes, id: \.self) { sizeCategory in
                self.viewToPreview
                    .previewLayout(PreviewLayout.sizeThatFits)
                    .padding()
                    .environment(\.sizeCategory, sizeCategory)
                    .previewDisplayName("\(sizeCategory)")
            }

        }
    }
}
