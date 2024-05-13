import SwiftUI

public extension View {
    
    func shrinkableSingleLine(minimumScaleFactor: CGFloat = 0.5) -> some View {
        self.lineLimit(1)
            .minimumScaleFactor(minimumScaleFactor)
    }
    
    func roundedBorder(_ color: Color,
                       cornerRadius: CGFloat = 4,
                       lineWidth: CGFloat = 1) -> some View {
        self.cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(color, lineWidth: lineWidth)
            )
    }
    
    func styledTabItem(imageName: String,
                       title: LocalizedStringKey,
                       accessibilityID: String) -> some View {
        tabItem {
            VStack {
                Image(systemName: imageName)
                    .imageScale(.large)
                Text(title, bundle: .module)
            }
            .accessibilityIdentifier(accessibilityID)
        }
        
    }
}

// MARK: - Text fields

// See: https://stackoverflow.com/questions/58200555/swiftui-add-clearbutton-to-textfield
// Until SwiftUI supports clear button natively (if ever??)
public struct TextFieldClearButton: ViewModifier {
    @Binding var text: String
    
    public init(text: Binding<String>) {
        self._text = text
    }

    public func body(content: Content) -> some View {
        HStack {
            content
            Spacer()
            if !text.isEmpty {
                // Tried using a Button here but it didn't work inside a form (hence onTapGesture instead)
                Image(systemName: "multiply.circle.fill")
                    .foregroundColor(.secondary)
                    .opacity(text == "" ? 0 : 1)
                    .onTapGesture { self.text = "" }
            }
        }
    }
}

public extension View {
    func showsClearButtonWhileEditing(_ text: Binding<String>) -> some View {
        self.modifier(TextFieldClearButton(text: text))
    }
}


// MARK: - Previews

public extension View {
    func styledPreview() -> some View {
        Font.registerCustomFonts()
        return self
    }
}


// MARK: - Pulsating symbol

public extension View {
    func pulsatingSymbol() -> some View {
        self.modifier(PulsatingSymbolEffectModifier())
    }
}

private struct PulsatingSymbolEffectModifier: ViewModifier {
    
    @State private var isAnimating = false
    
    func body(content: Content) -> some View {
        content
            .symbolEffect(.pulse, options: .repeating, value: isAnimating)
            .onAppear {
                isAnimating = true
            }
    }
}
