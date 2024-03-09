//
//  InputView.swift
//  MSS
//
//  Created by 大塚直樹 on 2024/03/09.
//

import SwiftUI

struct InputView: View {
    @Binding var text: String
    let title: String
    let placeholder: String
    var isSecureField = false
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .foregroundStyle(.white)
                .fontWeight(.semibold)
                .font(.footnote)
            
            // 安全なフィールドであるか確認
            if isSecureField {
                SecureField(placeholder, text: $text)
                    .font(.system(size: 14))
                    .foregroundStyle(.black)
                    .padding(10)
                    .background(Color.white)
                    .cornerRadius(5)
            } else {
                TextField(placeholder, text: $text)
                    .font(.system(size: 14))
                    .foregroundStyle(.black)
                    .padding(10)
                    .background(Color.white)
                    .cornerRadius(5)
            }
            
            Divider()
        }
    }
}
