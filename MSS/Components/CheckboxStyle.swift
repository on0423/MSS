//
//  CheckboxStyle.swift
//  MSS
//
//  Created by 大塚直樹 on 2024/03/09.
//

import Foundation
import SwiftUI

//チェックボックスのカスタム
public struct CheckBoxStyle: ToggleStyle {
    public func makeBody(configuration: Configuration) -> some View {
        HStack {
            Button {
                configuration.isOn.toggle()
            } label: {
                Image(systemName: configuration.isOn ? "checkmark.circle" : "circle")
            }
            .foregroundStyle(configuration.isOn ? Color.green : Color.gray)

            configuration.label
        }
    }
}

extension ToggleStyle where Self == CheckBoxStyle {
    public static var checkBox: CheckBoxStyle {
        .init()
    }
}
