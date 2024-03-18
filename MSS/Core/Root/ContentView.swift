//
//  ContentView.swift
//  MSS
//
//  Created by 大塚直樹 on 2024/03/09.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        Group {
            if viewModel.userSession != nil {
                MainMenuView()
            } else {
                LoginView()
            }
        }
    }
}
