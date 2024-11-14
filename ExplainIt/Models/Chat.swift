//
//  Chat.swift
//  ExplainIt
//
//  Created by Olti Maloku on 2024-11-10.
//

import Foundation

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUserMessage: Bool
    let timestamp: Date
    var isError: Bool = false
    var feedbackSegments: [FeedbackSegment] = []
    
    init(text: String, isUserMessage: Bool, timestamp: Date, isError: Bool = false, feedbackSegments: [FeedbackSegment] = []) {
            self.text = text
            self.isUserMessage = isUserMessage
            self.timestamp = timestamp
            self.isError = isError
            self.feedbackSegments = feedbackSegments
        }
}

struct ELI5Response: Decodable {
    let choices: [Choice]
    
    struct Choice: Decodable {
        let message: Message
    }
    
    struct Message: Decodable {
        let content: String
    }
}
