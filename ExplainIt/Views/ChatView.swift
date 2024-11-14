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
            
//            Button(action: {
//                print("Wand button tapped!")
//            }) {
//                Image(systemName: "wand.and.rays")
//                    .resizable()
//                    .frame(width: 25, height: 25)
//                    .foregroundColor(.white)
//                    .padding()
//                    .background(Color.blue)
//                    .clipShape(Circle())
//                    .shadow(radius: 10)
//            }
//            .padding(.trailing, 16)
//            .padding(.top, 16)
        }
    }
    
    private var messagesList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.messages) { message in
                        if message.feedbackSegments.isEmpty {
                            MessageBubbleView(message: message)
                        } else {
                            FeedbackMessageView(feedbackSegments: message.feedbackSegments)
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
            TextField("Ask me anything...", text: $viewModel.inputText)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color(.systemGray6))
                )
                .focused($isFocused)
           
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

struct FeedbackMessageView: View {
    let feedbackSegments: [FeedbackSegment]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(feedbackSegments) { segment in
                FeedbackSegmentView(segment: segment)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct FeedbackSegmentView: View {
    let segment: FeedbackSegment
    @State private var showExplanation = false
    
    var body: some View {
        Text(segment.text)
            .padding(6)
            .background(segment.feedbackType.color)
            .cornerRadius(8)
            .onTapGesture {
                showExplanation.toggle()
            }
            .popover(isPresented: $showExplanation) {
                VStack {
                    Text(segment.concept).bold()
                    Text(segment.explanation)
                        .padding()
                        .frame(maxWidth: 200)
                }
                
            }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        let mockMessages = [
            ChatMessage(
                text: "Testing AI feedback",
                isUserMessage: false,
                timestamp: Date(),
                feedbackSegments: [
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
                    ),
                    FeedbackSegment(
                        text: "Plants take in water through their roots",
                        feedbackType: .correct,
                        explanation: "Accurate statement about how plants absorb water.",
                        concept: "Plant Water Absorption"
                    ),
                    FeedbackSegment(
                        text: "and sunlight through their leaves.",
                        feedbackType: .correct,
                        explanation: "Correct that sunlight is absorbed through the leaves.",
                        concept: "Photosynthesis Process"
                    ),
                    FeedbackSegment(
                        text: "They use their blood to turn sunlight into energy.",
                        feedbackType: .incorrect,
                        explanation: "Incorrect. Plants do not have blood. They use chlorophyll in their leaves for this process.",
                        concept: "Plant Anatomy"
                    ),
                    FeedbackSegment(
                        text: "This process releases oxygen into the air as a byproduct.",
                        feedbackType: .partiallyCorrect,
                        explanation: "Partially correct. Oxygen is indeed released, but not as a waste product; it's a byproduct of splitting water molecules.",
                        concept: "Photosynthesis Byproducts"
                    )
                ]
            )
        ]
        
        let viewModel = ChatViewModel(mockMessages: mockMessages)
        
        return ChatView(viewModel: viewModel) // Pass viewModel to ChatView
    }
}
