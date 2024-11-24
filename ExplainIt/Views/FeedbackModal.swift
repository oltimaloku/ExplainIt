//
//  FeedbackModal.swift
//  ExplainIt
//
//  Created by Olti Maloku on 2024-11-22.
//

import SwiftUI
import MarkdownUI

struct FeedbackModal: View {
    let feedbackSegment: FeedbackSegment
    @EnvironmentObject var viewModel: ExplainViewModel
    @State private var definition: String?
    @State private var isLoading: Bool = false
    @State private var showAddConceptButton = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Concept Title
                HStack {
                    Text(feedbackSegment.concept)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.bottom, 8)
                    Spacer()
                    if showAddConceptButton {
                        Button(action: addConceptToTopic) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(Color(UIColor.label))
                                .font(.system(size: 30))
                        }
                    }
                }.padding(.bottom, 8)
                
                
                // User's Response
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Response:")
                        .font(.headline)
                    Text(feedbackSegment.text)
                        .padding()
                        .background(feedbackSegment.feedbackType.color)
                        .cornerRadius(8)
                    Text("Feedback:")
                        .font(.headline)
                    Text(feedbackSegment.explanation)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
                
                // Explanation or Definition
                if feedbackSegment.feedbackType == .incorrect {
                    if let definition = definition {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Correct Definition:")
                                .font(.headline)
                            Markdown(definition)
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                        }
                    } else if isLoading {
                        ProgressView("Fetching definition...")
                            .padding(.top)
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Explanation:")
                                .font(.headline)
                            Text(feedbackSegment.explanation)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(8)
                        }
                        Button(action: fetchDefinitionIfNeeded) {
                            Text("Get Correct Definition")
                                .foregroundColor(.blue)
                        }
                        .padding(.top)
                    }
                }
            }
            .padding()
        }
        .onAppear {
            if feedbackSegment.definition == nil {
                fetchDefinitionIfNeeded()
            }
        }
    }
    
    private func fetchDefinitionIfNeeded() {
            // First check if we already have this definition cached
            if let cachedDefinition = viewModel.definitions[feedbackSegment.concept] {
                self.definition = cachedDefinition
                return
            }
            
            guard definition == nil && !isLoading else { return }
            isLoading = true
            
            Task {
                do {
                    let fetchedDefinition = try await viewModel.getDefinition(for: feedbackSegment.concept)
                    DispatchQueue.main.async {
                        self.definition = fetchedDefinition
                        self.isLoading = false
                    }
                } catch {
                    print("Error fetching definition: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                }
            }
            
        }
    
    private func addConceptToTopic() {
        do {
            if let def = definition {
                try viewModel.addNewConceptFromFeedback(
                    conceptName: feedbackSegment.concept,
                    definition: def
                )
                
            }
        } catch {
            // Handle error - you might want to show an alert here
            print("Error adding concept: \(error.localizedDescription)")
        }
    }
}

#Preview {
    let sampleFeedback = FeedbackSegment(
        id: UUID(),
        text: "Variables are containers that store information in memory.",
        feedbackType: .correct,
        explanation: "Your understanding is correct! Variables are fundamental to programming.",
        concept: "Concept"
    )
    
    return FeedbackModal(feedbackSegment: sampleFeedback)
        .environmentObject(ExplainViewModel())
}

