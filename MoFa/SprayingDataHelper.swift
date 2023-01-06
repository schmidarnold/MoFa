//
//  SprayingDataHelper.swift
//  MoFa
//
//  Created by Arnold Schmid on 13.08.15.
//  Copyright (c) 2015 Arnold Schmid. All rights reserved.
//

import Foundation
import SQLite
class SprayingDataHelper{
    static let db = DaoSqlLite.sharedInstance.dbConn
    static let TABLE_NAME = "spraying"
    static let db_id = Expression<Int>("id")
    static let db_work_id = Expression<Int>("work_id")
    static let db_wateramount = Expression<Double>("wateramount")
    static let db_concentration = Expression<Double>("concentration")
    static let db_weather = Expression<Int>("weather")
    static let table = Table(TABLE_NAME)
    
    typealias T = Spraying
    static func insert(_ item: T) -> Int {
        do {
            let rowId = try db.run (table.insert(or:.replace, db_work_id <- item.work_id, db_wateramount <- item.wateramount!, db_concentration <- item.concentration, db_weather <- item.weather))
            return Int(rowId)
        }catch {
            return -1
        }
        
    }
    static func update (_ item: T) -> Void {
        let query = table.filter(db_work_id == item.work_id)
        try! _ = db.run (query.update(db_work_id <- item.work_id, db_wateramount <- item.wateramount!, db_concentration <- item.concentration, db_weather <- item.weather))
        
    }
    static func exists (_ workId: Int) -> Bool {
        let query = table.filter (db_work_id == workId)
        if try! db.scalar(query.count) > 0 {
            return true
        }
        return false
    }
    static func exists (_ item: T) -> Bool {
        let query = table.filter (db_work_id == item.work_id)
        if try! db.scalar(query.count) > 0 {
            return true
        }
        return false
    }
    
    static func findSprayingForWork(_ workId: Int) -> T? {
        let query = table.filter(db_work_id == workId)
        var results: T?
        if let item = try! db.pluck(query) {
            results = Spraying(id:item[db_id], workid: item[db_work_id], wateramount: item[db_wateramount], concentration: item[db_concentration], weather: item[db_weather] )
        }
        return results
    }
    
    
    static func delete (_ item: T) -> Void {
        let query = table.filter(db_id == item.id)
        try! _ = db.run (query.delete())
        
    }
    static func deleteSprayingForWork (_ workid: Int) {
        let sprayingForWork = table.filter(db_work_id == workid)
        try! _ = db.run (sprayingForWork.delete())
    }
    
    
}
