//
//  ConceptViewModel.swift
//  ExplainIt
//
//  Created by Olti Maloku on 2024-11-07.
//

import Foundation

class ConceptViewModel: ObservableObject {
    @Published var userInput: String = ""
    @Published var feedbackSegments: [FeedbackSegment] = []
    @Published var selectedSegment: FeedbackSegment?
    @Published var showingFeedbackPopup = false
    
    @Published var isLoading: Bool = false
    
    
    func submitForFeedback() {
            isLoading = true
            
            // Simulate API call to OpenAI
            // In production, replace with actual API call
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                // Sample feedback segments
                self.feedbackSegments = [
                    FeedbackSegment(
                        text: String(self.userInput.prefix(20)),
                        feedbackType: .correct,
                        explanation: "This part accurately describes the concept."
                    ),
                    FeedbackSegment(
                        text: String(self.userInput.dropFirst(20).prefix(15)),
                        feedbackType: .partiallyCorrect,
                        explanation: "This is partially correct, but could be more precise."
                    ),
                    FeedbackSegment(
                        text: String(self.userInput.dropFirst(35)),
                        feedbackType: .incorrect,
                        explanation: "This part contains misconceptions that need correction."
                    )
                ]
                self.isLoading = false
            }
        }
    
}
