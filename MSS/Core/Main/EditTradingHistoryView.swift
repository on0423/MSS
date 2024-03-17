//
//  EditTradingHistoryView.swift
//  MSS
//
//  Created by 大塚直樹 on 2024/03/09.
//

import SwiftUI

struct EditTradingHistoryView: View {
    @Environment(\.presentationMode) var presentationMode
    var tradingHistoryModel: TradingHistoryModel

    @State private var selectedAction: ActionType
    @State private var entryPrice: String
    @State private var lossCutPrice: String
    @State private var lc: Int
    @State private var maxPrice: String
    @State private var max: Int
    @State private var maisu: Int
    @State private var profitTakingFlag: Bool
    @State private var lossCutFlag: Bool
    @State private var settlementPrice: String
    @State private var memo: String
    @State private var range: Int
    @State private var PL: Int
    @State private var winLose: WinLose
    @State private var startDate = Date()
    @State private var finishDate = Date()
    @State private var possessionTime: Int
    
    @State private var isConfirmModalVisible = false  // 確認モーダルの表示状態
    @State private var isSaveButtonEnabled = false  // 保存ボタンの活性状態
    
    // アラートの種類を識別するEnumを定義
    enum ActiveAlert: Identifiable {
        case saveSuccess, saveFailure

        // Identifiable protocol requires a 'id' property
        var id: Int {
            self.hashValue
        }
    }
    
    @State private var activeAlert: ActiveAlert?    // 現在表示するアラートの種類を保持するための状態変数
    
    // フィールドの初期化
    init(tradingHistoryModel: TradingHistoryModel) {
        self.tradingHistoryModel = tradingHistoryModel
        _selectedAction = State(initialValue: ActionType(fromString: tradingHistoryModel.selectedAction))
        _entryPrice = State(initialValue: String(tradingHistoryModel.entryPrice))
        _lossCutPrice = State(initialValue: String(tradingHistoryModel.lossCutPrice))
        _lc = State(initialValue: tradingHistoryModel.lc)
        _maxPrice = State(initialValue: String(tradingHistoryModel.maxPrice))
        _max = State(initialValue: tradingHistoryModel.max)
        _maisu = State(initialValue: tradingHistoryModel.maisu)
        _profitTakingFlag = State(initialValue: tradingHistoryModel.profitTakingFlag)
        _lossCutFlag = State(initialValue: tradingHistoryModel.lossCutFlag)
        _settlementPrice = State(initialValue: String(tradingHistoryModel.settlementPrice))
        _range = State(initialValue: tradingHistoryModel.range)
        _PL = State(initialValue: tradingHistoryModel.PL)
        _winLose = State(initialValue: WinLose(fromString: tradingHistoryModel.winLose))
        
        _maisu = State(initialValue: tradingHistoryModel.maisu)
        _memo = State(initialValue: tradingHistoryModel.memo)
        _lc = State(initialValue: tradingHistoryModel.lc)
        _max = State(initialValue: tradingHistoryModel.max)
        _range = State(initialValue: tradingHistoryModel.range)
        _PL = State(initialValue: tradingHistoryModel.PL)
        
        _startDate = State(initialValue:  tradingHistoryModel.startDate)
        _finishDate = State(initialValue: tradingHistoryModel.finishDate)
        _possessionTime = State(initialValue: tradingHistoryModel.possessionTime)
    }
    
    var body: some View {
        ScrollView {
            VStack {
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
                    
                VStack(alignment: .leading) {
                    HStack {
                        Text("エントリー：")
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
                        Text("最大：")
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
                    
                    // 枚数表示
                    Text("枚数：\(maisu)")
                        .padding(.leading)
                    // ボタン群
                    HStack {
                        Button("+1") {
                            self.maisu += 1
                        }
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(Color.gray)
                        .foregroundStyle(.white)
                        .cornerRadius(5)
                        Button("+10") {
                            self.maisu += 10
                        }
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(Color.gray)
                        .foregroundStyle(.white)
                        .cornerRadius(5)
                        Button("+100") {
                            self.maisu += 100
                        }
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(Color.gray)
                        .foregroundStyle(.white)
                        .cornerRadius(5)
                        Button("クリア") {
                            self.maisu = 0
                        }
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(Color.gray)
                        .foregroundStyle(.white)
                        .cornerRadius(5)
                    }
                    .padding(.leading)
                    
                    if tradingHistoryModel.tradeID != "5_MA" && tradingHistoryModel.tradeID != "15_MA" {
                        HStack {
                            Text("利食い")
                            Toggle(isOn: $profitTakingFlag) {
                            }
                            .toggleStyle(.checkBox)
                            .onChange(of: profitTakingFlag) { newValue in
                                    if newValue {
                                        lossCutFlag = false
                                    }
                                }

                            Text("ロスカット")
                            Toggle(isOn: $lossCutFlag) {
                            }
                            .toggleStyle(.checkBox)
                            .onChange(of: lossCutFlag) { newValue in
                                if newValue {
                                    profitTakingFlag = false
                                }
                            }
                        }
                        .padding(.leading)
                        if !profitTakingFlag && !lossCutFlag {
                            HStack {
                                Text("決済：")
                                TextField("0", text: $settlementPrice)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.numberPad)
                                    .frame(width: 100)
                                    .foregroundStyle(.black)
                            }
                            .padding(.leading)
                        }
                    }else {
                        HStack {
                            Text("ロスカット")
                            Toggle(isOn: $lossCutFlag) {
                            }
                            .toggleStyle(.checkBox)
                        }
                        .padding(.leading)
                        if !lossCutFlag {
                            HStack {
                                Text("決済：")
                                TextField("0", text: $settlementPrice)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.numberPad)
                                    .frame(width: 100)
                                    .foregroundStyle(.black)
                            }
                            .padding(.leading)
                        }
                    }
                    Text("値幅： \(range)")
                        .onChange(of: selectedAction) { _ in
                            range = Calculations.calcEditRange(entryPrice: entryPrice, settlementPrice: settlementPrice, selectedAction: selectedAction) }
                        .onChange(of: entryPrice) { _ in
                            range = Calculations.calcEditRange(entryPrice: entryPrice, settlementPrice: settlementPrice, selectedAction: selectedAction) }
                        .onChange(of: settlementPrice) { _ in
                            range = Calculations.calcEditRange(entryPrice: entryPrice, settlementPrice: settlementPrice, selectedAction: selectedAction) }
                        .padding(.leading)
                    
                    Text("損益： \(PL)")
                        .onChange(of: range) { _ in
                            PL = Calculations.calcPL(range: range, maisu: maisu)}
                        .onChange(of: maisu) { _ in
                            PL = Calculations.calcPL(range: range, maisu: maisu)}
                        .padding(.leading)
                    
                    HStack {
                        Text("エントリー時間：")
                        DatePicker(selection: $startDate, label: {Text("")})
                            .environment(\.locale, Locale(identifier: "ja_JP"))
                            .padding(.trailing, 10)
                            .padding(.vertical, 10)
                            .background(Color.gray.opacity(0.5))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Text("決済時間：　　　")
                        DatePicker(selection: $finishDate, label: {Text("")})
                            .environment(\.locale, Locale(identifier: "ja_JP"))
                            .padding(.trailing, 10)
                            .padding(.vertical, 10)
                            .background(Color.gray.opacity(0.5))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // 保有時間
                    Text("保有時間: \(possessionTime/60)時間\(possessionTime%60)分")
                        .onChange(of: startDate) { _ in
                            possessionTime = Calculations.timeDifference(start: startDate, end: finishDate)}
                        .onChange(of: finishDate) { _ in
                            possessionTime = Calculations.timeDifference(start: startDate, end: finishDate)}
                        .padding(.leading)
                    
                    
                    
                    VStack(alignment: .leading) {
                        Text("メモ:")
                        TextEditor(text: $memo)
                            .lineSpacing(3)
                            .border(Color.gray)
                            .frame(minHeight: 100)
                            .foregroundStyle(.black)
                    }
                    .padding()
                }
                .padding([.leading, .trailing, .top])
                
                HStack {
                    Button(action: {
                        // 確認モーダルを表示
                        self.isConfirmModalVisible = true
                    }) {
                        Text("確認")
                            .padding()
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .cornerRadius(10)
                    }

                    Button(action: {
                        // 保存処理を実行
                        editTradingHistory()
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
            .navigationBarTitle("取引履歴編集", displayMode: .inline)
        }
        .padding(.top)
        .background(Color.blue2)
        .foregroundStyle(.white)
        .navigationBarTitle("登録内容", displayMode: .inline)
        .sheet(isPresented: $isConfirmModalVisible) {
            // 確認用のモーダルビューを定義
            EditConfirmView(title: tradingHistoryModel.title, selectedAction: selectedAction, entryPrice: entryPrice, lossCutPrice: lossCutPrice, lc: lc, maxPrice: maxPrice, max: max, maisu: maisu, settlementPrice: settlementPrice, range: range, PL: PL, startDate: startDate, finishDate: finishDate, possessionTime: possessionTime, memo: memo, onConfirm:  {
                // 確認後の処理
                self.isSaveButtonEnabled = true
                self.isConfirmModalVisible = false
            })
        }
        .alert(item: $activeAlert) { activeAlert in
            switch activeAlert {
            case .saveSuccess:
                return Alert(
                    title: Text("保存完了"),
                    message: Text("履歴登録が完了しました"),
                    dismissButton: .default(Text("OK")) {
                        self.presentationMode.wrappedValue.dismiss() // ここでビューを閉じる
                    }
                )
            case .saveFailure:
                return Alert(
                    title: Text("保存失敗"),
                    message: Text("履歴登録に失敗しました"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    // 履歴編集APIを呼び出して、データを保存し、入力情報をクリアする
    func editTradingHistory() {
        Task {
            do {
                let id = tradingHistoryModel.id
                let userID = tradingHistoryModel.userID
                let title = tradingHistoryModel.title
                let tradeID = tradingHistoryModel.tradeID
                let selectedActionString = selectedAction.rawValue
                let entryPriceInt = Int(entryPrice) ?? 0
                let lossCutPriceInt = Int(lossCutPrice) ?? 0
                let maxPriceInt = Int(maxPrice) ?? 0
                let settlementPriceInt = Int(settlementPrice) ?? 0
                let winLoseString = winLose.rawValue

                // 非同期関数を呼び出し、完了を待つ
                try await editTradingHistoryAPI(
                    id: id, userID: userID, title: title, selectedAction: selectedActionString,
                    entryPrice: entryPriceInt, lossCutPrice: lossCutPriceInt, lc: lc, maxPrice: maxPriceInt, max: max,
                    maisu: maisu, profitTakingFlag: profitTakingFlag, lossCutFlag: lossCutFlag, settlementPrice: settlementPriceInt,
                    range: range, PL: PL, winLose: winLoseString, startDate: startDate, finishDate: finishDate,
                    possessionTime: possessionTime, memo: memo, tradeID: tradeID
                )
                
                DispatchQueue.main.async {
                    self.activeAlert = .saveSuccess // 保存成功アラートを表示
                }
            } catch {
                // 保存処理が失敗した場合
                DispatchQueue.main.async {
                    self.activeAlert = .saveFailure // 保存失敗アラートを表示
                }
            }
        }
    }
}
