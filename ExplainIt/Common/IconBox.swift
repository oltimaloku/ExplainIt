//
//  IconBox.swift
//  ExplainIt
//
//  Created by Olti Maloku on 2024-11-15.
//

import SwiftUI

struct IconBox: View {
    var iconName: String // Name of the SF Symbol
    var boxSize: CGFloat = 50 // Size of the box
    var iconSize: CGFloat = 20 // Size of the icon
    var backgroundColor: Color = Color(.systemGray6) // Background color
    var foregroundColor: Color = Color.primary // Icon color
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(backgroundColor)
                .frame(width: boxSize, height: boxSize)
            
            Image(systemName: iconName)
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
                .foregroundColor(foregroundColor)
        }
    }
}

#Preview {
    IconBox(iconName: "star.fill")
}
