//
//  Conversation.swift
//  AIChat
//
//  Created by Saliah CV on 05/03/2026.
//

import Foundation
import SwiftData

// 1️⃣ @Model makes SwiftData persist this class automatically
@Model
class Conversation {
    var id: UUID
    var title: String
    var createdAt: Date
    var personaName: String
    var personaEmoji: String

    // 2️⃣ Cascade delete — deleting conversation deletes its messages too
    @Relationship(deleteRule: .cascade)
    var messages: [StoredMessage] = []

    init(persona: Persona) {
        self.id = UUID()
        self.title = "New Chat"
        self.createdAt = Date()
        self.personaName = persona.name
        self.personaEmoji = persona.emoji
    }

    // 3️⃣ Auto-title from first user message
    var displayTitle: String {
        messages.first(where: { $0.roleRaw == "user" })?.content
            .prefix(40)
            .description ?? title
    }
}

// 4️⃣ Separate SwiftData model for messages
@Model
class StoredMessage {
    var id: UUID
    var roleRaw: String       // "user" or "assistant"
    var content: String
    var timestamp: Date

    init(from message: Message) {
        self.id = message.id
        self.roleRaw = message.role.rawValue
        self.content = message.content
        self.timestamp = message.timestamp
    }

    // Convert back to our UI model
    var toMessage: Message {
        Message(role: MessageRole(rawValue: roleRaw) ?? .user,
                content: content)
    }
}
