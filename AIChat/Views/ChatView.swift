//
//  ChatView.swift
//  AIChat
//
//  Created by Saliah CV on 05/03/2026.
//

import SwiftUI

struct ChatView: View {

    let conversation: Conversation
        let persona: Persona

        @StateObject private var vm = ChatViewModel()
        @State private var inputText = ""
        @State private var showPersonaPicker = false
        @Environment(\.modelContext) private var context

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 0) {

                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {

                            ForEach(vm.messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }

                            if vm.isStreaming && vm.messages.last?.role == .user {
                                TypingIndicator()
                                    .id("typing")
                            }
                        }
                        .padding(.vertical, 12)
                    }
                    // 3️⃣ Scroll on new message or streaming start
                    .onChange(of: vm.messages.count) { scrollToBottom(proxy: proxy) }
                    .onChange(of: vm.isStreaming) {
                        if vm.isStreaming { scrollToBottom(proxy: proxy) }
                    }
                    // 4️⃣ Scroll while content streams in
                    .onChange(of: vm.messages.last?.content) { scrollToBottom(proxy: proxy) }
                }

                // 5️⃣ Error banner
                if let error = vm.errorMessage {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                        Text(error)
                            .font(.caption)
                        Spacer()
                        Button("Retry") { vm.errorMessage = nil }
                            .font(.caption.bold())
                    }
                    .foregroundStyle(.white)
                    .padding(10)
                    .background(Color.red.opacity(0.8))
                }

                Divider().overlay(Color.white.opacity(0.1))
                inputBar
            }
        }
        .navigationTitle(vm.selectedPersona.emoji + " " + vm.selectedPersona.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showPersonaPicker = true } label: {
                    Text(vm.selectedPersona.emoji).font(.title3)
                }
            }
        }
        .sheet(isPresented: $showPersonaPicker) {
            // 6️⃣ Bind directly to ViewModel's persona
            PersonaSelectorView(selectedPersona: $vm.selectedPersona)
        }
        .onAppear {
                    // 2️⃣ Load existing messages when reopening a chat
                    vm.selectedPersona = persona
                    vm.messages = conversation.messages
                        .sorted { $0.timestamp < $1.timestamp }
                        .map { $0.toMessage }
        }
        .onChange(of: vm.messages.count) {
                    // 3️⃣ Sync new messages back to SwiftData
                    syncMessages()
                }
    }
    
    private func syncMessages() {
            conversation.messages = vm.messages.map { StoredMessage(from: $0) }
            try? context.save()
        }

    private var inputBar: some View {
        HStack(alignment: .bottom, spacing: 10) {
            ZStack(alignment: .topLeading) {
                if inputText.isEmpty {
                    Text("Message...")
                        .foregroundStyle(.gray)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 10)
                }
                TextEditor(text: $inputText)
                    .scrollContentBackground(.hidden)
                    .foregroundStyle(.white)
                    .frame(minHeight: 40, maxHeight: 120)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Color(white: 0.15))
            .clipShape(RoundedRectangle(cornerRadius: 20))

            Button {
                vm.send(userInput: inputText)  // 7️⃣ delegate to ViewModel
                inputText = ""
            } label: {
                Image(systemName: inputText.trimmingCharacters(in: .whitespaces).isEmpty
                      ? "mic.fill" : "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(inputText.trimmingCharacters(in: .whitespaces).isEmpty
                                     ? .gray : .purple)
                    .animation(.easeInOut(duration: 0.2), value: inputText.isEmpty)
            }
            .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty || vm.isStreaming)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(white: 0.08))
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        withAnimation(.easeOut(duration: 0.3)) {
            if let last = vm.messages.last {
                proxy.scrollTo(last.id, anchor: .bottom)
            }
        }
    }
}

// Animated typing indicator — three bouncing dots
struct TypingIndicator: View {

    @State private var animating = false

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            Circle()
                .fill(Color.purple.opacity(0.3))
                .frame(width: 32, height: 32)
                .overlay(Text("🤖").font(.caption))

            HStack(spacing: 5) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 8, height: 8)
                        .offset(y: animating ? -5 : 0)
                        .animation(
                            .easeInOut(duration: 0.5)
                            .repeatForever()
                            .delay(Double(i) * 0.15),   // stagger each dot
                            value: animating
                        )
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color(white: 0.18))
            .clipShape(RoundedRectangle(cornerRadius: 18))

            Spacer()
        }
        .padding(.horizontal)
        .onAppear { animating = true }
    }
}
