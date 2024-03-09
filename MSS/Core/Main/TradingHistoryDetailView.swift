//
//  TradingHistoryDetailView.swift
//  MSS
//
//  Created by 大塚直樹 on 2024/03/09.
//

import SwiftUI

struct TradingHistoryDetailView: View {
    @State var tradingHistoryModel: TradingHistoryModel
    @Environment(\.presentationMode) var presentationMode
    
    // 表示するアラートの種類を管理する状態変数
    enum AlertType: Identifiable {
        case deleteConfirm, deleteSuccess, deleteFailure, fetchFailure

        var id: Self { self }
    }
    
    @State private var alertType: AlertType?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                DetailRow(title: "取引区分", value: tradingHistoryModel.title)
                DetailRow(title: "取引", value: tradingHistoryModel.selectedAction)
                DetailRow(title: "エントリー価格", value: "\(tradingHistoryModel.entryPrice)")
                DetailRow(title: "ロスカット価格", value: "\(tradingHistoryModel.lossCutPrice)")
                DetailRow(title: "ロスカット", value: "\(tradingHistoryModel.lc)")
                DetailRow(title: "最大", value: "\(tradingHistoryModel.maxPrice)")
                DetailRow(title: "最大値幅", value: "\(tradingHistoryModel.max)")
                DetailRow(title: "枚数", value: "\(tradingHistoryModel.maisu)")
                DetailRow(title: "決済価格", value: "\(tradingHistoryModel.settlementPrice)")
                DetailRow(title: "値幅", value: "\(tradingHistoryModel.range)")
                DetailRow(title: "損益", value: "\(tradingHistoryModel.PL)")
                DetailRow(title: "エントリー時間", value: formatDate(tradingHistoryModel.startDate))
                DetailRow(title: "決済時間", value: formatDate(tradingHistoryModel.finishDate))
                DetailRow(title: "保有時間", value: "\(tradingHistoryModel.possessionTime/60)時間\(tradingHistoryModel.possessionTime%60)分")
                // 以下、他のデータも同様に追加
                VStack(alignment: .leading) {
                    Text("メモ：")
                        .font(.title3)
                    Text(tradingHistoryModel.memo)
                        .font(.body)

                }
                .padding(.top, 5)
                
                HStack {
                    NavigationLink(destination: EditTradingHistoryView(tradingHistoryModel: tradingHistoryModel)) {
                        Text("編集")
                            .padding()
                            .background(Color.green)
                            .foregroundStyle(.white)
                            .cornerRadius(10)
                    }
                    // 削除ボタン
                    Button("削除") {
                        alertType = .deleteConfirm
                    }
                    .padding()
                    .background(Color.red)
                    .foregroundStyle(.white)
                    .cornerRadius(10)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 10)
            }
            .padding(.leading, 15)
        }
        .padding()
        .background(Color.blue2)
        .foregroundStyle(.white)
        .navigationBarTitle("取引履歴詳細", displayMode: .inline)
        .onAppear {
            // 更新されたデータを取得する処理
            fetchUpdatedData()
        }
        .navigationBarTitle("取引履歴詳細", displayMode: .inline)
        .alert(item: $alertType) { alertType in
            switch alertType {
            case .deleteConfirm:
                return Alert(
                    title: Text("削除の確認"),
                    message: Text("この履歴を削除しても大丈夫ですか？"),
                    primaryButton: .destructive(Text("削除")) {
                        Task {
                            await deleteTradingHistory()
                        }
                    },
                    secondaryButton: .cancel()
                )
            case .deleteSuccess:
                return Alert(
                    title: Text("削除完了"),
                    message: Text("取引履歴が正常に削除されました。"),
                    dismissButton: .default(Text("OK")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            case .deleteFailure:
                return Alert(
                    title: Text("削除失敗"),
                    message: Text("取引履歴の削除に失敗しました。"),
                    dismissButton: .default(Text("OK"))
                )
            case .fetchFailure:
                return Alert(
                    title: Text("エラー"),
                    message: Text("データの取得に失敗しました。"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    // 各行の表示を構造化するためのヘルパーメソッド
    private func DetailRow(title: String, value: String) -> some View {
        HStack {
            Text(title + ":")
                .frame(width: 140, alignment: .leading)
                .font(.title3)
            Text(value)
                .frame(alignment: .leading)
                .font(.title3)
            Spacer()
        }
        .padding(.top, 5)
    }
    
    // 編集完了後、編集画面から戻ってきた時に、表示するデータを取得
    func fetchUpdatedData() {
        Task {
            do {
                // オプショナルを安全にアンラップ
                if let updatedData = try await fetchEditedTradingHistoryAPI(id: tradingHistoryModel.id, tradeID: tradingHistoryModel.tradeID) {
                    // UIを更新するためにメインスレッドで実行
                    DispatchQueue.main.async {
                        self.tradingHistoryModel = updatedData
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    // アラートを表示
                    self.alertType = .fetchFailure
                }
            }
        }
    }
    
    // 履歴削除APIを呼び出して実行する。
    func deleteTradingHistory() async {
        do {
            try await deleteTradingHistoryAPI(id: tradingHistoryModel.id, tradeID: tradingHistoryModel.tradeID)
            // 削除成功
            alertType = .deleteSuccess
        } catch {
            // 削除失敗
            alertType = .deleteFailure
        }
    }
}
