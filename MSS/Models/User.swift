//
//  User.swift
//  MSS
//
//  Created by 大塚直樹 on 2024/03/09.
//

import Foundation

struct User: Identifiable, Codable {
    let id: String
    let fullname: String
    let userName: String
    let email: String
    
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullname) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        
        return ""
    }
}
