//
//  AIChatApp.swift
//  AIChat
//
//  Created by Saliah CV on 05/03/2026.
//

import SwiftUI
import SwiftData

@main
struct AIChatApp: App {
    var body: some Scene {
        WindowGroup {
            ConversationListView()
        }
        // 4️⃣ Register all SwiftData models here
        .modelContainer(for: [Conversation.self, StoredMessage.self])
    }
}
