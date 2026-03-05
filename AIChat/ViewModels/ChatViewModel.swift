//
//  ChatViewModel.swift
//  AIChat
//
//  Created by Saliah CV on 05/03/2026.
//

import Foundation

@MainActor
class ChatViewModel: ObservableObject {

    @Published var messages: [Message] = []
    @Published var isStreaming = false
    @Published var errorMessage: String? = nil

    // 1️⃣ Persona drives the system prompt sent to AIService
    @Published var selectedPersona: Persona = Persona.all[0]

    private let service = AIService()

    // 2️⃣ Called from ChatView when user taps send
    func send(userInput: String) {
        let trimmed = userInput.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !isStreaming else { return }

        errorMessage = nil

        // 3️⃣ Append user message immediately so UI updates right away
        messages.append(Message(role: .user, content: trimmed))

        // 4️⃣ Add an empty assistant message — we'll append chunks into it
        let assistantMessage = Message(role: .assistant, content: "")
        messages.append(assistantMessage)
        let assistantIndex = messages.count - 1

        isStreaming = true

        Task {
            do {
                // 5️⃣ Get the stream — passes full history + persona
                let stream = service.sendMessage(
                    messages: messages.dropLast(),  // exclude the empty assistant placeholder
                    persona: selectedPersona
                )

                // 6️⃣ for await iterates each chunk as it arrives
                for try await chunk in stream {
                    messages[assistantIndex].content += chunk  // 7️⃣ append word by word
                }

            } catch {
                // 8️⃣ Remove the empty assistant message on error
                messages.removeLast()
                errorMessage = error.localizedDescription
            }

            isStreaming = false
        }
    }

    func clearMessages() {
        messages = []
        errorMessage = nil
    }
}
