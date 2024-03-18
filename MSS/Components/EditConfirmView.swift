//
//  EditConfirmView.swift
//  MSS
//
//  Created by 大塚直樹 on 2024/03/09.
//

import SwiftUI

struct EditConfirmView: View {
    var title: String
    var selectedAction: ActionType
    var entryPrice: String
    var lossCutPrice: String
    var lc: Int
    var maxPrice: String
    var max: Int
    var maisu: Int
    var settlementPrice: String
    var range: Int
    var PL: Int
    var startDate = Date()
    var finishDate = Date()
    var possessionTime: Int
    var memo: String
    var onConfirm: () -> Void

    var body: some View {
        ZStack {
            Color.blue2.ignoresSafeArea(edges: .all)   // 背景色を指定
            ScrollView {
                VStack {
                    HStack {
                        Spacer()
                        Text("確認内容").font(.headline)
                        Spacer()
                    }
                    .padding()
                    VStack(alignment: .leading) {
                        Text("取引区分: \(title)")
                        Text("取引: \(selectedAction.rawValue)")
                        Text("エントリー価格: \(entryPrice)")
                        Text("ロスカット価格: \(lossCutPrice)")
                        Text("Lc: \(lc)")
                        Text("最大価格: \(maxPrice)")
                        Text("最大値幅: \(max)")
                        Text("枚数: \(maisu)")
                        Text("決済価格: \(settlementPrice)")
                        Text("値幅: \(range)")
                        Text("損益: \(PL)")
                        Text("エントリー時間: \(formatDate(startDate))")
                        Text("終了時間: \(formatDate(finishDate))")
                        Text("保有時間: \(possessionTime/60)時間\(possessionTime%60)分")
                        Text("メモ: ")
                        Text("\(memo)")
                    }
                    HStack {
                        Spacer()
                        Button("確認") {
                            onConfirm()  // 親ビューから渡された確認アクションを実行
                        }
                        .padding()
                        .background(Color.green)
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                        Spacer()
                    }
                }
                .padding()
            }
        }
    }
}
