//
//  PromptView.swift
//  ExplainIt
//
//  Created by Olti Maloku on 2024-11-15.
//

import SwiftUI

struct PromptView: View {
    @State private var inputText: String = ""
    
    let concepts = [
            (title: "Computer Networking", icon: "network", action: {}),
            (title: "Data Structures", icon: "list.bullet", action: {}),
            (title: "Algorithms", icon: "gearshape", action: {}),
            (title: "SwiftUI Basics", icon: "swift", action: {}),
            (title: "iOS Development", icon: "iphone", action: {})
        ]
    
    var body: some View {
        VStack (alignment: .center){
            Text("Learn Anything.")
                            .font(.title2)
                            .fontWeight(.regular)
                            .padding(.bottom, 8)
            
            EITextField(text: $inputText, placeholder: "Enter a concept", padding: 16, icon: "brain")
                .padding(.bottom, 20)
            
            Text("My Concepts")
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
            
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(concepts, id: \.title) { concept in
                        ConceptView(title: concept.title, action: concept.action)
                    }
                }
            }
            
        }
        .padding(20)
        .background(Color(.systemGray6))
    }
}

#Preview {
    PromptView()
}
