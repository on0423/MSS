//
//  RegisterTradingHistoryModel.swift
//  MSS
//
//  Created by 大塚直樹 on 2024/03/09.
//

import Foundation

struct RegisterTradingHistoryModel: Identifiable, Codable {
    var id: String
    var userID: String
    var title: String
    var selectedAction: String
    var entryPrice: Int
    var lossCutPrice: Int
    var lc: Int
    var maxPrice: Int
    var max: Int
    var diffEntryFlag: Bool
    var diffEntryPrice: Int?
    var maisu: Int
    var profitTakingFlag: Bool
    var lossCutFlag: Bool
    var settlementPrice: Int
    var range: Int
    var PL: Int
    var winLose: String
    var startDate: Date
    var finishDate: Date
    var possessionTime: Int
    var memo: String
}
