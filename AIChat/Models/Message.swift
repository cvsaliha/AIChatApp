//
//  Message.swift
//  AIChat
//
//  Created by Saliah CV on 05/03/2026.
//

import Foundation

// 1️⃣ Role — who sent the message
enum MessageRole: String, Codable {
    case user
    case assistant
}

// 2️⃣ A single chat message
struct Message: Identifiable, Codable {
    let id: UUID
    let role: MessageRole
    var content: String        // var because streaming appends chunks
    let timestamp: Date

    init(role: MessageRole, content: String) {
        self.id = UUID()
        self.role = role
        self.content = content
        self.timestamp = Date()
    }
}

// 3️⃣ A persona changes how the AI behaves via a system prompt
struct Persona: Identifiable {
    let id = UUID()
    let name: String
    let emoji: String
    let systemPrompt: String
}

// 4️⃣ Sample personas
extension Persona {
    static let all: [Persona] = [
        Persona(
            name: "Assistant",
            emoji: "🤖",
            systemPrompt: "You are a helpful and concise assistant."
        ),
        Persona(
            name: "Teacher",
            emoji: "👨‍🏫",
            systemPrompt: "You are a patient teacher. Explain everything simply with examples."
        ),
        Persona(
            name: "Coach",
            emoji: "💪",
            systemPrompt: "You are an energetic life coach. Be motivating, direct and positive."
        ),
        Persona(
            name: "Sarcastic",
            emoji: "😏",
            systemPrompt: "You are witty and sarcastic but still helpful. Keep responses short."
        )
    ]
}
