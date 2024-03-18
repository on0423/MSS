//
//  Calculations.swift
//  MSS
//
//  Created by 大塚直樹 on 2024/03/09.
//

import Foundation

struct Calculations {
    // lc(ロスカット)を計算する関数
    static func calculateLC(entryPrice: String, lossCutPrice: String, selectedAction: ActionType) -> Int {
        guard let entry = Int(entryPrice), let lossCut = Int(lossCutPrice) else { return 0 }
        return selectedAction == .long ? (entry - lossCut) : (lossCut - entry)
    }
    
    // max(最大値幅)を計算する関数
    static func calculateMax(entryPrice: String, maxPrice: String, selectedAction: ActionType) -> Int {
        guard let entry = Int(entryPrice), let max = Int(maxPrice) else { return 0 }
        return selectedAction == .long ? (max - entry) : (entry - max)
    }
    
    // 決済価格計算の呼び出し
    static func callCalcSettlementPrice(tradeID: String, entryPrice: String, settlementPrice: String, lc: Int, profitTakingFlag: Bool,lossCutFlag: Bool, selectedAction: ActionType)-> Int {
        guard let entry = Int(entryPrice), let settlement = Int(settlementPrice) else { return 0}
        
        switch tradeID {
        case "5_15":
            // 5分足の15円利食いの値幅計算
            return calcSettlementPrice(profit: 15, entryPrice: entry, settlementPrice: settlement, lc: lc, profitTakingFlag: profitTakingFlag, lossCutFlag: lossCutFlag, selectedAction: selectedAction)
        case "5_30":
            // 5分足の30円利食いの値幅計算
            return calcSettlementPrice(profit: 30, entryPrice: entry, settlementPrice: settlement, lc: lc, profitTakingFlag: profitTakingFlag, lossCutFlag: lossCutFlag, selectedAction: selectedAction)
        case "5_50":
            // 5分足の50円利食いの値幅計算
            return calcSettlementPrice(profit: 50, entryPrice: entry, settlementPrice: settlement, lc: lc, profitTakingFlag: profitTakingFlag, lossCutFlag: lossCutFlag, selectedAction: selectedAction)
        case "5_MA":
            // MAの値幅計算
            return calcSettlementPriceMA(entryPrice: entry, settlementPrice: settlement, lc: lc, lossCutFlag: lossCutFlag, selectedAction: selectedAction)
        case "15_35":
            // 15分足の35円利食いの値幅計算
            return calcSettlementPrice(profit: 35, entryPrice: entry, settlementPrice: settlement, lc: lc, profitTakingFlag: profitTakingFlag, lossCutFlag: lossCutFlag, selectedAction: selectedAction)
        case "15_50":
            // 15分足の50円利食いの値幅計算
            return calcSettlementPrice(profit: 50, entryPrice: entry, settlementPrice: settlement, lc: lc, profitTakingFlag: profitTakingFlag, lossCutFlag: lossCutFlag, selectedAction: selectedAction)
        case "15_100":
            // 15分足の100円利食いの値幅計算
            return calcSettlementPrice(profit: 100, entryPrice: entry, settlementPrice: settlement, lc: lc, profitTakingFlag: profitTakingFlag, lossCutFlag: lossCutFlag, selectedAction: selectedAction)
        case "15_MA":
            // MAの値幅計算
            return calcSettlementPriceMA(entryPrice: entry, settlementPrice: settlement, lc: lc, lossCutFlag: lossCutFlag, selectedAction: selectedAction)
        default:
            // その他の場合
            return calcSettlementPriceMA(entryPrice: entry, settlementPrice: settlement, lc: lc, lossCutFlag: lossCutFlag, selectedAction: selectedAction)
        }
    }
    
    // 利食いの決済価格計算ロジック
    static func calcSettlementPrice(profit: Int, entryPrice: Int, settlementPrice: Int, lc: Int, profitTakingFlag: Bool,lossCutFlag: Bool, selectedAction: ActionType) -> Int {
        if profitTakingFlag {
            // 利食いあり
            if selectedAction == .long {
                // 買い
                return entryPrice + profit
            } else {
                // 売り
                return entryPrice - profit
            }
        } else {
            // 利食いなし
            if lossCutFlag {      //ロスカットの場合
                if selectedAction == .long {
                    // 買い
                    return entryPrice - lc
                } else {
                    // 売り
                    return entryPrice + lc
                }
            }else {
                return settlementPrice
            }
        }
    }
    
    // 利食いの決済価格計算ロジック
    static func calcSettlementPriceMA(entryPrice: Int, settlementPrice: Int, lc: Int, lossCutFlag: Bool, selectedAction: ActionType) -> Int {
        if lossCutFlag {
            if selectedAction == .long {
                // 買い
                return entryPrice - lc
            } else {
                // 売り
                return entryPrice + lc
            }
        } else {
            // ロスカットなし
            return settlementPrice
        }
    }
    
    
    
    // 値幅計算の呼び出し
    static func callCalcRange(tradeID: String, entryPrice: String, settlementPrice: String, lossCutPrice: String, lc: Int, diffEntryPrice: String, diffEntryFlag: Bool, profitTakingFlag: Bool,lossCutFlag: Bool, selectedAction: ActionType)-> Int {
        guard let entry = Int(entryPrice), let lossCut = Int(lossCutPrice) else { return 0}
        let settlement = Int(settlementPrice) ?? 0
        let diffEntryPrice = Int(diffEntryPrice) ?? 0
        
        switch tradeID {
        case "5_15":
            // 5分足の15円利食いの値幅計算
            return calcRange(profit: 15, entry: entry, settlement: settlement, lossCut: lossCut, lc: lc, diffEntryPrice: diffEntryPrice, diffEntryFlag: diffEntryFlag, profitTakingFlag: profitTakingFlag, lossCutFlag: lossCutFlag, selectedAction: selectedAction)
        case "5_30":
            // 5分足の30円利食いの値幅計算
            return calcRange(profit: 30, entry: entry, settlement: settlement, lossCut: lossCut, lc: lc, diffEntryPrice: diffEntryPrice, diffEntryFlag: diffEntryFlag, profitTakingFlag: profitTakingFlag, lossCutFlag: lossCutFlag, selectedAction: selectedAction)
        case "5_50":
            // 5分足の50円利食いの値幅計算
            return calcRange(profit: 50, entry: entry, settlement: settlement, lossCut: lossCut, lc: lc, diffEntryPrice: diffEntryPrice, diffEntryFlag: diffEntryFlag, profitTakingFlag: profitTakingFlag, lossCutFlag: lossCutFlag, selectedAction: selectedAction)
        case "5_MA":
            // MAの値幅計算
            return calcRangeMA(entry: entry, settlement: settlement, lossCut: lossCut, lc: lc, diffEntryPrice: diffEntryPrice, diffEntryFlag: diffEntryFlag, lossCutFlag: lossCutFlag, selectedAction: selectedAction)
        case "15_35":
            // 15分足の35円利食いの値幅計算
            return calcRange(profit: 35, entry: entry, settlement: settlement, lossCut: lossCut, lc: lc, diffEntryPrice: diffEntryPrice, diffEntryFlag: diffEntryFlag, profitTakingFlag: profitTakingFlag, lossCutFlag: lossCutFlag, selectedAction: selectedAction)
        case "15_50":
            // 15分足の50円利食いの値幅計算
            return calcRange(profit: 50, entry: entry, settlement: settlement, lossCut: lossCut, lc: lc, diffEntryPrice: diffEntryPrice, diffEntryFlag: diffEntryFlag, profitTakingFlag: profitTakingFlag, lossCutFlag: lossCutFlag, selectedAction: selectedAction)
        case "15_100":
            // 15分足の100円利食いの値幅計算
            return calcRange(profit: 100, entry: entry, settlement: settlement, lossCut: lossCut, lc: lc, diffEntryPrice: diffEntryPrice, diffEntryFlag: diffEntryFlag, profitTakingFlag: profitTakingFlag, lossCutFlag: lossCutFlag, selectedAction: selectedAction)
        case "15_MA":
            // MAの値幅計算
            return calcRangeMA(entry: entry, settlement: settlement, lossCut: lossCut, lc: lc, diffEntryPrice: diffEntryPrice, diffEntryFlag: diffEntryFlag, lossCutFlag: lossCutFlag, selectedAction: selectedAction)
        default:
            // その他の場合
            return 0
        }
    }
        
    // 利食いの値幅計算ロジック
    static func calcRange(profit: Int, entry: Int, settlement: Int, lossCut: Int,lc: Int, diffEntryPrice: Int, diffEntryFlag: Bool, profitTakingFlag: Bool,lossCutFlag: Bool, selectedAction: ActionType) -> Int {
        if diffEntryFlag {
            // エントリーポイントが異なる場合
            if profitTakingFlag {
                // 利食いあり
                if selectedAction == .long {
                    // 買い
                    return (entry - diffEntryPrice) + profit
                } else {
                    // 売り
                    return (diffEntryPrice - entry) + profit
                }
            } else {
                // 利食いなし
                if lossCutFlag {      //ロスカットの場合
                    if selectedAction == .long {
                        // 買い
                        return -lc + (entry - diffEntryPrice)
                    } else {
                        // 売り
                        return -lc + (diffEntryPrice - entry)
                    }
                }else {
                    if selectedAction == .long {
                        // 買い
                        return settlement - diffEntryPrice
                    } else {
                        // 売り
                        return diffEntryPrice - settlement
                    }
                }
            }
        } else {   // 本来のポイントでエントリー
            if profitTakingFlag {
                // 利食いあり
                return profit
            } else {
                // 利食いなし
                if lossCutFlag {      //ロスカットの場合
                    return -lc
                }else {
                    if selectedAction == .long {
                        // 買い
                        return settlement - entry
                    } else {
                        // 売り
                        return entry - settlement
                    }
                }
            }
        }
    }
    
    // MAの値幅計算ロジック
    static func calcRangeMA (entry: Int, settlement: Int, lossCut: Int, lc: Int, diffEntryPrice: Int, diffEntryFlag: Bool, lossCutFlag: Bool, selectedAction: ActionType) -> Int {
        if diffEntryFlag {
            // エントリーポイントが異なる場合
            if lossCutFlag {      //ロスカットの場合
                if selectedAction == .long {
                    // 買い
                    return -lc + (entry - diffEntryPrice)
                } else {
                    // 売り
                    return -lc + (diffEntryPrice - entry)
                }
            }else {
                if selectedAction == .long {
                    // 買い
                    return settlement - diffEntryPrice
                } else {
                    // 売り
                    return diffEntryPrice - settlement
                }
            }
        } else {   // 本来のポイントでエントリー
            if lossCutFlag {      //ロスカットの場合
                return -lc
            }else {
                if selectedAction == .long {
                    // 買い
                    return settlement - entry
                } else {
                    // 売り
                    return entry - settlement
                }
            }
        }
    }
    
    // 編集画面での値幅計算
    static func calcEditRange(entryPrice: String, settlementPrice: String, selectedAction: ActionType)-> Int {
        guard let entryPrice = Int(entryPrice), let settlementPrice = Int(settlementPrice) else { return 0}
        if selectedAction == .long {
            // 買い
            return settlementPrice - entryPrice
        } else {
            // 売り
            return entryPrice - settlementPrice
        }
    }
    
    // 損益の計算
    static func calcPL(range: Int, maisu: Int)-> Int{
        return range * maisu
    }
    
    // 保有時間の計算
    static func timeDifference(start: Date, end: Date) -> Int {
        let difference = Calendar.current.dateComponents([.hour, .minute], from: start, to: end)
        let hours = difference.hour ?? 0
        let minutes = difference.minute ?? 0
        return (hours * 60) + minutes
    }
    
    // 期待値(EV:Expected value)の計算
    static func calcEV(winRate: Double, avarageProfit: Double, avarageLoss: Double) -> Double {
        return (avarageProfit * winRate) - (avarageLoss * (1 - winRate))
    }
    
}

