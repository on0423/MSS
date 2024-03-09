//
//  MSSApp.swift
//  MSS
//
//  Created by 大塚直樹 on 2024/03/09.
//

import SwiftUI
import Firebase
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct MSSApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @StateObject var viewModel = AuthViewModel()
    
    init(){
        //FirebaseApp.configure()
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .blue // ナビゲーションバーの背景色を設定
        appearance.titleTextAttributes = [       // タイトルの設定
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold) // フォントサイズを大きく設定
        ]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white] // 大きなタイトルの色

        // 戻るボタンの色
        UINavigationBar.appearance().tintColor = .white

        // 外観をナビゲーションバーに適用
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
