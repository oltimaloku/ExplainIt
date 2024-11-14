import SwiftUI

struct FeedbackSegment: Identifiable, Decodable {
    let id: UUID
    let text: String
    let feedbackType: FeedbackType
    let explanation: String
    let concept: String
    
    init(id: UUID = UUID(), text: String, feedbackType: FeedbackType, explanation: String, concept: String) {
            self.id = id
            self.text = text
            self.feedbackType = feedbackType
            self.explanation = explanation
            self.concept = concept
        }
    
    // Custom initializer for decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        text = try container.decode(String.self, forKey: .text)
        explanation = try container.decode(String.self, forKey: .explanation)
        concept = try container.decode(String.self, forKey: .concept)
        
        // Decode `feedbackType` with a custom strategy
        let feedbackTypeString = try container.decode(String.self, forKey: .feedbackType)
        switch feedbackTypeString.lowercased() {
        case "correct":
            feedbackType = .correct
        case "partiallycorrect":
            feedbackType = .partiallyCorrect
        case "incorrect":
            feedbackType = .incorrect
        default:
            throw DecodingError.dataCorruptedError(forKey: .feedbackType, in: container, debugDescription: "Invalid feedback type")
        }
        
        id = UUID()
    }
    
    // Coding keys for decoding
    private enum CodingKeys: String, CodingKey {
        case text
        case feedbackType
        case explanation
        case concept
    }
}

enum FeedbackType: Decodable {
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
