//
//  ExplainView.swift
//  ExplainIt
//
//  Created by Olti Maloku on 2024-11-21.
//

import SwiftUI

struct ExplainView: View {
    @StateObject private var speechRecognizer = SpeechRecognitionService()
    @EnvironmentObject private var viewModel: ExplainViewModel
    @State private var currentQuestionIndex: Int = 0
    
    let questions: [String]
    
    var body: some View {
        
        VStack {
            Spacer()
            
            // Display the current question
            if currentQuestionIndex < questions.count {
                Text(questions[currentQuestionIndex])
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
            } else {
                Text("You've completed the questions!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
            }
            
            // Display the recognized text
            Text(speechRecognizer.recognizedText.isEmpty ? "Tap the microphone to answer" : speechRecognizer.recognizedText)
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(15)
                .foregroundColor(Color(UIColor.label))
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            
            // Display feedback after grading
            if let feedbackAnalysis = viewModel.feedbackAnalysis {
                ScrollView {
                    FeedbackMessageView(feedbackAnalysis: feedbackAnalysis)
                        .padding(.top, 20)
                        .padding(.horizontal, 24)
                        .environmentObject(viewModel)
                }
            } else if viewModel.isLoading {
                ProgressView("Analyzing your response...")
                    .foregroundColor(.white)
                    .padding(.top, 20)
            }
            
            Spacer()
            
            HStack {
                Button( action: {
                    if currentQuestionIndex != 0 {
                        currentQuestionIndex -= 1
                        viewModel.resetFeedback()
                        speechRecognizer.resetTranscript()
                    }
                }) {
                    Text("Back")
                }
                Spacer()
                // Microphone button
                Button(action: {
                    speechRecognizer.toggleRecording()
                    if !speechRecognizer.isRecording {
                        // When recording stops, send the recognized text for grading
                        Task {
                            await viewModel.gradeResponse(question: questions[currentQuestionIndex], text: speechRecognizer.recognizedText)
                            
                        }
                    } else {
                        // Reset previous feedback
                        viewModel.resetFeedback()
                        speechRecognizer.resetTranscript()
                    }
                }) {
                    
                    ZStack {
                        Circle()
                            .fill(speechRecognizer.isRecording ? Color.red : Color.blue)
                            .frame(width: 70, height: 70)
                            .shadow(color: speechRecognizer.isRecording ? Color.red.opacity(0.7) : Color.blue.opacity(0.7), radius: 10, x: 0, y: 5)
                        
                        Image(systemName: "mic.fill")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    
                }
                Spacer()
                Button( action: {
                    if currentQuestionIndex < questions.count - 1 {
                        currentQuestionIndex += 1
                        viewModel.resetFeedback()
                        speechRecognizer.resetTranscript()
                    }
                }) {
                    Text(!speechRecognizer.recognizedText.isEmpty || viewModel.feedbackAnalysis != nil ? "Next" : "Skip")
                }
                
            }
            .padding(.bottom, 50)
            .padding(.horizontal, 20)
            .disabled(currentQuestionIndex >= questions.count)
        }
        
        .onAppear {
            speechRecognizer.requestAuthorization()
        }
    }
}

#Preview {
    ExplainView(questions: ["What is the OSI Model?", "Explain how TCP and UDP differ.", "What is the role of DNS?"])
}
