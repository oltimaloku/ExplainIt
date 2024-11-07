//
//  ContentView.swift
//  ExplainIt
//
//  Created by Olti Maloku on 2024-11-07.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: ConceptViewModel = ConceptViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection
                inputSection
                submitButton
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                }
                feedbackSection
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Concept Practice")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Explain the concept in your own words")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private var inputSection: some View {
        TextEditor(text: $viewModel.userInput)
            .frame(height: 150)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
    }
    
    private var submitButton: some View {
           Button(action: viewModel.submitForFeedback) {
               Text("Submit")
                   .fontWeight(.semibold)
                   .frame(maxWidth: .infinity)
                   .padding()
                   .background(Color.blue)
                   .foregroundColor(.white)
                   .cornerRadius(8)
           }
           .disabled(viewModel.userInput.isEmpty || viewModel.isLoading)
       }
    
    private var feedbackSection: some View {
            VStack(alignment: .leading, spacing: 12) {
                if !viewModel.feedbackSegments.isEmpty {
                    Text("Feedback")
                        .font(.headline)
                        .padding(.top)
                    
                    FeedbackView(segments: viewModel.feedbackSegments) { segment in
                        viewModel.selectedSegment = segment
                        viewModel.showingFeedbackPopup = true
                    }
                }
            }
        }
}



#Preview {
    ContentView()
}


struct FeedbackView: View {
    let segments: [FeedbackSegment]
    let onTapSegment: (FeedbackSegment) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(segments) { segment in
                Text(segment.text)
                    .padding(8)
                    .background(segment.feedbackType.color)
                    .cornerRadius(4)
                    .onTapGesture {
                        onTapSegment(segment)
                    }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct FeedbackPopupView: View {
    let segment: FeedbackSegment
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text(segment.text)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(segment.feedbackType.color)
                    .cornerRadius(8)
                
                Text("Feedback:")
                    .font(.headline)
                
                Text(segment.explanation)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Detailed Feedback")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
