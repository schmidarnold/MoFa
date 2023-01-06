//
//  Wirkung.swift
//  MoFa
//
//  Created by Arnold Schmid on 23.01.18.
//  Copyright © 2018 Arnold Schmid. All rights reserved.
//

import Foundation

struct PestRestrictions : Codable {
    let wirkungen: [Wirkung]
    let warteFristen: [WarteFrist]
}

struct Wirkung: Codable {
    let maxDose : Double?
    let minDose : Double?
    let maxUseProYear : Int?
    let maxAmountProUse: Double?
    let reason : String
    let period: String
    let cultur: String
    let periodCode: String
    static func == (lhs: Wirkung, rhs: Wirkung) -> Bool {
        return (lhs.reason == rhs.reason && lhs.periodCode == rhs.periodCode)
    }
    
}
struct WarteFrist: Codable{
    let waitTime : String
    let cultur: String
    let prodType: String
    let beeRestriction: Int
    let status: String?
    
}

extension Wirkung: CustomStringConvertible {
    var description: String {
        return "\(reason), \(cultur)"
    }
}
