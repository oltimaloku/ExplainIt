//
//  ExplainViewModel.swift
//  ExplainIt
//
//  Created by Olti Maloku on 2024-11-21.
//

import Foundation

@MainActor
class ExplainViewModel: ObservableObject {
    @Published var feedbackAnalysisForQuestions: [String: FeedbackAnalysis] = [:]
    @Published var feedbackAnalysis: FeedbackAnalysis?
    @Published var isLoading: Bool = false
    @Published var definitions: [String: String] = [:]
    @Published var currentTopic: Topic?
    @Published var topics: [Topic] = []
    
    private let openAIService: OpenAIService
    
    init(openAIService: OpenAIService = .shared) {
        self.openAIService = openAIService
        topics = getMockTopics()
    }
    
    func addNewConceptFromFeedback(conceptName: String, definition: String?) throws {
        guard let currentTopic = currentTopic else {
            throw NSError(domain: "CurrentTopicNotSet", code: -1, userInfo: [NSLocalizedDescriptionKey: "No topic is currently selected."])
        }
        
        // Check if the concept already exists
        if currentTopic.concepts.contains(where: { $0.name == conceptName }) {
            throw NSError(domain: "ConceptAlreadyExists", code: -1, userInfo: [NSLocalizedDescriptionKey: "The concept '\(conceptName)' already exists in the current topic."])
        }
        
        // Create and add the new concept
        let newConcept = Concept(id: UUID(), name: conceptName, definition: definition)
        
        // Update the current topic
        if let index = topics.firstIndex(where: { $0.id == currentTopic.id }) {
            topics[index].concepts.append(newConcept)
        }
    }
    
    
    func gradeResponse(question: String, text: String) async {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        isLoading = true
        
        do {
            
            let feedbackSegments = try await gradeSentenceSegments(question: question, fullResponse: text)
            
            
            let overallGrade = calculateOverallGrade(for: feedbackSegments)
            let feedback = FeedbackAnalysis(segments: feedbackSegments, overallGrade: overallGrade)
            
            feedbackAnalysis = feedback
            feedbackAnalysisForQuestions[question] = feedback
        } catch {
            print("Error grading response: \(error.localizedDescription)")
            // Handle error (you can update the UI to show an error message)
        }
        
        isLoading = false
    }
    
    func resetFeedback() {
        feedbackAnalysis = nil
    }
    
    private func splitTextIntoSentences(_ text: String) -> [String] {
        return text.components(separatedBy: CharacterSet(charactersIn: ".!?"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
    
    func generateInitialQuestions(for topic: String) async throws -> [String] {
        let systemMessage = GPTMessage(
            role: "system",
            content: """
            You are an educational assistant specializing in gauging a user's understanding of complex topics. \
            Your role is to generate five targeted questions about a specific topic to assess the user's knowledge. \
            These questions should address foundational and advanced concepts related to the topic.
            """
        )
        
        let userGPTMessage = GPTMessage(
            role: "user",
            content: """
            Generate 2 questions to assess a user's understanding of the topic "\(topic)". \
            The questions should be designed to evaluate their knowledge of key concepts in the topic and highlight areas where they may need improvement. \
            Respond with a JSON array of questions. Do not include any markdown, like this:
            [
                "What is ...?",
                "Explain ...?",
                "How does ...?",
                "What are the key differences between ...?",
                "Why is ... important in the context of ...?"
            ]
            """
        )
        
        let response = try await openAIService.chatCompletion(
            messages: [systemMessage, userGPTMessage]
        )
        
        if let content = response.choices.first?.message.content {
            // Parse the JSON array from the response
            guard let data = content.data(using: .utf8) else {
                throw NSError(domain: "InvalidResponse", code: -1, userInfo: nil)
            }
            print(content)
            print(data)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let questions = try decoder.decode([String].self, from: data)
            return questions
        } else {
            throw NSError(domain: "NoContent", code: -1, userInfo: nil)
        }
    }
    
    private func gradeSentenceSegments(question: String, fullResponse: String) async throws -> [FeedbackSegment] {
        let systemMessage = GPTMessage(
            role: "system",
            content: """
            You are a detailed grader for an educational app that assesses users' understanding of complex topics. \
            Your role is to evaluate each small segment of a user's explanation and provide targeted feedback. \
            The user's response is a casual speech transcript, so do not penalize for punctuation, grammar, or informal phrasing. \
            Focus solely on the correctness and clarity of the content in their explanation.
            """
        )
        
        let userGPTMessage = GPTMessage(
            role: "user",
            content: """
            Please analyze the following user response to the question "\(question)". \
            Evaluate the content generously, focusing on whether the explanation demonstrates understanding of the topic. \
            Do not penalize for missing punctuation, casual speech patterns, or minor grammatical errors. \
            Mark something as incorrect only if the content itself is factually incorrect or incomplete and do this only if absoultely necessary. \
            Break down the response into sentences and provide feedback for each sentence with the following structure:
            {
                "text": "<sentence>",
                "feedbackType": "<correct | incorrect>",
                "explanation": "<brief explanation of why this part is marked as such>",
                "concept": "<The concept addressed by this part>"
            }
            Respond with a JSON array of feedback for each sentence. Do not respond with any markdown. User response: "\(fullResponse)"
            """
        )
        
        let response = try await openAIService.chatCompletion(
            messages: [systemMessage, userGPTMessage]
        )
        
        if let content = response.choices.first?.message.content {
            // Parse the JSON array from the response
            guard let data = content.data(using: .utf8) else {
                throw NSError(domain: "InvalidResponse", code: -1, userInfo: nil)
            }
            
            print("data: ", data)
            print("content: ", content)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let segments = try decoder.decode([FeedbackSegment].self, from: data)
            return segments
        } else {
            throw NSError(domain: "NoContent", code: -1, userInfo: nil)
        }
    }
    
    func getDefinition(for concept: String) async throws -> String {
        // Return cached definition if available
        if let cachedDefinition = definitions[concept] {
            return cachedDefinition
        }
        
        let systemMessage = GPTMessage(
            role: "system",
            content: """
               You are an AI assistant providing detailed, concise definitions for educational purposes. \
               Your task is to define the concept and explain its importance.
               """
        )
        
        let userGPTMessage = GPTMessage(
            role: "user",
            content: """
               Please provide a detailed definition of the concept "\(concept)" and explain its relevance or application in learning or practical contexts.
               """
        )
        
        let response = try await openAIService.chatCompletion(
            messages: [systemMessage, userGPTMessage]
        )
        
        if let content = response.choices.first?.message.content {
            let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
            // Cache the definition
            definitions[concept] = trimmedContent
            return trimmedContent
        } else {
            throw NSError(domain: "NoContent", code: -1, userInfo: nil)
        }
    }
    
    private func calculateOverallGrade(for segments: [FeedbackSegment]) -> Double {
        let totalCount = segments.count
        
        // Calculate the points for correct and partially correct segments
        let totalPoints = segments.reduce(0.0) { points, segment in
            switch segment.feedbackType {
            case .correct:
                return points + 1.0 // Full point for correct
            case .partiallyCorrect:
                return points + 0.5 // Half point for partially correct
            case .incorrect:
                return points // No points for incorrect
            }
        }
        
        // Avoid division by zero
        guard totalCount > 0 else { return 0.0 }
        
        return totalPoints / Double(totalCount)
    }
    
    func getMockTopics() -> [Topic] {
        return [
            Topic(
                id: UUID(),
                name: "Mathematics",
                icon: "function",
                concepts: [
                    Concept(id: UUID(), name: "Calculus", definition: "The mathematical study of continuous change."),
                    Concept(id: UUID(), name: "Linear Algebra", definition: nil), // No definition provided
                    Concept(id: UUID(), name: "Probability and Statistics", definition: "The study of randomness and data interpretation.")
                ]
            ),
            Topic(
                id: UUID(),
                name: "Biology",
                icon: "leaf",
                concepts: [
                    Concept(id: UUID(), name: "Cell Structure", definition: "The composition and organization of cells."),
                    Concept(id: UUID(), name: "DNA and Genetics", definition: "The study of heredity and genetic information."),
                    Concept(id: UUID(), name: "Evolutionary Theory", definition: nil) // No definition provided
                ]
            ),
            Topic(
                id: UUID(),
                name: "Technology",
                icon: "gear",
                concepts: [
                    Concept(id: UUID(), name: "Artificial Intelligence", definition: "The simulation of human intelligence in machines."),
                    Concept(id: UUID(), name: "Cybersecurity", definition: nil), // No definition provided
                    Concept(id: UUID(), name: "Blockchain", definition: "A distributed ledger technology for secure transactions.")
                ]
            )
        ]
    }
    
}
