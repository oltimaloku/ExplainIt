//
//  ConceptView.swift
//  ExplainIt
//
//  Created by Olti Maloku on 2024-11-15.
//

import SwiftUI

struct ConceptView: View {
    var title: String
    var icon: String = "circle.square"
    var action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
        }) {
            VStack {
                createHeader()
                createActionRow()
            }.padding()
            
                .background(RoundedRectangle(cornerRadius: 16).fill(Color(.white)))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(.systemGray5)))
        }
    }
    
    private func createHeader() -> some View {
        HStack (alignment: .center){
            IconBox(iconName: icon, backgroundColor: Color.green.opacity(0.2), foregroundColor: Color.black)
            Text(title)
                .font(.headline)
                .foregroundColor(.black)
                .fontWeight(.regular)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        
    }
    
    private func createActionRow() -> some View {
        HStack {
//            createActionContainer(icon: "book", text: "Learn")
//            createActionContainer(icon: "pencil", text: "Practice")
//            createActionContainer(icon: "plus.circle", text: "Expand")
        }
    }
    
    private func createActionContainer(icon: String, text: String) -> some View {
        let containerWidth = (UIScreen.main.bounds.width / 3) - 30
        return Button(action: {
        }){
            VStack {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.black)
                Spacer()
                Text(text)
                    .foregroundColor(.black)
                    .fontWeight(.bold)
                
            }
            
            .padding()
            .frame(width: containerWidth, height: 100 )
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.green.opacity(0.2)))
        }
    }
}

#Preview {
    ConceptView(title: "Computer Networking", action: {
        print("test")
    })
}
