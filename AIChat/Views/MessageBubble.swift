//
//  MessageBubble.swift
//  AIChat
//
//  Created by Saliah CV on 05/03/2026.
//

import SwiftUI

struct MessageBubble: View {

    let message: Message

    // 1️⃣ Convenience — avoids repeating this condition everywhere
    private var isUser: Bool { message.role == .user }

    // In MessageBubble, update the body
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if !isUser {
                Circle()
                    .fill(Color.purple.opacity(0.3))
                    .frame(width: 32, height: 32)
                    .overlay(Text("🤖").font(.caption))
            }

            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(isUser ? Color.purple : Color(white: 0.18))
                    .foregroundStyle(.white)
                    .clipShape(BubbleShape(isUser: isUser))
                    .scaleX(isUser ? -1 : 1)  // 👈 counter-mirror just the bubble content

                Text(message.timestamp.formatted(.dateTime.hour().minute()))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .scaleX(isUser ? -1 : 1)  // 👈 counter-mirror the timestamp too
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.72,
                   alignment: isUser ? .trailing : .leading)

            if isUser { Spacer(minLength: 40) }
        }
        .scaleX(isUser ? -1 : 1)  // flips the whole HStack for layout
        .padding(.horizontal)
    }
}

// 9️⃣ Custom bubble shape — pointed corner changes side based on sender
struct BubbleShape: Shape {

    let isUser: Bool

    func path(in rect: CGRect) -> Path {
        let r: CGFloat = 18        // corner radius
        let tail: CGFloat = 10     // tail size

        var path = Path()

        if isUser {
            // Rounded rect with bottom-right tail
            path.move(to: CGPoint(x: rect.minX + r, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - r, y: rect.minY))
            path.addArc(center: CGPoint(x: rect.maxX - r, y: rect.minY + r),
                        radius: r, startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - r - tail))
            path.addLine(to: CGPoint(x: rect.maxX + tail, y: rect.maxY - tail))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - r))
            path.addArc(center: CGPoint(x: rect.maxX - r, y: rect.maxY - r),
                        radius: r, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
            path.addLine(to: CGPoint(x: rect.minX + r, y: rect.maxY))
            path.addArc(center: CGPoint(x: rect.minX + r, y: rect.maxY - r),
                        radius: r, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + r))
            path.addArc(center: CGPoint(x: rect.minX + r, y: rect.minY + r),
                        radius: r, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        } else {
            // Rounded rect with bottom-left tail
            path.move(to: CGPoint(x: rect.minX + r, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - r, y: rect.minY))
            path.addArc(center: CGPoint(x: rect.maxX - r, y: rect.minY + r),
                        radius: r, startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - r))
            path.addArc(center: CGPoint(x: rect.maxX - r, y: rect.maxY - r),
                        radius: r, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
            path.addLine(to: CGPoint(x: rect.minX + r, y: rect.maxY))
            path.addArc(center: CGPoint(x: rect.minX + r, y: rect.maxY - r),
                        radius: r, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + r + tail))
            path.addLine(to: CGPoint(x: rect.minX - tail, y: rect.minY + tail))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + r))
            path.addArc(center: CGPoint(x: rect.minX + r, y: rect.minY + r),
                        radius: r, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        }

        path.closeSubpath()
        return path
    }
}

// 🔟 View extension for horizontal flip trick
extension View {
    func scaleX(_ scale: CGFloat) -> some View {
        self.scaleEffect(CGSize(width: scale, height: 1))
    }
}

// Preview both sides
#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack(spacing: 12) {
            MessageBubble(message: Message(role: .user, content: "What is SwiftUI?"))
            MessageBubble(message: Message(role: .assistant, content: "SwiftUI is Apple's modern framework for building UIs across all platforms using Swift."))
        }
        .padding(.top)
    }
}
