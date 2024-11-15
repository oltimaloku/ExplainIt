//
//  EITextField.swift
//  ExplainIt
//
//  Created by Olti Maloku on 2024-11-15.
//

import SwiftUI

struct EITextField: View {
    @Binding var text: String
    var placeholder: String
    var cornerRadius: CGFloat = 25
    var backgroundColor: Color = Color(.white)
    var padding: CGFloat = 10
    var icon: String = "magnifyingglass"
    
    var body: some View {
        HStack {
            Image(systemName: icon).foregroundColor(.gray)
            TextField(placeholder, text: $text)
                .padding(.vertical, padding)
                
        }
        .padding(.horizontal, padding)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius)
                 .fill(backgroundColor)
            )
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius).stroke(Color(.systemGray5), lineWidth: 1)
        )
        
    }
}

#Preview {
    EITextField(text: .constant(""), placeholder: "Ask me anything...")
}
