//
//  PurchasePestDataHelper.swift
//  MoFa
//
//  Created by Arnold Schmid on 13.12.15.
//  Copyright © 2015 Arnold Schmid. All rights reserved.
//

import Foundation
import SQLite
class PurchasePestDataHelper{
    static let db = DaoSqlLite.sharedInstance.dbConn
    static let TABLE_NAME = "purchasepesticide"
    static let db_id = Expression<Int>("id")
    static let db_purchase_id = Expression<Int>("purchase_id")
    static let db_amount = Expression<Double>("amount")
    static let db_pest_id = Expression<Int>("pest_id")
    static let table = Table(TABLE_NAME)
    
    typealias T = PurchasePesticide
    static func insert(_ item: T) -> Int {
        do {
            let rowId = try db.run (table.insert(or:.replace, db_purchase_id <- item.purchase_id, db_pest_id <- item.pest_id, db_amount <- item.amount))
            return Int(rowId)
            
        }catch {
            return -1
        }
    }
    static func update (_ item: T) -> Void {
        let query = table.filter(db_purchase_id == item.purchase_id && db_pest_id == item.pest_id)
        try! _ = db.run (query.update(db_purchase_id <- item.purchase_id, db_pest_id <- item.pest_id, db_amount <- item.amount))
        
    }
    
    static func exists (_ purchaseId: Int, pestId: Int) -> Bool {
        let query = table.filter (db_purchase_id == purchaseId && db_pest_id == pestId)
        if try! db.scalar(query.count) > 0 {
            return true
        }
        return false
    }
    static func exists (_ item: T) -> Bool {
        let query = table.filter (db_purchase_id == item.purchase_id && db_pest_id == item.pest_id)
        if try! db.scalar(query.count) > 0 {
            return true
        }
        return false
    }
    
    static func findPestForPurchase(_ purchaseId: Int) -> [T]? {
        let query = table.filter(db_purchase_id == purchaseId)
        var retArray = [T]()
        for item in try! db.prepare(query) {
            retArray.append(PurchasePesticide(id: item[db_id], purchaseId: item[db_purchase_id], pestId: item[db_pest_id], amount: item[db_amount]))
        }
        return retArray
    }
    static func findAll() -> [T]? {
        var retArray = [T]()
        for item in try! db.prepare(table) {
            retArray.append(PurchasePesticide(id: item[db_id], purchaseId: item[db_purchase_id], pestId: item[db_pest_id], amount: item[db_amount]))
        }
        return retArray
    }
    
    static func delete (_ item: T) -> Void {
        let query = table.filter(db_id == item.id)
        try! _ = db.run (query.delete())
        
    }
    static func delete (_ itemId: Int) -> Void {
        let query = table.filter(db_id == itemId)
        try! _ = db.run (query.delete())
        
    }
    
    static func deletePesticidesForPurchase (_ purchaseId: Int) {
        let pesticidesForPurchase = table.filter(db_purchase_id == purchaseId)
        try! _ = db.run (pesticidesForPurchase.delete())
    }
    

}
