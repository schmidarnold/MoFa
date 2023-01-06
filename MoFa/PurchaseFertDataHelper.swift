//
//  PurchaseFertDataHelper.swift
//  MoFa
//
//  Created by Arnold Schmid on 17.12.15.
//  Copyright © 2015 Arnold Schmid. All rights reserved.
//

import Foundation
import SQLite
class PurchaseFertDataHelper{
    static let db = DaoSqlLite.sharedInstance.dbConn
    static let TABLE_NAME = "purchasefertilizer"
    static let db_id = Expression<Int>("id")
    static let db_purchase_id = Expression<Int>("purchase_id")
    static let db_amount = Expression<Double>("amount")
    static let db_fert_id = Expression<Int>("fert_id")
    static let table = Table(TABLE_NAME)
    
    typealias T = PurchaseFertilizer
    static func insert(_ item: T) -> Int {
        do {
            let rowId = try db.run (table.insert(or:.replace, db_purchase_id <- item.purchase_id, db_fert_id <- item.fert_id, db_amount <- item.amount))
            return Int(rowId)
            
        }catch {
            return -1
        }
    }
    static func update (_ item: T) -> Void {
        let query = table.filter(db_purchase_id == item.purchase_id && db_fert_id == item.fert_id)
        try! _ = db.run (query.update(db_purchase_id <- item.purchase_id, db_fert_id <- item.fert_id, db_amount <- item.amount))
        
    }
    
    static func exists (_ purchaseId: Int, fertId: Int) -> Bool {
        let query = table.filter (db_purchase_id == purchaseId && db_fert_id == fertId)
        if try! db.scalar(query.count) > 0 {
            return true
        }
        return false
    }
    static func exists (_ item: T) -> Bool {
        let query = table.filter (db_purchase_id == item.purchase_id && db_fert_id == item.fert_id)
        if try! db.scalar(query.count) > 0 {
            return true
        }
        return false
    }
    
    static func findPestForPurchase(_ purchaseId: Int) -> [T]? {
        let query = table.filter(db_purchase_id == purchaseId)
        var retArray = [T]()
        for item in try! db.prepare(query) {
            retArray.append(PurchaseFertilizer(id: item[db_id], purchaseId: item[db_purchase_id], fertId: item[db_fert_id], amount: item[db_amount]))
        }
        return retArray
    }
    static func findAll() -> [T]? {
        var retArray = [T]()
        for item in try! db.prepare(table) {
            retArray.append(PurchaseFertilizer(id: item[db_id], purchaseId: item[db_purchase_id], fertId: item[db_fert_id], amount: item[db_amount]))
        }
        return retArray
    }
    static func delete (_ item: T) -> Void {
        let query = table.filter(db_id == item.id)
        _ = try! db.run (query.delete())
        
    }
    static func delete (_ itemId: Int) -> Void {
        let query = table.filter(db_id == itemId)
        _ = try! db.run (query.delete())
        
    }
    
    static func deleteFertilizersForPurchase (_ purchaseId: Int) {
        let fertilizersForPurchase = table.filter(db_purchase_id == purchaseId)
        _ = try! db.run (fertilizersForPurchase.delete())
    }
    
    
}
