//
//  PurchaseDataHelper.swift
//  MoFa
//
//  Created by Arnold Schmid on 13.12.15.
//  Copyright © 2015 Arnold Schmid. All rights reserved.
//

import Foundation
import SQLite
class PurchaseDataHelper {
    static let db = DaoSqlLite.sharedInstance.dbConn
    static let TABLE_NAME = "purchase"
    static let db_id = Expression<Int>("id")
    static let db_date = Expression<Int>("date")
    
    static let table = Table(TABLE_NAME)
    
    typealias T = Purchase
    static func insert(_ item: T) -> Int {
        do {
            let rowId = try db.run (table.insert(or:.replace, db_date <- item.date))
            return Int(rowId)
        }catch {
            return -1
        }
        
    }
    static func insert(_ date: Int) -> Int {
        do {
            let rowId = try db.run (table.insert(or:.replace, db_date <- date))
            return Int(rowId)
        }catch {
            return -1
        }
        
    }
    static func exists (_ id: Int) -> Bool {
        let query = table.filter (db_id == id)
        if try! db.scalar(query.count) > 0 {
            return true
        }
        return false
    }
    static func exists (_ item: T) -> Bool {
        let query = table.filter (db_id == item.id)
        if try! db.scalar(query.count) > 0 {
            return true
        }
        return false
    }
    static func findAll() -> [T]? {
        var retArray = [T]()
        for item in try! db.prepare(table) {
            retArray.append(Purchase(id:item[db_id],date: item[db_date] ))
        }
        return retArray
    }
    
    //need to adapt to delete all related pest and fert
    static func delete (_ item: T) -> Void {
       let query = table.filter(db_id == item.id)
        try! _ = db.run (query.delete())
     
    }
    static func deleteAllWithRefs() {
        
        for item in try! db.prepare(table) {
            deletePurWithRefs(Purchase(id:item[db_id],date: item[db_date]))
        }
        
    }
    
    static func deletePurWithRefs (_ item: T) {
        do {
            try db.transaction {
                PurchasePestDataHelper.deletePesticidesForPurchase(item.id)
                PurchaseFertDataHelper.deleteFertilizersForPurchase(item.id)
                delete(item)
            }
        }catch _ {
            print ("error in deleting data")
        }
    }
    

}
