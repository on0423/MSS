//
//  MainMenuView.swift
//  MSS
//
//  Created by 大塚直樹 on 2024/03/09.
//

import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        if let user = viewModel.currentUser {
            NavigationView {
                ZStack {
                    Color.blue2   // 背景色を設定
                        .edgesIgnoringSafeArea(.all)  // Safe Areaを含む全体に適用
                    
                    VStack {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.fullname)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .padding(.top, 4)
                                
                                Text(user.email)
                                    .font(.footnote)
                                    .foregroundStyle(.gray)
                            }
                            .padding(.leading, 10)
                            
                            Spacer()
                            
                            Button {
                                viewModel.signOut()
                            } label: {
                                SettingsRowView(imageName: "arrow.left.circle.fill",
                                                title: "ログアウト",
                                                tintColor: .red)
                            }
                            .padding(.trailing, 10)
                            .background(Color.gray) // ボタンの背景色をグレーに設定
                            .cornerRadius(10) // 背景の角を丸くする場合
                        }
                        
                        Spacer()
                        
                        NavigationLink(destination: TradingHistoryListView()) {
                            Text("取引履歴一覧")
                                .padding()
                                .background(Color.blue)
                                .foregroundStyle(.white)
                                .cornerRadius(10)
                        }
                        NavigationLink(destination: RegisterTradingHistoryView(timeAxis: 5)) {
                            Text("5分足登録")
                                .padding(.horizontal, 25)
                                .padding(.vertical)
                                .background(Color.blue)
                                .foregroundStyle(.white)
                                .cornerRadius(10)
                        }
                        NavigationLink(destination: RegisterTradingHistoryView(timeAxis: 15)) {
                            Text("15分足登録")
                                .padding(.horizontal, 20)
                                .padding(.vertical)
                                .background(Color.blue)
                                .foregroundStyle(.white)
                                .cornerRadius(10)
                        }
                        .navigationBarTitle("Topページ", displayMode: .inline)
                        
                        Spacer()
                    }
                }
            }
            .foregroundStyle(.white)
        }
    }
}
