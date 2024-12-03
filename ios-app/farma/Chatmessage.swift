import Foundation
import SwiftUI

// ChatMessage model to represent a chat message
struct ChatMessage: Identifiable, Codable {
    var id: UUID // Use UUID instead of an integer ID
    let sender: String
    let message: String
    let timestamp: Date
    let isAttachment: Bool

    // Initializer for creating a temporary message
    init(sender: String, message: String, timestamp: Date, isAttachment: Bool) {
        self.id = UUID() // Assign a unique UUID
        self.sender = sender
        self.message = message
        self.timestamp = timestamp
        self.isAttachment = isAttachment
    }

    // Decoder to allow mapping backend response correctly
    enum CodingKeys: String, CodingKey {
        case id
        case sender
        case message
        case timestamp
        case isAttachment
    }
}

