//
//  AuthViewModel.swift
//  MSS
//
//  Created by 大塚直樹 on 2024/03/09.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

// 認証用のプロトコル
protocol AuthenticationFormProtocol {
    var formIsValid: Bool { get }
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    //@Published var errorMessage: String?
    
    init() {
        self.userSession = Auth.auth().currentUser
        
        Task {
            await fetchUser()
        }
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
        } catch {
            print("DEBUG: サインインに失敗しました： \(error.localizedDescription)")
//            self.errorMessage = "サインインに失敗しました"
            self.userSession = nil
            self.currentUser = nil
        }
    }
    
    func createUser(withEmail email: String, password: String, fullname: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            let user = User(id: result.user.uid, fullname: fullname, email: email)
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            await fetchUser()
        } catch {
            print("DEBUG: ユーザーの作成に失敗しました：\(error.localizedDescription)")
//            self.errorMessage = "ユーザーの作成に失敗しました"
            self.userSession = nil
            self.currentUser = nil
        }
    }
    
    func signOut() {
        do {
            // バックエンド側でユーザーをサインアウト
            try Auth.auth().signOut()
            
            //セッション情報を空にすることで、ログイン画面に戻る
            self.userSession = nil
            self.currentUser = nil  //現在のユーザーのデータモデルを空にする
        } catch {
            print("DEBUG: サインアウトに失敗しました： \(error.localizedDescription)")
//            self.errorMessage = "サインアウトに失敗しました"
        }
            
    }
    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return }
        self.currentUser = try? snapshot.data(as: User.self)
    }
}
