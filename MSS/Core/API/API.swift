//
//  API.swift
//  MSS
//
//  Created by 大塚直樹 on 2024/03/09.
//

import Foundation

import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

// 履歴登録API
func saveTradingHistoryAPI(
    userID: String, title: String, selectedAction: String, entryPrice: Int, lossCutPrice: Int,
    lc: Int, maxPrice: Int, max: Int, diffEntryFlag: Bool, diffEntryPrice: Int?,
    maisu: Int, profitTakingFlag: Bool, lossCutFlag: Bool,
    settlementPrice: Int, range: Int, PL: Int, winLose: String, startDate: Date,
    finishDate: Date, possessionTime: Int, memo: String, timeAxis: Int, tradeID: String
) async throws {
    do {
        let db = Firestore.firestore()
        let documentId = UUID().uuidString // UUIDを生成してdocumentIdとして使用
        // tradeIDに基づいてコレクション名を設定
        let collectionName: String
        if timeAxis == 5 {
            if tradeID == "5_15" {
                collectionName = "five_15"
            } else if tradeID == "5_30" {
                collectionName = "five_30"
            } else if tradeID == "5_50" {
                collectionName = "five_50"
            } else {
                collectionName = "five_MA"
            }
        } else if timeAxis == 15 {
            if tradeID == "15_35" {
                collectionName = "fifteen_35"
            } else if tradeID == "15_50" {
                collectionName = "fifteen_50"
            } else if tradeID == "15_100" {
                collectionName = "fifteen_100"
            } else {
                collectionName = "fifteen_MA"
            }
        } else {
            throw NSError(domain: "Invalid tradeID", code: 0, userInfo: nil)
        }
        
        // エントリー価格を設定
        let actualEntryPrice: Int
        if diffEntryFlag {
            actualEntryPrice = diffEntryPrice ?? entryPrice
        } else {
            actualEntryPrice = entryPrice
        }
        
        // 日本時間で入力されたエントリー時間、決済時間をUTCに変換
        let startDateUTC = convertToUTC(date: startDate)
        let finishDateUTC = convertToUTC(date: finishDate)

        let data: [String: Any] = [
            "id": documentId,
            "userID": userID,
            "title": title,
            "selectedAction": selectedAction,
            "entryPrice": actualEntryPrice,
            "lossCutPrice": lossCutPrice,
            "lc": lc,
            "maxPrice": maxPrice,
            "max": max,
            "tradeID": tradeID,
            "maisu": maisu,
            "profitTakingFlag": profitTakingFlag,
            "lossCutFlag": lossCutFlag,
            "settlementPrice": settlementPrice,
            "range": range,
            "PL": PL,
            "winLose": winLose,
            "startDate": Timestamp(date: startDateUTC), // DateをTimestampに変換
            "finishDate": Timestamp(date: finishDateUTC), // DateをTimestampに変換
            "possessionTime": possessionTime,
            "memo": memo
        ]

        // 指定したコレクション名とドキュメントIDでデータを保存
        try await db.collection(collectionName).document(documentId).setData(data)
    } catch {
        print("DEBUG: 取引履歴の登録に失敗しました: \(error.localizedDescription)")
    }
    
}


// 取引履歴一覧初期表示API
func fetchTradingHistory1stAPI(userID: String) async throws -> [TradingHistoryModel] {
    let db = Firestore.firestore()
    var tradingHistoryList: [TradingHistoryModel] = []
    
    let timeZoneJST = TimeZone(identifier: "Asia/Tokyo")!
    var calendar = Calendar.current
    calendar.timeZone = timeZoneJST  // タイムゾーンを日本に設定
    calendar.firstWeekday = 2  // 週の最初の曜日を月曜日に設定（日曜=1、月曜=2）

    let currentDate = Date()
    let currentComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate)
    var weekStart = calendar.date(from: currentComponents)!
    
    // weekStartが月曜日であることを確認し、そうでない場合は調整
    while calendar.component(.weekday, from: weekStart) != 2 {  // 2は月曜日
        weekStart = calendar.date(byAdding: .day, value: -1, to: weekStart)!
    }
    
    let weekEnd = calendar.date(byAdding: .day, value: 5, to: weekStart)!
    
    // 日本時間での開始日と終了日をUTCに変換
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    dateFormatter.timeZone = timeZoneJST
    
    let weekStartString = dateFormatter.string(from: weekStart)
    let weekEndString = dateFormatter.string(from: weekEnd)

    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")  // UTCに変換
    let weekStartUTC = dateFormatter.date(from: weekStartString)!
    let weekEndUTC = dateFormatter.date(from: weekEndString)!

    // Firestoreのクエリを使用して特定のuserIDに一致するドキュメントを検索
    let querySnapshot = try await db.collection("five_MA") // デフォルトとして"five_MA"コレクションの実行日が含まれる週のデータ(平日のみ)を取得
        .whereField("userID", isEqualTo: userID)
        .whereField("startDate", isGreaterThanOrEqualTo: weekStartUTC)
        .whereField("startDate", isLessThanOrEqualTo: weekEndUTC)
        .getDocuments()

    // クエリの結果からデータを抽出し、RegisterAreaDataのリストを作成
    for document in querySnapshot.documents {
        let data = document.data()
        if let id = data["id"] as? String,
           let userID = data["userID"] as? String,
           let title = data["title"] as? String,
           let selectedAction = data["selectedAction"] as? String,
           let entryPrice = data["entryPrice"] as? Int,
           let lossCutPrice = data["lossCutPrice"] as? Int,
           let lc = data["lc"] as? Int,
           let maxPrice = data["maxPrice"] as? Int,
           let max = data["max"] as? Int,
           let tradeID = data["tradeID"] as? String,
           let maisu = data["maisu"] as? Int,
           let settlementPrice = data["settlementPrice"] as? Int,
           let range = data["range"] as? Int,
           let PL = data["PL"] as? Int,
           let winLose = data["winLose"] as? String,
           let startDateTimestamp = data["startDate"] as? Timestamp,
           let finishDateTimestamp = data["finishDate"] as? Timestamp,
           let possessionTime = data["possessionTime"] as? Int,
           let memo = data["memo"] as? String {
            // UTCのTimestampをDateに変換
            let startDateUTC = startDateTimestamp.dateValue()
            let finishDateUTC = finishDateTimestamp.dateValue()

            // UTCのDateを日本時間のDateに変換
            let startDateJST = convertUTCtoJST(date: startDateUTC)
            let finishDateJST = convertUTCtoJST(date: finishDateUTC)

            let tradingHistoryModel = TradingHistoryModel(
                id: id,
                userID: userID,
                title: title,
                selectedAction: selectedAction,
                entryPrice: entryPrice,
                lossCutPrice: lossCutPrice,
                lc: lc,
                maxPrice: maxPrice,
                max: max,
                tradeID: tradeID,
                maisu: maisu,
                profitTakingFlag: data["profitTakingFlag"] as? Bool ?? false,
                lossCutFlag: data["lossCutFlag"] as? Bool ?? false,
                settlementPrice: settlementPrice,
                range: range,
                PL: PL,
                winLose: winLose,
                startDate: startDateJST,     // 日本時間に変換したstartDate
                finishDate: finishDateJST,   // 日本時間に変換したfinishDate
                possessionTime: possessionTime,
                memo: memo
            )
            tradingHistoryList.append(tradingHistoryModel)
        }
    }

    return tradingHistoryList
}

// データ検索API
func searchTradingHistoryAPI(userID: String, timeAxis: String, selectedOption: String, startDate: Date, finishDate: Date) async throws -> [TradingHistoryModel] {
    let db = Firestore.firestore()
    var tradingHistoryList: [TradingHistoryModel] = []
    let calendar = Calendar.current
    
    // コレクション名の判定
    let collectionName: String
    if timeAxis == "5分" {
        if selectedOption == "15円" {
            collectionName = "five_15"
        } else if selectedOption == "30円" {
            collectionName = "five_30"
        } else if selectedOption == "50円" {
            collectionName = "five_50"
        } else if selectedOption == "MA" {
            collectionName = "five_MA"
        } else {
            throw NSError(domain: "Invalid selectedOption5minutes", code: 0, userInfo: nil)
        }
    } else if timeAxis == "15分" {
        if selectedOption == "35円" {
            collectionName = "fifteen_35"
        } else if selectedOption == "50円" {
            collectionName = "fifteen_50"
        } else if selectedOption == "100円" {
            collectionName = "fifteen_100"
        } else if selectedOption == "MA" {
            collectionName = "fifteen_MA"
        } else {
            throw NSError(domain: "Invalid selectedOption15minutes", code: 0, userInfo: nil)
        }
    } else {
        throw NSError(domain: "Invalid timeAxis", code: 0, userInfo: nil)
    }
    
    // 日本時間で入力されたエントリー時間、決済時間をUTCに変換
    // 開始日はその日の0時0分0秒、終了日はその日の23時59分59秒に設定
    let startDateWithTime = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: startDate)!
    let startDateUTC = convertToUTC(date: startDateWithTime)
    let finishDateWithTime = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: finishDate)!
    let finishDateUTC = convertToUTC(date: finishDateWithTime)

    // Firestoreのクエリを使用して選択された期間内で特定のuserIDに一致するドキュメントを検索
    let querySnapshot = try await db.collection(collectionName)
        .whereField("userID", isEqualTo: userID)
        .whereField("startDate", isGreaterThanOrEqualTo: startDateUTC)
        .whereField("startDate", isLessThanOrEqualTo: finishDateUTC)
        .getDocuments()

    // クエリの結果からデータを抽出し、RegisterAreaDataのリストを作成
    for document in querySnapshot.documents {
        let data = document.data()
        if let id = data["id"] as? String,
           let userID = data["userID"] as? String,
           let title = data["title"] as? String,
           let selectedAction = data["selectedAction"] as? String,
           let entryPrice = data["entryPrice"] as? Int,
           let lossCutPrice = data["lossCutPrice"] as? Int,
           let lc = data["lc"] as? Int,
           let maxPrice = data["maxPrice"] as? Int,
           let max = data["max"] as? Int,
           let tradeID = data["tradeID"] as? String,
           let maisu = data["maisu"] as? Int,
           let settlementPrice = data["settlementPrice"] as? Int,
           let range = data["range"] as? Int,
           let PL = data["PL"] as? Int,
           let winLose = data["winLose"] as? String,
           let startDateTimestamp = data["startDate"] as? Timestamp,
           let finishDateTimestamp = data["finishDate"] as? Timestamp,
           let possessionTime = data["possessionTime"] as? Int,
           let memo = data["memo"] as? String {
            // UTCのTimestampをDateに変換
            let startDateUTC = startDateTimestamp.dateValue()
            let finishDateUTC = finishDateTimestamp.dateValue()

            // UTCのDateを日本時間のDateに変換
            let startDateJST = convertUTCtoJST(date: startDateUTC)
            let finishDateJST = convertUTCtoJST(date: finishDateUTC)

            let tradingHistoryModel = TradingHistoryModel(
                id: id,
                userID: userID,
                title: title,
                selectedAction: selectedAction,
                entryPrice: entryPrice,
                lossCutPrice: lossCutPrice,
                lc: lc,
                maxPrice: maxPrice,
                max: max,
                tradeID: tradeID,
                maisu: maisu,
                profitTakingFlag: data["profitTakingFlag"] as? Bool ?? false,
                lossCutFlag: data["lossCutFlag"] as? Bool ?? false,
                settlementPrice: settlementPrice,
                range: range,
                PL: PL,
                winLose: winLose,
                startDate: startDateJST,        // 日本時間に変換したstartDate
                finishDate: finishDateJST,      // 日本時間に変換したfinishDate
                possessionTime: possessionTime,
                memo: memo
            )
            tradingHistoryList.append(tradingHistoryModel)
        }
    }

    return tradingHistoryList
}

// 履歴編集API
func editTradingHistoryAPI(
    id: String, // 編集するドキュメントのIDを引数として追加
    userID: String, title: String, selectedAction: String, entryPrice: Int, lossCutPrice: Int,
    lc: Int, maxPrice: Int, max: Int,
    maisu: Int, profitTakingFlag: Bool, lossCutFlag: Bool,
    settlementPrice: Int, range: Int, PL: Int, winLose: String, startDate: Date,
    finishDate: Date, possessionTime: Int, memo: String, tradeID: String
) async throws {
    do {
        let db = Firestore.firestore()

        // tradeIDで登録するコレクション名を判定
        let collectionName: String
        switch tradeID {
        case "5_15":
            collectionName = "five_15"
        case "5_30":
            collectionName = "five_30"
        case "5_50":
            collectionName = "five_50"
        case "5_MA":
            collectionName = "five_MA"
        case "15_35":
            collectionName = "fifteen_35"
        case "15_50":
            collectionName = "fifteen_50"
        case "15_100":
            collectionName = "fifteen_100"
        case "15_MA":
            collectionName = "fifteen_MA"
        // その他のtradeIDに対応するコレクション名...
        default:
            throw NSError(domain: "Invalid tradeID", code: 0, userInfo: nil)
        }
        
        // 日本時間で入力されたエントリー時間、決済時間をUTCに変換
        let startDateUTC = convertToUTC(date: startDate)
        let finishDateUTC = convertToUTC(date: finishDate)

        let data: [String: Any] = [
            "id": id,
            "userID": userID,
            "title": title,
            "selectedAction": selectedAction,
            "entryPrice": entryPrice,
            "lossCutPrice": lossCutPrice,
            "lc": lc,
            "maxPrice": maxPrice,
            "max": max,
            "tradeID": tradeID,
            "maisu": maisu,
            "profitTakingFlag": profitTakingFlag,
            "lossCutFlag": lossCutFlag,
            "settlementPrice": settlementPrice,
            "range": range,
            "PL": PL,
            "winLose": winLose,
            "startDate": Timestamp(date: startDateUTC), // DateをTimestampに変換
            "finishDate": Timestamp(date: finishDateUTC), // DateをTimestampに変換
            "possessionTime": possessionTime,
            "memo": memo
        ]

        // 指定したコレクション名と既存のドキュメントIDでデータを更新
        try await db.collection(collectionName).document(id).setData(data)
    } catch {
        print("DEBUG: 取引履歴の編集に失敗しました: \(error.localizedDescription)")
    }
}

// 詳細データ取得API
func fetchEditedTradingHistoryAPI(id: String, tradeID: String) async throws -> TradingHistoryModel? {
    let db = Firestore.firestore()
    
    // tradeIDで登録するコレクション名を判定
    let collectionName: String
    if tradeID == "5_15" {
        collectionName = "five_15"
    } else if tradeID == "5_30" {
        collectionName = "five_30"
    } else if tradeID == "5_50" {
        collectionName = "five_50"
    } else if tradeID == "5_MA"{
        collectionName = "five_MA"
    } else if tradeID == "15_35" {
        collectionName = "fifteen_35"
    } else if tradeID == "15_50" {
        collectionName = "fifteen_50"
    } else if tradeID == "15_100" {
        collectionName = "fifteen_100"
    } else {
        collectionName = "fifteen_MA"
    }
    // 指定されたidを持つドキュメントを取得
    let documentSnapshot = try await db.collection(collectionName).document(id).getDocument()

    // クエリの結果からデータを抽出し、RegisterAreaDataのリストを作成
    if let data = documentSnapshot.data() {
        if let userID = data["userID"] as? String,
           let title = data["title"] as? String,
           let selectedAction = data["selectedAction"] as? String,
           let entryPrice = data["entryPrice"] as? Int,
           let lossCutPrice = data["lossCutPrice"] as? Int,
           let lc = data["lc"] as? Int,
           let maxPrice = data["maxPrice"] as? Int,
           let max = data["max"] as? Int,
           let maisu = data["maisu"] as? Int,
           let settlementPrice = data["settlementPrice"] as? Int,
           let range = data["range"] as? Int,
           let PL = data["PL"] as? Int,
           let winLose = data["winLose"] as? String,
           let startDateTimestamp = data["startDate"] as? Timestamp,
           let finishDateTimestamp = data["finishDate"] as? Timestamp,
           let possessionTime = data["possessionTime"] as? Int,
           let memo = data["memo"] as? String {
            // UTCのTimestampをDateに変換
            let startDateUTC = startDateTimestamp.dateValue()
            let finishDateUTC = finishDateTimestamp.dateValue()

            // UTCのDateを日本時間のDateに変換
            let startDateJST = convertUTCtoJST(date: startDateUTC)
            let finishDateJST = convertUTCtoJST(date: finishDateUTC)

            return TradingHistoryModel(
                id: id,
                userID: userID,
                title: title,
                selectedAction: selectedAction,
                entryPrice: entryPrice,
                lossCutPrice: lossCutPrice,
                lc: lc,
                maxPrice: maxPrice,
                max: max,
                tradeID: tradeID,
                maisu: maisu,
                profitTakingFlag: data["profitTakingFlag"] as? Bool ?? false,
                lossCutFlag: data["lossCutFlag"] as? Bool ?? false,
                settlementPrice: settlementPrice,
                range: range,
                PL: PL,
                winLose: winLose,
                startDate: startDateJST,
                finishDate: finishDateJST,
                possessionTime: possessionTime,
                memo: memo
            )
        }
    }

    // 指定されたidを持つドキュメントが見つからない場合はnilを返す
    return nil
}

// 履歴削除API
func deleteTradingHistoryAPI(id: String, tradeID: String) async throws {
    let db = Firestore.firestore()
    
    // tradeIDで登録するコレクション名を判定
    let collectionName: String
    switch tradeID {
    case "5_15":
        collectionName = "five_15"
    case "5_30":
        collectionName = "five_30"
    case "5_50":
        collectionName = "five_50"
    case "5_MA":
        collectionName = "five_MA"
    case "15_35":
        collectionName = "fifteen_35"
    case "15_50":
        collectionName = "fifteen_50"
    case "15_100":
        collectionName = "fifteen_100"
    case "15_MA":
        collectionName = "fifteen_MA"
    // その他のtradeIDに対応するコレクション名...
    default:
        throw NSError(domain: "Invalid tradeID", code: 0, userInfo: nil)
    }

    // Firestoreからドキュメントを削除
    try await db.collection(collectionName).document(id).delete()
}
