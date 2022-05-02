import SwiftUI

extension AnyTransition {
    
    static var slideUp: AnyTransition {
        let insertion = AnyTransition.move(edge: .bottom)
                                     .combined(with: .opacity)

        let removal = AnyTransition.move(edge: .top)
                                     .combined(with: .opacity)

        return .asymmetric(insertion: insertion, removal: removal)
    }
    
    static var slideDown: AnyTransition {
        let insertion = AnyTransition.move(edge: .top)
                                     .combined(with: .opacity)

        let removal = AnyTransition.move(edge: .bottom)
                                     .combined(with: .opacity)

        return .asymmetric(insertion: insertion, removal: removal)
    }
    
}

extension View {
    
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
struct TextFieldClearButton: ViewModifier {
    @Binding var text: String

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
