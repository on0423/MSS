//
//  Judgement.swift
//  MSS
//
//  Created by 大塚直樹 on 2024/03/09.
//

import Foundation

struct Judgement {
    // 損益(PL)によって、勝ち・引き分け・負けを判定する
    static func judgementWinLose(PL: Int) -> WinLose{
        if PL == 0 {
            return .draw
        } else if PL > 0 {
            return .win
        } else {
            return .lose
        }
    }
    
    // WinLose enumの値に基づいてテキストを返す
        static func winLoseText(winLose: WinLose) -> String {
            switch winLose {
            case .win:
                return "勝ち"
            case .draw:
                return "引き分け"
            case .lose:
                return "負け"
            }
        }
}
