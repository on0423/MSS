//
//  TradingHistoryListView.swift
//  MSS
//
//  Created by 大塚直樹 on 2024/03/09.
//

import SwiftUI

struct TradingHistoryListView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    // 選択肢
    let timeAxis = ["5分", "15分"]   // 時間軸の選択肢
    let options5minutes = ["15円", "30円", "50円", "MA"]     // 5分足の選択肢
    let options15minutes = ["35円", "50円", "100円", "MA"]   // 15分足の選択肢
    
    // 選択された選択肢を保持する状態変数
    @State private var selectedTimeAxis: String = "5分"
    @State private var selectedOption5minutes: String = "15円"
    @State private var selectedOption15minutes: String = "35円"
    
    // 日付の状態変数
    @State private var displayStartDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @State private var displayEndDate = Date()
    
    @State private var isSearchAreaVisible = false
    
    // 取得した取引履歴データを保持する状態変数
    @State private var tradingHistoryList: [TradingHistoryModel] = []
    
    // アラート表示用の状態変数
    @State private var showAlert = false
    @State private var alertMessage = ""  // アラートに表示するメッセージ内容
    
    // ビューが表示されるときに取引履歴データを取得する
    private func fetchTradingHistory(userName: String) {
        Task {
            do {
                // APIを呼び出してデータを取得
                let fetchedData = try await fetchTradingHistory1stAPI(userName: userName)
                // 取得したデータを状態変数に格納
                tradingHistoryList = fetchedData
            } catch {
                print("取引履歴の取得に失敗しました: \(error)")
            }
        }
    }
    
    // 勝ち数
    var numberOfWins: Int {
        tradingHistoryList.filter { $0.winLose == "win" }.count
    }
    
    // 負け数
    var numberOfLose: Int {
        tradingHistoryList.filter { $0.winLose == "lose" }.count
    }
    
    var totalProfit: Int { // 合計利益
        tradingHistoryList
            .filter { $0.PL > 0 }
            .reduce(0) { $0 + $1.PL }
    }
    
    var totalLoss: Int {   // 合計損失
        tradingHistoryList
            .filter { $0.PL < 0 }
            .reduce(0) { $0 + $1.PL }
    }
    
//    var totalMax: Int {   // 最大幅の合計
//        tradingHistoryList
//            .filter { $0.max < 0 }
//            .reduce(0) { $0 + $1.max }
//    }
    
    
    var body: some View {
        ScrollView {
            VStack {
                // 検索エリアの表示・非表示をトグルする
                HStack {
                    Text("検索エリア")
                        .font(.title2)
                        .fontWeight(.bold)
                    Toggle(isOn: $isSearchAreaVisible){
                    }
                    .padding(.trailing, 200)
                }
                .padding(.leading, 30)
                
                if isSearchAreaVisible {
                    VStack {
                        VStack {
                            Section(header: CustomHeader(text: "時間軸")) {
                                Picker("選択してください", selection: $selectedTimeAxis) {
                                    ForEach(timeAxis, id: \.self) { option in
                                        Text(option).tag(option)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .background(Color.gray.opacity(0.5))
                                .cornerRadius(10)
                            }
                        }
                        
                        if selectedTimeAxis == "5分" {
                            VStack {
                                Section(header: CustomHeader(text: "区分")) {
                                    Picker("選択してください", selection: $selectedOption5minutes) {
                                        ForEach(options5minutes, id: \.self) { option in
                                            Text(option).tag(option)
                                        }
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
                                    .background(Color.gray.opacity(0.5))
                                    .cornerRadius(10)
                                }
                            }
                        }else {
                            VStack {
                                Section(header: CustomHeader(text: "区分")) {
                                    Picker("選択してください", selection: $selectedOption15minutes) {
                                        ForEach(options15minutes, id: \.self) { option in
                                            Text(option).tag(option)
                                        }
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
                                    .background(Color.gray.opacity(0.5))
                                    .cornerRadius(10)
                                }
                            }
                        }
                        // 日付選択エリア
                        HStack {
                            Text("期間")
                            Spacer()
                        }
                        HStack {
                            DatePicker("", selection: $displayStartDate, displayedComponents: .date)
                                .labelsHidden()
                                .environment(\.locale, Locale(identifier: "ja_JP"))
                            Text("〜")
                            DatePicker("", selection: $displayEndDate, displayedComponents: .date)
                                .labelsHidden()
                                .environment(\.locale, Locale(identifier: "ja_JP"))
                        }
                        .padding()
                        .background(Color.gray.opacity(0.5))
                        .cornerRadius(10)
                        
                        // 検索ボタン
                        Button("検索") {
                            // 検索条件に基づいて取引履歴データを取得する
                            Task {
                                do {
                                    // 時間軸に応じた選択肢を決定
                                    let selectedOption = selectedTimeAxis == "5分" ? selectedOption5minutes : selectedOption15minutes
                                    
                                    // APIを呼び出してデータを取得
                                    let fetchedData = try await searchTradingHistoryAPI(
                                        userName: viewModel.currentUser?.userName ?? "",
                                        timeAxis: selectedTimeAxis,
                                        selectedOption: selectedOption,
                                        startDate: displayStartDate,
                                        finishDate: displayEndDate
                                    )
                                    // 取得したデータを状態変数に格納
                                    tradingHistoryList = fetchedData
                                } catch {
                                    print("取引履歴の検索に失敗しました: \(error)")
                                    alertMessage = "取引履歴の検索に失敗しました"
                                    showAlert = true  // アラートを表示
                                }
                            }
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                    }
                    .padding(20)
                    //.background(.gray)
                    .overlay(RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.secondary, lineWidth: 10))
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    .padding(20)  // 検索エリアの外側に余白を追加
                    
                }

                DataView(tradingHistoryList: $tradingHistoryList, numberOfWins: numberOfWins, numberOfLose: numberOfLose, totalProfit: totalProfit, totalLoss: totalLoss)
                    .padding(.horizontal ,20)
                
                DataListView(tradingHistoryList: $tradingHistoryList)
                    .padding(.horizontal ,20)
            }
        }
        .onAppear {
            // ビューが表示されるときにデータを取得
            if let user = viewModel.currentUser {
                fetchTradingHistory(userName: user.userName)
            } else {
                print("取引履歴の取得に失敗しました:")
                alertMessage = "取引履歴の取得に失敗しました"
                showAlert = true  // アラートを表示
            }
        }
        // アラートの定義
        .alert(isPresented: $showAlert) {
            Alert(title: Text("エラー"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .padding()
        .background(Color.blue2)
        .foregroundStyle(.white)
        .navigationBarTitle("取引履歴一覧", displayMode: .inline)
    }
}

// カスタムセクションヘッダービュー
struct CustomHeader: View {
    let text: String

    var body: some View {
        HStack {
            Text(text)
            Spacer()
        }
    }
}

// データエリア
struct DataView: View {
    @Binding var tradingHistoryList: [TradingHistoryModel]
    var numberOfWins: Int
    var numberOfLose: Int
    var totalProfit: Int
    var totalLoss: Int
//    var totalmax: Int

    var body: some View {
        // データ表示エリア
        VStack {
            HStack {
                Text("データエリア")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.leading, 10)
            VStack(alignment: .leading) {
                // データを表示
                HStack {
                    Text("取引回数: \(tradingHistoryList.count)")
                        .padding(.trailing)
                    // 勝率の計算
                    let winRate = tradingHistoryList.count > 0 ? (Double(numberOfWins) / Double(tradingHistoryList.count)) * 100 : 0.0
                    Text("勝率: \(String(format: "%.2f", winRate)) %")
                }
                Divider()
                HStack {
                    Text("勝ち数: \(numberOfWins)")
                        .padding(.trailing, 10)
                    Text("合計利益: \(totalProfit)")
                        .padding(.trailing, 10)
                }
                .padding(.bottom, 5)
                // 平均利益の計算
                let averageProfit = numberOfWins > 0 ? totalProfit / numberOfWins : 0
                Text("平均利益: \(averageProfit)")
                    .padding(.bottom, 5)
                Divider()
                HStack {
                    Text("負け数: \(numberOfLose)")
                        .padding(.trailing, 10)
                    Text("合計損失: \(-(totalLoss))")
                        .padding(.trailing, 10)
                }
                .padding(.bottom, 5)
                // 平均損失の計算
                let averageLoss = numberOfLose > 0 ? -(totalLoss / numberOfLose) : 0
                Text("平均損失: \(averageLoss)")
                Divider()
                HStack {
                    let RR = numberOfWins > 0 && numberOfLose > 0 ? (Double(averageProfit) / Double(averageLoss)) : 0.0
                    Text("リスクリワード: \(String(format: "%.2f", RR))")
                        .padding(.trailing)
                    // 平均利益と平均損失を計算します
                    let averageProfit = numberOfWins > 0 ? Double(totalProfit) / Double(numberOfWins) : 0
                    let averageLoss = numberOfLose > 0 ? Double(totalLoss) / Double(numberOfLose) : 0

                    // 勝率を計算
                    let winRate = Double(numberOfWins) / Double(tradingHistoryList.count)

                    // 期待値を計算
                    // 平均損失は正で計算するため、-を使用
                    let expectedValue = winRate > 0.0 ? Calculations.calcEV(winRate: winRate, avarageProfit: Double(averageProfit), avarageLoss: Double(-averageLoss)) : 0.0

                    Text("期待値: \(String(format: "%.2f", expectedValue))")
                        .padding(.trailing)
                }
                
                // 平均最大幅の計算
//                let averageMax = tradingHistoryList.count > 0 ? Double(totalmax) / Double(tradingHistoryList.count) : 0.0
//                Text("平均最大幅: \(averageMax)")
            }.padding()
            .overlay(RoundedRectangle(cornerRadius: 30)
                .stroke(Color.secondary, lineWidth: 10))
            .clipShape(RoundedRectangle(cornerRadius: 30))
        }
    }
}


// 一覧エリア
struct DataListView: View {
    @Binding var tradingHistoryList: [TradingHistoryModel]

    var body: some View {
        // 一覧エリア
        VStack {
            HStack {
                Text("一覧エリア")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.leading, 15)
            VStack {
                // 列のタイトル
                HStack {
                    Text("種類")
                        .frame(width: 50, alignment: .center)
                        .fontWeight(.bold)
                    Text("売買")
                        .frame(width: 50, alignment: .center)
                        .fontWeight(.bold)
                    Text("開始日")
                        .frame(width: 100, alignment: .center)
                        .fontWeight(.bold)
                    Text("枚数")
                        .frame(width: 50, alignment: .center)
                        .fontWeight(.bold)
                    Text("損益")
                        .frame(width: 50, alignment: .center)
                        .fontWeight(.bold)

                }
                .padding(.bottom, 2)
                Divider()
                // データ行
                ForEach(tradingHistoryList, id: \.id) { history in
                    NavigationLink(destination: TradingHistoryDetailView(tradingHistoryModel: history)) {
                        HStack {
                            Text(history.title)
                                .frame(width: 50, alignment: .center)
                            Text(history.selectedAction)
                                .frame(width: 50, alignment: .center)
                            Text(formatDate(history.startDate))
                                .frame(width: 100, alignment: .center)
                            Text("\(history.maisu)")
                                .frame(width: 50, alignment: .center)
                            Text("\(history.PL)")
                                .frame(width: 50, alignment: .center)
                        }
                    }
                    Divider()  // 行ごとに区切り線を追加
                }
            }
            .padding()
            .overlay(RoundedRectangle(cornerRadius: 30)
                .stroke(Color.secondary, lineWidth: 10))
            .clipShape(RoundedRectangle(cornerRadius: 30))
        }
    }
}
