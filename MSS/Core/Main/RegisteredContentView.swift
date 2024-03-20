//
//  RegisteredContentView.swift
//  MSS
//
//  Created by 大塚直樹 on 2024/03/09.
//

import SwiftUI

struct RegisteredContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
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
    @State private var settlementPrice: String = "0"         // 決済の価格
    @State private var diffEntryPrice: String = ""          // エントリーポイントが異なる場合の価格
    @State private var memo: String = ""
    
    // RegisterAreaData インスタンスを格納する配列
    @State private var recordDataList: [RegisterAreaData] = []   // 記録エリアのデータをもつ配列
    @State private var recordDataListConfirm: [RegisterAreaData] = []   // 最新の記録エリアのデータを管理する配列
    
    @State private var isConfirmModalVisible = false  // 確認モーダルの表示状態
    @State private var isSaveButtonEnabled = false  // 保存ボタンの活性状態
    
    // アラート表示用の状態変数
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @State private var resetTrigger = false // 記録エリアの内容をクリアするのに使用する
    
    @State private var isInputComplete = false  // 入力完了を制御
    
    var body: some View {
        if let user = viewModel.currentUser {
            ScrollView {
                // 買いボタンと売りボタン
                HStack {
                    Button(action: {
                        self.selectedAction = .long
                    }) {
                        Text("Long")
                            .padding()
                            .background(selectedAction == .long ? Color.red : Color.gray)
                            .foregroundStyle(.white)
                    }
                    .cornerRadius(10)
                    
                    Button(action: {
                        self.selectedAction = .short
                    }) {
                        Text("Short")
                            .padding()
                            .background(selectedAction == .short ? Color.blue : Color.gray)
                            .foregroundStyle(.white)
                    }
                    .cornerRadius(10)
                }
                .padding([.leading, .trailing, .top])
                
                VStack(alignment: .leading) {
                    // 基本情報入力エリア
                    HStack {
                        Text("エントリー時間：")
                        DatePicker(selection: $startDate, label: {Text("")})
                            .environment(\.locale, Locale(identifier: "ja_JP"))
                            .padding(.trailing, 20)
                            .padding(.vertical, 10)
                            .background(Color.gray.opacity(0.5))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Text("エントリー価格：")
                        TextField("0", text: $entryPrice)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                            .frame(width: 100)
                            .foregroundStyle(.black)
                    }
                    .padding(.leading)
                    
                    HStack {
                        Text("ロスカット：")
                        TextField("0", text: $lossCutPrice)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                            .frame(width: 100)
                            .foregroundStyle(.black)
                    }
                    .padding(.leading)
                    
                    Text("Lc： \(lc)")
                        .padding(.leading)
                        .onChange(of: selectedAction) { _ in
                            lc = Calculations.calculateLC(entryPrice: entryPrice, lossCutPrice: lossCutPrice, selectedAction: selectedAction)
                        }
                        .onChange(of: entryPrice) { _ in
                            lc = Calculations.calculateLC(entryPrice: entryPrice, lossCutPrice: lossCutPrice, selectedAction: selectedAction)
                        }
                        .onChange(of: lossCutPrice) { _ in
                            lc = Calculations.calculateLC(entryPrice: entryPrice, lossCutPrice: lossCutPrice, selectedAction: selectedAction)
                        }
                    
                    HStack {
                        Text("最大価格：")
                        TextField("0", text: $maxPrice)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                            .frame(width: 100)
                            .foregroundStyle(.black)
                    }
                    .padding(.leading)
                    
                    Text("最大値幅： \(max)")
                        .padding(.leading)
                        .onChange(of: selectedAction) { _ in
                            max = Calculations.calculateMax(entryPrice: entryPrice, maxPrice: maxPrice, selectedAction: selectedAction) }
                        .onChange(of: entryPrice) { _ in
                            max = Calculations.calculateMax(entryPrice: entryPrice, maxPrice: maxPrice, selectedAction: selectedAction) }
                        .onChange(of: maxPrice) { _ in
                            max = Calculations.calculateMax(entryPrice: entryPrice, maxPrice: maxPrice, selectedAction: selectedAction) }
                }
                
                
                // 利食いとMAごとに記録するエリア
                if timeAxis == 5 {
                    // 5分足用の記録エリアを表示
                    VStack(alignment: .leading, spacing: 10) {
                        RecordArea5minutes(tradeID: "5_15",title: "15円", entryPrice: $entryPrice , lossCutPrice: $lossCutPrice, lc: $lc, maxPrice: $maxPrice, max: $max, diffEntryPrice: diffEntryPrice, settlementPrice: settlementPrice,startDate: $startDate, selectedAction: $selectedAction, onSave: updateRecordDataList, onDelete: removeData, resetTrigger: $resetTrigger)
                        RecordArea5minutes(tradeID: "5_30",title: "30円", entryPrice: $entryPrice , lossCutPrice: $lossCutPrice, lc: $lc, maxPrice: $maxPrice, max: $max, diffEntryPrice: diffEntryPrice, settlementPrice: settlementPrice,startDate: $startDate, selectedAction: $selectedAction, onSave: updateRecordDataList, onDelete: removeData, resetTrigger: $resetTrigger)
                        RecordArea5minutes(tradeID: "5_50",title: "50円", entryPrice: $entryPrice , lossCutPrice: $lossCutPrice, lc: $lc, maxPrice: $maxPrice, max: $max, diffEntryPrice: diffEntryPrice, settlementPrice: settlementPrice,startDate: $startDate, selectedAction: $selectedAction, onSave: updateRecordDataList, onDelete: removeData, resetTrigger: $resetTrigger)
                        RecordArea5minutes(tradeID: "5_MA",title: "MA", entryPrice: $entryPrice , lossCutPrice: $lossCutPrice, lc: $lc, maxPrice: $maxPrice, max: $max, diffEntryPrice: diffEntryPrice, settlementPrice: settlementPrice,startDate: $startDate, selectedAction: $selectedAction, onSave: updateRecordDataList, onDelete: removeData, resetTrigger: $resetTrigger)
                    }
                    .padding([.leading, .trailing, .bottom])
                }else if timeAxis == 15 {
                    // 15分足用の記録エリアを表示
                    VStack(alignment: .leading, spacing: 10) {
                        RecordArea15minutes(tradeID: "15_35",title: "35円", entryPrice: $entryPrice , lossCutPrice: $lossCutPrice, lc: $lc, maxPrice: $maxPrice, max: $max, diffEntryPrice: diffEntryPrice, settlementPrice: settlementPrice,startDate: $startDate, selectedAction: $selectedAction, onSave: updateRecordDataList, onDelete: removeData, resetTrigger: $resetTrigger)
                        RecordArea15minutes(tradeID: "15_50",title: "50円", entryPrice: $entryPrice , lossCutPrice: $lossCutPrice, lc: $lc, maxPrice: $maxPrice, max: $max, diffEntryPrice: diffEntryPrice, settlementPrice: settlementPrice,startDate: $startDate, selectedAction: $selectedAction, onSave: updateRecordDataList, onDelete: removeData, resetTrigger: $resetTrigger)
                        RecordArea15minutes(tradeID: "15_100",title: "100円", entryPrice: $entryPrice , lossCutPrice: $lossCutPrice, lc: $lc, maxPrice: $maxPrice, max: $max, diffEntryPrice: diffEntryPrice, settlementPrice: settlementPrice,startDate: $startDate, selectedAction: $selectedAction, onSave: updateRecordDataList, onDelete: removeData, resetTrigger: $resetTrigger)
                        RecordArea15minutes(tradeID: "15_MA",title: "MA", entryPrice: $entryPrice , lossCutPrice: $lossCutPrice, lc: $lc, maxPrice: $maxPrice, max: $max, diffEntryPrice: diffEntryPrice, settlementPrice: settlementPrice,startDate: $startDate, selectedAction: $selectedAction, onSave: updateRecordDataList, onDelete: removeData, resetTrigger: $resetTrigger)
                    }
                    .padding([.leading, .trailing, .bottom])
                }
                
                VStack(alignment: .leading) {
                    Text("メモ:")
                    TextEditor(text: $memo)
                        .lineSpacing(3)
                        .border(Color.gray)
                        .frame(minHeight: 100)
                        .foregroundStyle(.black)
                    // 入力完了のトグル
                    Toggle("入力完了", isOn: $isInputComplete)
                        .padding(.trailing, 230)
                }
                .padding()
                
                HStack {
                    Button(action: {
                        // 確認モーダルで表示するリストを最新のものに更新
                        //recordDataListConfirm = recordDataList
                        // 確認モーダルを表示
                        self.isConfirmModalVisible = true
                        self.isSaveButtonEnabled = false  // もう一度確認ボタンをクリックした際は、モーダル内の確認をクリックするまで保存ボタンは非活性
                    }) {
                        Text("確認")
                            .padding()
                            .background(isInputComplete ? Color.blue : Color.gray)
                            .foregroundStyle(.white)
                            .cornerRadius(10)
                    }
                    .disabled(!isInputComplete)

                    Button(action: {
                        // 保存処理を実行
                        saveTradingHistory(userID: user.id)
                    }) {
                        Text("保存")
                            .padding()
                            .background(isSaveButtonEnabled ? Color.green : Color.gray)
                            .foregroundStyle(.white)
                            .cornerRadius(10)
                    }
                    .disabled(!isSaveButtonEnabled)  // ボタンの活性状態を制御
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 10)
            }
            .background(Color.blue2)
            .foregroundStyle(.white)
            .onTapGesture {
                hideKeyboard()
            }
            .navigationBarTitle("登録内容", displayMode: .inline)
            .sheet(isPresented: $isConfirmModalVisible) {
                // 確認用のモーダルビューを定義
                RegisterConfirmView(selectedAction: selectedAction, startDate: startDate, entryPrice: entryPrice, lossCutPrice: lossCutPrice, lc: lc, maxPrice: maxPrice, max: max, recordDataList: recordDataListConfirm, memo: memo, onConfirm:  {
                    // 確認後の処理
                    if recordDataList != [] {
                        // データがある場合のみ、保存ボタンを活性化
                        self.isSaveButtonEnabled = true
                    }
                    self.isConfirmModalVisible = false
                })
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("通知"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    // キーボードを非表示
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // 記録エリアのデータを更新
    private func updateRecordDataList(with newData: RegisterAreaData) {
        if let index = recordDataList.firstIndex(where: { $0.tradeID == newData.tradeID }) {
            if newData.tradeFlag {
                // tradeFlagがTrueの場合は、既存のデータを更新
                recordDataList[index] = newData
            } else {
                // tradeFlagがFalseの場合は、既存のデータを削除
                recordDataList.remove(at: index)
            }
        } else if newData.tradeFlag {
            // 新しいデータでtradeFlagがTrueの場合は、新しいデータを追加
            recordDataList.append(newData)
        }
        recordDataListConfirm = recordDataList
        isInputComplete = false
    }
    
    // 記録エリアのデータを削除
    func removeData(withTradeID tradeID: String) {
        recordDataList.removeAll { $0.tradeID == tradeID }
    }
    
    // 履歴登録APIを呼び出して、データを保存し、入力情報をクリアする
    func saveTradingHistory(userID:String) {
        Task {
            do {
                let entryPriceInt = Int(entryPrice) ?? 0
                let lossCutPriceInt = Int(lossCutPrice) ?? 0
                let maxPriceInt = Int(maxPrice) ?? 0
                let selectedActionString = selectedAction.rawValue

                // 非同期関数を呼び出し、完了を待つ
                for data in recordDataList {
                    try await saveTradingHistoryAPI(
                        userID: userID, title: data.title, selectedAction: selectedActionString,
                        entryPrice: entryPriceInt, lossCutPrice: lossCutPriceInt, lc: lc, maxPrice: maxPriceInt, max: max,
                        diffEntryFlag: data.diffEntryFlag, diffEntryPrice: data.diffEntryPrice,
                        maisu: data.maisu, profitTakingFlag: data.profitTakingFlag, lossCutFlag: data.lossCutFlag, settlementPrice: data.settlementPrice,
                        range: data.range, PL: data.PL, winLose: data.winLose, startDate: startDate, finishDate: data.finishDate,
                        possessionTime: data.possessionTime, memo: memo, timeAxis: timeAxis, tradeID: data.tradeID
                    )
                }
                
                // 保存処理が成功した場合の処理
                alertMessage = "履歴登録が完了しました"
                showAlert = true

                // 登録完了後の処理（入力項目のリセットなど）
                resetForm()
                resetTrigger = true
            } catch {
                // 保存処理が失敗した場合の処理
                alertMessage = "履歴登録に失敗しました"
                showAlert = true
            }
        }
    }
    
    // アラートを表示する関数
    func showAlert(message: String) {
        self.alertMessage = message
        self.showAlert = true
    }

    // 入力項目のリセット
    func resetForm() {
        self.recordDataList.removeAll()
        self.recordDataList = []
        self.entryPrice = ""
        self.lossCutPrice = ""
        self.maxPrice = ""
        self.settlementPrice = ""
        self.diffEntryPrice = ""
        self.memo = ""
        self.isSaveButtonEnabled = false  // 保存ボタンを非活性に
        self.isInputComplete = false
    }
}
