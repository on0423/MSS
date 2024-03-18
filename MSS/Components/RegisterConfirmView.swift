//
//  RegisterConfirmView.swift
//  MSS
//
//  Created by 大塚直樹 on 2024/03/09.
//

import SwiftUI

struct RegisterConfirmView: View {
    var selectedAction: ActionType
    var startDate = Date()          // エントリー時間
    var entryPrice: String          // エントリーポイントの価格
    var lossCutPrice: String    // ロスカットの価格
    var lc: Int
    var maxPrice: String        // 最大の価格
    var max: Int
    var recordDataList: [RegisterAreaData]
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
                        Text("取引: \(selectedAction.rawValue)")
                        Text("エントリー時間: \(formatDate(startDate))")
                        Text("エントリー価格: \(entryPrice)")
                        Text("ロスカット価格: \(lossCutPrice)")
                        Text("Lc: \(lc)")
                        Text("最大価格: \(maxPrice)")
                        Text("最大値幅: \(max)")
                        ForEach(recordDataList.indices, id: \.self) { index in
                            VStack(alignment: .leading) {
                                Text("取引区分: \(recordDataList[index].title)")
                                if recordDataList[index].diffEntryFlag {
                                    // 有利なポイントでエントリーしている場合のみ、有利なエントリー価格を表示
                                    if let price = recordDataList[index].diffEntryPrice {
                                        Text("有利なポイント: \(price)")
                                    } else {
                                        Text("有利なポイント: なし")
                                    }
                                }
                                Text("枚数: \(recordDataList[index].maisu)")
                                Text("決済価格: \(recordDataList[index].settlementPrice)")
                                Text("値幅: \(recordDataList[index].range)")
                                Text("損益: \(recordDataList[index].PL)")
                                Text("終了時間: \(formatDate(recordDataList[index].finishDate))")
                                Text("保有時間: \(recordDataList[index].possessionTime/60)時間\(recordDataList[index].possessionTime%60)分")
                            }
                            .padding()  // 内容にパディングを追加
                            .background(Color.gray)  // 背景色を白に設定
                            .cornerRadius(10)  // 角を丸くする
                            .shadow(radius: 5)  // 影を追加
                            .padding(.bottom, 5)  // VStack の下に余白を追加
                        }
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
