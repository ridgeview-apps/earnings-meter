import SwiftUI
import Introspect

public extension View {
    
    func shrinkableSingleLine(minimumScaleFactor: CGFloat = 0.5) -> some View {
        self.lineLimit(1)
            .minimumScaleFactor(minimumScaleFactor)
    }
    
    func addBorder<S>(_ content: S, width: CGFloat = 1, cornerRadius: CGFloat) -> some View where S : ShapeStyle {
         let roundedRect = RoundedRectangle(cornerRadius: cornerRadius)
         return clipShape(roundedRect)
              .overlay(roundedRect.strokeBorder(content, lineWidth: width))
     }
    
    func outerBorder(_ color: Color,
                     cornerRadius: CGFloat = 4,
                     lineWidth: CGFloat = 1) -> some View {
        self
            .padding([.all], lineWidth / 2) // set the width to half of the stroke width
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(color, lineWidth: lineWidth)
            )
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
    
    func dismissesKeyboardOnDrag() -> some View {
        introspectTableView { tableView in
            tableView.keyboardDismissMode = .onDrag
        }
    }
    
    func uiTableViewBackgroundColor(_ color: UIColor) -> some View {
        introspectTableView { tableView in
            tableView.backgroundColor = color
        }
    }
}

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
