import SwiftUI

struct ChatView: View {
    @StateObject var viewModel: ChatViewModel
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 0) {
                messagesList
                inputArea
            }
        }
    }
    
    private var messagesList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.messages) { message in
                        if let feedbackAnalysis = message.feedbackAnalysis {
                            FeedbackMessageView(feedbackAnalysis: feedbackAnalysis)
                        } else {
                            MessageBubbleView(message: message)
                        }
                    }
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    }
                }
                .padding()
            }
            .onChange(of: viewModel.messages.count) { _ in
                if let lastMessage = viewModel.messages.last {
                    withAnimation {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }
    
    private var inputArea: some View {
        HStack(spacing: 12) {
            EITextField(text: $viewModel.inputText, placeholder: "Ask me anything...")
               
           
            Button {
                Task {
                    await viewModel.sendMessage()
                }
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.blue)
            }
            .disabled(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading)
        }
        .padding()
        .background(Color(.systemBackground))
        .shadow(radius: 2)
    }
}



struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        let mockSegments = [
            FeedbackSegment(
                text: "Photosynthesis is a process that plants use",
                feedbackType: .correct,
                explanation: "Correct understanding that photosynthesis is a process used by plants.",
                concept: "Photosynthesis"
            ),
            FeedbackSegment(
                text: "to eat food from the soil.",
                feedbackType: .incorrect,
                explanation: "Incorrect. Photosynthesis involves producing food from sunlight, not eating from the soil.",
                concept: "Photosynthesis Process"
            )
        ]
        
        let mockFeedbackAnalysis = FeedbackAnalysis(
            segments: mockSegments,
            overallGrade: 0.4
        )
        
        let mockMessages = [
            ChatMessage(
                text: "Testing AI feedback",
                isUserMessage: false,
                timestamp: Date(),
                feedbackAnalysis: mockFeedbackAnalysis
            )
        ]
        
        let viewModel = ChatViewModel(mockMessages: mockMessages)
        
        return ChatView(viewModel: viewModel)
    }
}
