//
//  RegisterTradingHistoryView.swift
//  MSS
//
//  Created by 大塚直樹 on 2024/03/09.
//

import SwiftUI

struct RegisterTradingHistoryView: View {
    let timeAxis:Int
    // イニシャライザ
    init(timeAxis: Int) {
        self.timeAxis = timeAxis
    }
    
    @State private var selectedAction: ActionType = .long
    @State private var startDate = Date()          // エントリー時間
    @State private var entryPrice: String = ""      // エントリーポイントの価格
    @State private var lossCutPrice: String = ""    // ロスカットの価格
    @State private var maxPrice: String = ""        // 最大の価格
    @State private var lc: Int = 0
    @State private var max: Int = 0
    @State private var settlementPrice = ""         // 決済の価格
    @State private var diffEntryPrice = ""          // エントリーポイントが異なる場合の価格
    @State private var memo: String = ""

    var body: some View {
        VStack {
            if timeAxis == 5 {
                RegisteredContentView(timeAxis: 5)
            } else if timeAxis == 15 {
                RegisteredContentView(timeAxis: 15)
            }
        }
        .navigationBarTitle("取引履歴登録", displayMode: .inline)
    }
}
