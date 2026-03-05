//
//  PersonaSelectorView.swift
//  AIChat
//
//  Created by Saliah CV on 05/03/2026.
//

import SwiftUI

struct PersonaSelectorView: View {

    // 1️⃣ Binding so parent knows which persona was selected
    @Binding var selectedPersona: Persona

    // 2️⃣ Controls sheet dismissal
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {

                        Text("Choose how the AI behaves in this chat.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .padding(.top, 8)

                        // 3️⃣ Loop through all personas
                        ForEach(Persona.all) { persona in
                            PersonaCard(
                                persona: persona,
                                isSelected: persona.id == selectedPersona.id
                            ) {
                                selectedPersona = persona   // 4️⃣ update binding
                                dismiss()                   // 5️⃣ close sheet
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Select Persona")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.purple)
                }
            }
        }
    }
}

// 6️⃣ Single persona card — extracted for cleanliness
struct PersonaCard: View {

    let persona: Persona
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {

                // Emoji avatar
                Text(persona.emoji)
                    .font(.largeTitle)
                    .frame(width: 56, height: 56)
                    .background(isSelected ? Color.purple : Color(white: 0.18))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(persona.name)
                        .font(.headline)
                        .foregroundStyle(.white)
                    // 7️⃣ Show a trimmed preview of the system prompt
                    Text(persona.systemPrompt)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                // 8️⃣ Checkmark on selected
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.purple)
                        .font(.title3)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(white: 0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.purple : Color.clear, lineWidth: 2)
                    )
            )
        }
        // 9️⃣ Scale animation on tap
        .buttonStyle(ScaleButtonStyle())
    }
}

// 🔟 Reusable button style that scales down on press
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    PersonaSelectorView(selectedPersona: .constant(Persona.all[0]))
}
