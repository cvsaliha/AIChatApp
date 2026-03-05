//
//  AIService.swift
//  AIChat
//
//  Created by Saliah CV on 05/03/2026.
//

import Foundation

enum AIServiceError: LocalizedError {
    case invalidResponse
    case networkError(String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:        return "Invalid response from server."
        case .networkError(let msg):  return msg
        }
    }
}

class AIService: NSObject, URLSessionDataDelegate {

    private let apiKey = APIConfig.groqKey
    private let url = URL(string: "https://api.groq.com/openai/v1/chat/completions")!

    private var continuation: AsyncThrowingStream<String, Error>.Continuation?

    func sendMessage(
        messages: [Message],
        persona: Persona
    ) -> AsyncThrowingStream<String, Error> {

        AsyncThrowingStream { continuation in
            self.continuation = continuation

            var apiMessages: [[String: String]] = [
                ["role": "system", "content": persona.systemPrompt]
            ]

            apiMessages += messages.map {
                ["role": $0.role.rawValue, "content": $0.content]
            }

            let body: [String: Any] = [
                "model": "llama-3.3-70b-versatile",
                "messages": apiMessages,
                "stream": true,
                "max_tokens": 1024
            ]

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)

            let session = URLSession(configuration: .default,
                                     delegate: self,
                                     delegateQueue: nil)
            session.dataTask(with: request).resume()
        }
    }

    func urlSession(_ session: URLSession,
                    dataTask: URLSessionDataTask,
                    didReceive data: Data) {

        guard let raw = String(data: data, encoding: .utf8) else { return }

        let lines = raw.components(separatedBy: "\n")

        for line in lines {
            guard line.hasPrefix("data: ") else { continue }

            let jsonString = String(line.dropFirst(6))

            if jsonString == "[DONE]" {
                continuation?.finish()
                return
            }

            guard
                let jsonData = jsonString.data(using: .utf8),
                let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
                let choices = json["choices"] as? [[String: Any]],
                let delta = choices.first?["delta"] as? [String: Any],
                let text = delta["content"] as? String
            else { continue }

            continuation?.yield(text)
        }
    }

    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?) {
        if let error {
            continuation?.finish(throwing: error)
        } else {
            continuation?.finish()
        }
    }
}
