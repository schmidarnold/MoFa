//
//  WorkFertilizerDataHelper.swift
//  MoFa
//
//  Created by Arnold Schmid on 20.11.15.
//  Copyright © 2015 Arnold Schmid. All rights reserved.
//

import Foundation
import SQLite
class WorkFertilizerDataHelper {
    static let db = DaoSqlLite.sharedInstance.dbConn
    static let TABLE_NAME = "workfertilizer"
    static let db_id = Expression<Int>("id")
    static let db_work_id = Expression<Int>("work_id")
    static let db_soilfertilizer_id = Expression<Int>("soilfertilizer_id")
    static let db_amount = Expression<Double>("amount")
    static let table = Table(TABLE_NAME)
    
    typealias T = WorkFertilizer
    static func insert(_ item: T) -> Int {
        do {
            let rowId = try db.run (table.insert(db_work_id <- item.workId, db_soilfertilizer_id <- item.soilFertId, db_amount <- item.amount))
            return Int(rowId)
        }catch{
            return -1
        }
    }
    static func update (_ item: T) -> Void {
        if let id = item.id {
            let query = table.filter(db_id == id)
            try! _ = db.run (query.update(db_work_id <- item.workId, db_soilfertilizer_id <- item.soilFertId, db_amount <- item.amount))
        }
    }
    static func findFertilizerForWorkId(_ workId: Int) -> [T]? {
        let query = table.filter(db_work_id == workId)
        var retArray = [T]()
        for item in try! db.prepare(query) {
            retArray.append(WorkFertilizer(id: item[db_id], workId: item[db_work_id], soilFertId: item[db_soilfertilizer_id], amount: item[db_amount]))
        }
        return retArray
    }
    static func getFertForWork(_ workId: Int, prodId: Int) -> T? {
        let query = table.filter (db_work_id == workId && db_soilfertilizer_id == prodId)
        var results: T?
        if let item = try! db.pluck (query) {
            results = WorkFertilizer(id:item[db_id], workId: item[db_work_id], soilFertId: item[db_soilfertilizer_id], amount: item[db_amount] )
        }
        return results
    }
    static func delete (_ item: T) -> Void {
        if let id = item.id {
            let query = table.filter(db_id == id)
            try! _ = db.run(query.delete())
        }
    }
    static func deleteSoilFertForWorkId(_ workId: Int) -> Void {
        
        let query = table.filter(db_work_id == workId)
        try! _ = db.run(query.delete())
        
    }
    static func exists (_ workId: Int) -> Bool {
        let query = table.filter (db_work_id == workId)
        if try! db.scalar(query.count) > 0 {
            return true
        }
        return false
    }
    static func existsFertInWork (_ workId: Int, prodId:Int) -> Bool {
        let query = table.filter (db_work_id == workId && db_soilfertilizer_id == prodId)
        if try! db.scalar(query.count) > 0 {
            return true
        }
        return false
    }
    
    
    static func insertSoilFertArray (_ items : [T], currWorkId : Int) {
        for item in items {
            if existsFertInWork(currWorkId, prodId: item.soilFertId) {
                item.workId = currWorkId
                update(item)
            }else{
                item.workId = currWorkId
                _ = insert(item)
            }
        }
    }
}
