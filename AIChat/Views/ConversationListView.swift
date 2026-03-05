//
//  ConversationListView.swift
//  AIChat
//
//  Created by Saliah CV on 05/03/2026.
//

import SwiftUI
import SwiftData

struct ConversationListView: View {

    // 1️⃣ Fetch all conversations, newest first
    @Query(sort: \Conversation.createdAt, order: .reverse)
    private var conversations: [Conversation]

    // 2️⃣ SwiftData context for insert/delete
    @Environment(\.modelContext) private var context

    @State private var showNewChat = false
    @State private var selectedConversation: Conversation?
    @State private var selectedPersona: Persona = Persona.all[0]
    @State private var showPersonaPicker = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                Group {
                    if conversations.isEmpty {
                        emptyState
                    } else {
                        conversationList
                    }
                }
            }
            .navigationTitle("Chats")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                // 3️⃣ Persona picker button
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showPersonaPicker = true
                    } label: {
                        Text(selectedPersona.emoji)
                            .font(.title3)
                    }
                }
                // 4️⃣ New chat button
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        createNewConversation()
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .foregroundStyle(.purple)
                    }
                }
            }
            .sheet(isPresented: $showPersonaPicker) {
                PersonaSelectorView(selectedPersona: $selectedPersona)
            }
            // 5️⃣ Navigate to ChatView when a conversation is selected
            .navigationDestination(item: $selectedConversation) { convo in
                ChatView(conversation: convo, persona: selectedPersona)
            }
        }
    }

    private var conversationList: some View {
        List {
            ForEach(conversations) { convo in
                Button {
                    selectedConversation = convo
                } label: {
                    ConversationRow(conversation: convo)
                }
                .listRowBackground(Color(white: 0.1))
                .listRowSeparatorTint(Color.white.opacity(0.08))
            }
            // 6️⃣ Swipe to delete
            .onDelete { indexSet in
                indexSet.forEach { context.delete(conversations[$0]) }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Text("🤖")
                .font(.system(size: 60))
            Text("No chats yet")
                .font(.title3.bold())
                .foregroundStyle(.white)
            Text("Tap ✏️ to start a new conversation")
                .foregroundStyle(.secondary)
            Button {
                createNewConversation()
            } label: {
                Label("New Chat", systemImage: "plus")
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.purple)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
        }
    }

    private func createNewConversation() {
        let convo = Conversation(persona: selectedPersona)
        context.insert(convo)       // 7️⃣ saves to SwiftData automatically
        selectedConversation = convo
    }
}

// 8️⃣ Single row in the list
struct ConversationRow: View {

    let conversation: Conversation

    var body: some View {
        HStack(spacing: 14) {
            Text(conversation.personaEmoji)
                .font(.title2)
                .frame(width: 44, height: 44)
                .background(Color.purple.opacity(0.2))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(conversation.displayTitle)
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(conversation.createdAt.formatted(.relative(presentation: .named)))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
    }
}
