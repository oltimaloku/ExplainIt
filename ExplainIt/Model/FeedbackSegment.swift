//
//  FeedbackSegment.swift
//  ExplainIt
//
//  Created by Olti Maloku on 2024-11-07.
//

import SwiftUI

struct FeedbackSegment: Identifiable {
    let id = UUID()
    let text: String
    let feedbackType: FeedbackType
    let explanation: String
}

enum FeedbackType {
    case correct
    case partiallyCorrect
    case incorrect
    
    var color: Color {
        switch self {
            case .correct: return .green.opacity(0.3)
            case .partiallyCorrect: return .yellow.opacity(0.3)
            case .incorrect: return .red.opacity(0.3)
        }
    }
}
