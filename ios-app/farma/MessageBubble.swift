import SwiftUI
import Foundation

struct MessageBubble: View {
    var message: ChatMessage
    var isCurrentUser: Bool

    var body: some View {
        HStack {
            if isCurrentUser {
                Text(message.message)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(15)
            } else {
                Text(message.message)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(15)
            }
        }
        .frame(maxWidth: .infinity, alignment: isCurrentUser ? .trailing : .leading)
    }
}

