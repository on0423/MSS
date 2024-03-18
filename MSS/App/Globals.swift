//
//  Globals.swift
//  MSS
//
//  Created by 大塚直樹 on 2024/03/09.
//

import Foundation

// どのファイルからもアクセスできるようにグローバルスコープに定義

// 買いor売り
enum ActionType: String {
    case long
    case short

    init(fromString string: String) {
        switch string.lowercased() {
        case "long":
            self = .long
        case "short":
            self = .short
        default:
            self = .long // デフォルトの値
        }
    }

    var displayString: String {
        return self.rawValue.capitalized
    }
}

// ActionType型の値をStringに変換
func ActionTypeToString(_ winLose: ActionType) -> String {
    switch winLose {
    case .long:
        return "long"
    case .short:
        return "short"
    }
}

// 取引の勝敗(一覧画面のデータエリアで使用する)
enum WinLose: String  {
    case win
    case draw
    case lose
    
    init(fromString string: String) {
        switch string.lowercased() {
        case "win":
            self = .win
        case "draw":
            self = .draw
        case "lose":
            self = .lose
        default:
            self = .win // デフォルトの値
        }
    }
    
    var displayString: String {
        return self.rawValue.capitalized
    }
}

// WinLose型の値をStringに変換
func winLoseToString(_ winLose: WinLose) -> String {
    switch winLose {
    case .win:
        return "win"
    case .draw:
        return "draw"
    case .lose:
        return "lose"
    }
}


// 日付文字列をDate型に変換する関数
func stringToDate(_ dateString: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
    dateFormatter.locale = Locale(identifier: "ja_JP")
    return dateFormatter.date(from: dateString) ?? Date()
}

// 日付を文字列に変換
func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/MM/dd HH:mm"
    return formatter.string(from: date)
}

// 日本時間からUTCに変換する関数
func convertToUTC(date: Date) -> Date {
    let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: date))
    return Calendar.current.date(byAdding: .second, value: Int(-timeZoneOffset), to: date)!
}

// UTCのTimestampを日本時間のDateに変換する関数
func convertUTCtoJST(date: Date) -> Date {
    let timeZoneJST = TimeZone(identifier: "Asia/Tokyo")!
    let utcDateComponents = Calendar.current.dateComponents(in: TimeZone(secondsFromGMT: 0)!, from: date)
    let jstDate = Calendar.current.date(from: utcDateComponents)!.addingTimeInterval(TimeInterval(timeZoneJST.secondsFromGMT()))
    return jstDate
}
