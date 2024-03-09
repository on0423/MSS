//
//  RecordArea5minutesView.swift
//  MSS
//
//  Created by 大塚直樹 on 2024/03/09.
//

import SwiftUI

struct RecordArea5minutes: View {
    var tradeID: String
    var title: String
    @Binding var entryPrice: String
    @Binding var lossCutPrice: String
    @Binding var lc: Int
    @Binding var maxPrice: String
    @Binding var max: Int
    @State var tradeFlag = false        //取引の有無
    @State var diffEntryFlag = false    //エントリーポイントが違う場合
    @State var diffEntryPrice: String // エントリーポイントが違う場合の入ったポイント
    @State var profitTakingFlag = false // 利食い判定
    @State var lossCutFlag = false        // ロスカット判定
    @State var settlementPrice: String
    @State private var maisu = 0
    @State private var finishDate = Date()          // 決済時間
    @Binding var startDate: Date                // エントリー時間
    @State private var range = 0       // 値幅
    @State private var PL = 0     // 損益
    @Binding var selectedAction: ActionType
    @State private var winLose: WinLose = .win        // 勝敗
    @State private var possessionTime = 0      // 保有時間(/分)
    
    @State var confirmFlag = false           // 内容確認フラグ(チェックが入ったタイミングで)
    var onSave: (RegisterAreaData) -> Void   // コールバック関数
    var onDelete: (String) -> Void // tradeIDを引数にとる削除用のコールバック関数
    
    @Binding var resetTrigger: Bool // 保存完了時の入力内容クリアに使用する
    
    var body: some View {
        VStack(alignment: .leading) {
            Toggle(isOn: $tradeFlag) {
                Text(title)
                    .font(.title2)
            }
            .onChange(of: tradeFlag) { newValue in
                confirmFlag = false
                if !newValue {
                    // tradeFlagがfalseになったら、対応するデータを削除するように親ビューに指示する
                    onDelete(tradeID)
                }
            }
            
            // 選んだ結果でエリアを表示・非表示
            if tradeFlag {
                VStack(alignment: .leading) {
                    // エントリーポイントが異なる場合、入ったポイントを入力
                    HStack {
                        Text("有利なポイント")
                        Toggle(isOn: $diffEntryFlag) {
                        }
                        .padding(.trailing, 180)
                        .toggleStyle(.checkBox)
                        .onChange(of: diffEntryFlag) { _ in confirmFlag = false }
                    }
                    if diffEntryFlag{
                        HStack {
                            Text("エントリー：")
                            TextField("0", text: $diffEntryPrice)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                                .frame(width: 100)
                                .foregroundStyle(.black)
                                .onChange(of: diffEntryPrice) { _ in confirmFlag = false }
                        }
                    }else{
                    }
                    
                    // 枚数表示
                    Text("枚数：\(maisu)")
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
                        .onChange(of: maisu) { _ in confirmFlag = false }
                        Button("+10") {
                            self.maisu += 10
                        }
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(Color.gray)
                        .foregroundStyle(.white)
                        .cornerRadius(5)
                        .onChange(of: maisu) { _ in confirmFlag = false }
                        Button("+100") {
                            self.maisu += 100
                        }
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(Color.gray)
                        .foregroundStyle(.white)
                        .cornerRadius(5)
                        .onChange(of: maisu) { _ in confirmFlag = false }
                        Button("クリア") {
                            self.maisu = 0
                        }
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(Color.gray)
                        .foregroundStyle(.white)
                        .cornerRadius(5)
                        .onChange(of: maisu) { _ in confirmFlag = false }
                    }
                }
                
                if tradeID != "5_MA" && tradeID != "15_MA" {
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
                        .onChange(of: profitTakingFlag) { _ in confirmFlag = false }

                        Text("ロスカット")
                        Toggle(isOn: $lossCutFlag) {
                        }
                        .toggleStyle(.checkBox)
                        .onChange(of: lossCutFlag) { newValue in
                                if newValue {
                                    profitTakingFlag = false
                                }
                            }
                        .onChange(of: lossCutFlag) { _ in confirmFlag = false }
                    }
                    if !profitTakingFlag && !lossCutFlag {
                        HStack {
                            Text("決済：")
                            TextField("0", text: $settlementPrice)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                                .frame(width: 100)
                                .foregroundStyle(.black)
                                .onChange(of: settlementPrice) { _ in confirmFlag = false }
                        }
                    }else{
                    }
                }else {
                    HStack {
                        Text("ロスカット")
                        Toggle(isOn: $lossCutFlag) {
                        }
                        .toggleStyle(.checkBox)
                        .onChange(of: lossCutFlag) { _ in confirmFlag = false }
                    }
                    if !lossCutFlag {
                        HStack {
                            Text("決済：")
                            TextField("0", text: $settlementPrice)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                                .frame(width: 100)
                                .foregroundStyle(.black)
                                .onChange(of: settlementPrice) { _ in confirmFlag = false }
                        }
                    }
                }
                
                // 決済時間の入力
                HStack {
                    Text("決済時間：")
                    DatePicker(selection: $finishDate, label: {Text("")})
                        .environment(\.locale, Locale(identifier: "ja_JP"))
                        .padding(.trailing, 25)
                        .padding(.vertical, 10)
                        .background(Color.gray.opacity(0.5))
                        .cornerRadius(10)
                        .onChange(of: finishDate) { _ in confirmFlag = false }
                }
                
                // 保有時間
                Text("保有時間: \(possessionTime/60)時間\(possessionTime%60)分")
                    .onChange(of: startDate) { _ in
                        possessionTime = Calculations.timeDifference(start: startDate, end: finishDate)}
                    .onChange(of: finishDate) { _ in
                        possessionTime = Calculations.timeDifference(start: startDate, end: finishDate)}
                
                
                
                // 値幅
                // 損益の計算結果エリア
                Text("値幅： \(range)")
                    .onChange(of: selectedAction) { _ in
                        range = Calculations.callCalcRange(tradeID: tradeID, entryPrice: entryPrice, settlementPrice: settlementPrice, lossCutPrice: lossCutPrice, lc: lc, diffEntryPrice: diffEntryPrice, diffEntryFlag: diffEntryFlag, profitTakingFlag: profitTakingFlag, lossCutFlag: lossCutFlag, selectedAction: selectedAction) }
                    .onChange(of: entryPrice) { _ in
                        range = Calculations.callCalcRange(tradeID: tradeID, entryPrice: entryPrice, settlementPrice: settlementPrice, lossCutPrice: lossCutPrice, lc: lc, diffEntryPrice: diffEntryPrice, diffEntryFlag: diffEntryFlag, profitTakingFlag: profitTakingFlag, lossCutFlag: lossCutFlag, selectedAction: selectedAction) }
                    .onChange(of: lossCutPrice) { _ in
                        range = Calculations.callCalcRange(tradeID: tradeID, entryPrice: entryPrice, settlementPrice: settlementPrice, lossCutPrice: lossCutPrice, lc: lc, diffEntryPrice: diffEntryPrice, diffEntryFlag: diffEntryFlag, profitTakingFlag: profitTakingFlag, lossCutFlag: lossCutFlag, selectedAction: selectedAction) }
                    .onChange(of: settlementPrice) { _ in
                        range = Calculations.callCalcRange(tradeID: tradeID, entryPrice: entryPrice, settlementPrice: settlementPrice, lossCutPrice: lossCutPrice, lc: lc, diffEntryPrice: diffEntryPrice, diffEntryFlag: diffEntryFlag, profitTakingFlag: profitTakingFlag, lossCutFlag: lossCutFlag, selectedAction: selectedAction) }
                    .onChange(of: profitTakingFlag) { _ in
                        range = Calculations.callCalcRange(tradeID: tradeID, entryPrice: entryPrice, settlementPrice: settlementPrice, lossCutPrice: lossCutPrice, lc: lc, diffEntryPrice: diffEntryPrice, diffEntryFlag: diffEntryFlag, profitTakingFlag: profitTakingFlag, lossCutFlag: lossCutFlag, selectedAction: selectedAction) }
                    .onChange(of: diffEntryFlag) { _ in
                        range = Calculations.callCalcRange(tradeID: tradeID, entryPrice: entryPrice, settlementPrice: settlementPrice, lossCutPrice: lossCutPrice, lc: lc, diffEntryPrice: diffEntryPrice, diffEntryFlag: diffEntryFlag, profitTakingFlag: profitTakingFlag, lossCutFlag: lossCutFlag, selectedAction: selectedAction) }
                    .onChange(of: diffEntryPrice) { _ in
                        range = Calculations.callCalcRange(tradeID: tradeID, entryPrice: entryPrice, settlementPrice: settlementPrice, lossCutPrice: lossCutPrice, lc: lc, diffEntryPrice: diffEntryPrice, diffEntryFlag: diffEntryFlag, profitTakingFlag: profitTakingFlag, lossCutFlag: lossCutFlag, selectedAction: selectedAction) }
                    .onChange(of: lossCutFlag) { _ in
                        range = Calculations.callCalcRange(tradeID: tradeID, entryPrice: entryPrice, settlementPrice: settlementPrice, lossCutPrice: lossCutPrice, lc: lc, diffEntryPrice: diffEntryPrice, diffEntryFlag: diffEntryFlag, profitTakingFlag: profitTakingFlag, lossCutFlag: lossCutFlag, selectedAction: selectedAction) }

                Text("損益： \(PL)")
                    .onChange(of: range) { _ in
                        PL = Calculations.calcPL(range: range, maisu: maisu)}
                    .onChange(of: maisu) { _ in
                        PL = Calculations.calcPL(range: range, maisu: maisu)}
                    
                // 損益(PL)から勝敗を判定
                .onChange(of: PL) { _ in
                    winLose = Judgement.judgementWinLose(PL: PL)}
                
                // 内容確認のチェックボックス
                Toggle(isOn: $confirmFlag) {
                    Text("内容確認")
                }
                // onChange内で関数を呼び出す
                .onChange(of: confirmFlag) { newValue in
                    handleConfirmFlagChange(isConfirmed: newValue)
                }
            }
                
        }
        .padding()
        .border(Color.gray, width: 1)
        .onChange(of: resetTrigger) { newValue in
            if newValue {
                resetStates()
                // リセットトリガーを元に戻す（オプション）
                resetTrigger = false
            }
        }
    }
    // データを配列に入れる関数を定義
    private func handleConfirmFlagChange(isConfirmed newValue: Bool) {
        if newValue {
            // 型変換
            let diffEntryPriceInt = Int(diffEntryPrice) ?? 0
            let winLoseString = winLoseToString(winLose)
            let acturlSettlementPrice = Calculations.callCalcSettlementPrice(tradeID: tradeID, entryPrice: entryPrice, settlementPrice: settlementPrice, lc: lc, profitTakingFlag: profitTakingFlag, lossCutFlag: lossCutFlag, selectedAction: selectedAction)

            // RegisterAreaData インスタンスを作成
            let newData = RegisterAreaData(
                tradeFlag: tradeFlag,
                tradeID: tradeID,
                title: title,
                diffEntryFlag: diffEntryFlag,
                diffEntryPrice: diffEntryPriceInt,
                maisu: maisu,
                profitTakingFlag: profitTakingFlag,
                lossCutFlag: lossCutFlag,
                settlementPrice: acturlSettlementPrice,
                range: range,
                PL: PL,
                winLose: winLoseString,
                finishDate: finishDate,
                possessionTime: possessionTime,
                confirmFlag: confirmFlag
            )

            // コールバック関数を呼び出す
            onSave(newData)
        }
    }
    
    // ビューの内部状態をリセットする関数
    private func resetStates() {
        tradeFlag = false
        diffEntryFlag = false
        diffEntryPrice = ""
        profitTakingFlag = false
        lossCutFlag = false
        settlementPrice = ""
        maisu = 0
        finishDate = Date()
        range = 0
        PL = 0
        winLose = .win
        possessionTime = 0
    }
}
