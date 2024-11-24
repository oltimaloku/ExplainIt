import SwiftUI

struct PromptView: View {
    @State private var inputText: String = ""
    @State private var isNavigating: Bool = false
    @State private var generatedQuestions: [String] = []
    
    @StateObject private var viewModel = ExplainViewModel()
    
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                Text("Learn Anything.")
                    .font(.title2)
                    .fontWeight(.regular)
                    .padding(.bottom, 8)
                
                HStack(alignment: .center) {
                    EITextField(text: $inputText, placeholder: "Enter a concept", padding: 16, icon: "brain")
                        .alignmentGuide(.bottom) { $0[.bottom] }
                    
                    Button(action: {
                        Task {
                            // Trigger question generation
                            do {
                                let newTopic = Topic(id: UUID(), name: inputText, icon: "book", concepts: [])
                                viewModel.currentTopic = newTopic
                                
                                if !viewModel.topics.contains(where: { $0.name == inputText }) {
                                    viewModel.topics.append(newTopic)
                                }
                                
                                
                                generatedQuestions = try await viewModel.generateInitialQuestions(for: inputText)
                                isNavigating = true
                            } catch {
                                print("Error generating questions: \(error)")
                            }
                        }
                    }) {
                        IconBox(iconName: "arrow.up", backgroundColor: Color(UIColor.label), foregroundColor: Color(.systemBackground))
                    }
                    .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                
                Text("My Concepts")
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.topics, id: \.id) { topic in
                            NavigationLink(destination: TopicView(topic: topic)) {
                                TopicCard(name: topic.name, icon: topic.icon)
                            }
                            
                            
                        }
                    }
                }
                
                NavigationLink(
                    destination: ExplainView(questions: generatedQuestions).environmentObject(viewModel),
                    isActive: $isNavigating
                ) {
                    EmptyView()
                }
            }
            .padding(20)
            .background(Color(.systemBackground))
            
        }
    }
}

#Preview {
    PromptView()
}
