import SwiftUI

struct ChatView: View {
    @ObservedObject var viewModel = ChatViewModel()
    let currentUser = "Buyer" // You can change this dynamically based on your app's user model
    
    var body: some View {
        VStack {
            // Chat message history
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(viewModel.messages) { message in
                        HStack {
                            if message.sender == currentUser {
                                Spacer()
                                MessageBubble(message: message, isCurrentUser: true)
                            } else {
                                MessageBubble(message: message, isCurrentUser: false)
                                Spacer()
                            }
                        }
                    }
                }
            }
            .padding()

            // Message input and send button
            HStack {
                TextField("Type your message...", text: $viewModel.messageInput)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)

                Button(action: {
                    viewModel.sendMessage(sender: currentUser)
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .navigationTitle("Chat")
        .onAppear {
            // Load messages when the view appears
            viewModel.loadMessages()
        }
    }
}

