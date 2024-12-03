import SwiftUI
import Foundation

// Extension to format Date into ISO 8601 string
extension Date {
    var iso8601: String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: self)
    }
}

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = [] // Chat history
    @Published var messageInput: String = ""    // Current input text
    @Published var errorMessage: String? = nil  // Error message for failed sends
    
    // Send message to backend
    func sendMessage(sender: String) {
        // Validate input
        if messageInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Message cannot be empty."
            return
        }

        // Create a new message with UUID as temporary id
        let newMessage = ChatMessage(
            sender: sender,
            message: messageInput,
            timestamp: Date(),
            isAttachment: false
        )

        // Immediately append the message to the local messages array
        DispatchQueue.main.async {
            self.messages.append(newMessage)
        }

        // Clear the input field after the message is added
        self.messageInput = ""

        // Create the URL request for the backend
        guard let url = URL(string: "http://localhost:3000/api/v1/chat") else {
            errorMessage = "Invalid URL"
            return
        }

        // Prepare the message data
        let parameters: [String: Any] = [
            "sender": sender,
            "message": newMessage.message,
            "timestamp": newMessage.timestamp.iso8601,
            "isAttachment": newMessage.isAttachment
        ]

        // Make the network request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            // Encode the parameters to JSON
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            errorMessage = "Failed to encode message"
            return
        }

        // Make the network request to the backend
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to send message: \(error.localizedDescription)"
                }
                return
            }

            if let data = data {
                do {
                    // Decode the response from the backend into a ChatMessage object
                    let decodedResponse = try JSONDecoder().decode(ChatMessage.self, from: data)

                    // Now update the message with the ID received from the backend
                    DispatchQueue.main.async {
                        // Find the message with the same UUID and replace it with the backend response
                        if let index = self.messages.firstIndex(where: { $0.id == newMessage.id }) {
                            self.messages[index] = decodedResponse // Update with real ID from backend
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to decode response: \(error.localizedDescription)"
                    }
                }
            }
        }.resume()

        // Optionally, send push notification
        //NotificationManager.shared.sendNotification(
          //  title: "New Message",
          //  body: "\(sender): \(newMessage.message)"
       // )


    }
    
    // Load messages from the backend
    func loadMessages() {
        guard let url = URL(string: "http://localhost:3000/api/v1/chat/messages") else {
            errorMessage = "Invalid URL"
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to load messages: \(error.localizedDescription)"
                }
                return
            }
            
            if let data = data {
                do {
                    // Decode the response into an array of ChatMessage
                    let decodedMessages = try JSONDecoder().decode([ChatMessage].self, from: data)
                    DispatchQueue.main.async {
                        self.messages = decodedMessages  // Update the message list with the latest from the server
                        self.errorMessage = nil
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to decode messages: \(error.localizedDescription)"
                    }
                }
            }
        }.resume()
    }
}

