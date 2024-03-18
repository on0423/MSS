//
//  RegisterAreaData.swift
//  MSS
//
//  Created by 大塚直樹 on 2024/03/09.
//

import Foundation

struct RegisterAreaData: Codable, Equatable{
    var tradeFlag: Bool
    var tradeID: String
    var title: String
    var diffEntryFlag: Bool
    var diffEntryPrice: Int?
    var maisu: Int
    var profitTakingFlag: Bool
    var lossCutFlag: Bool
    var settlementPrice: Int
    var range: Int
    var PL: Int
    var winLose: String
    var finishDate: Date
    var possessionTime: Int
    var confirmFlag: Bool
}
