import SwiftUI

struct PrimaryButtonStyle: ViewModifier {
    var color: Color = Color.green

    func body(content: Content) -> some View {
        content
            .foregroundColor(.white)
            .frame(width: 200, height: 50)
            .background(color)
            .cornerRadius(10)
            .padding()
    }
}

extension View {
    func primaryButton(color: Color = Color.green) -> some View {
        self.modifier(PrimaryButtonStyle(color: color))
    }
}
