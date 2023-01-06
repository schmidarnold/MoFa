//
//  HarvestDataHelper.swift
//  MoFa
//
//  Created by Arnold Schmid on 21.10.15.
//  Copyright © 2015 Arnold Schmid. All rights reserved.
//

import Foundation
import SQLite
class HarvestDataHelper {
    static let db = DaoSqlLite.sharedInstance.dbConn
    static let TABLE_NAME = "harvest"
    
    static let db_id = Expression<Int>("id")
    static let db_work_id = Expression<Int>("work_id")
    static let db_category_id = Expression<Int>("fruitQuality_id")
    static let db_date = Expression<Int>("date")
    static let db_amount = Expression<Int>("amount")
    static let db_boxes = Expression<Int?>("boxes")
    static let db_note = Expression<String?>("note")
    static let db_pass = Expression<Int>("pass")
    static let db_sugar = Expression<Double?>("sugar")
    static let db_acid = Expression<Double?>("acid")
    static let db_ph = Expression<Double?>("phValue")
    static let db_phenol = Expression<Double?>("phenol")
    
    static let table = Table(TABLE_NAME)
    
    typealias T = Harvest
    
    static func insert(_ item: T) -> Int {
        do {
            let rowId =  try db.run(table.insert(db_id <- item.id!, db_work_id <- item.workId!, db_category_id <- item.categoryId!, db_date <- item.date!, db_amount <- item.amount!, db_boxes <- item.boxes, db_note <- item.note, db_pass <- item.turn, db_sugar <- item.sugar, db_acid <- item.acid, db_ph <- item.ph, db_phenol <- item.phenol))
            return Int(rowId)
        }catch {
            return -1
        }
    }
    static func delete (_ item: T) -> Void {
        if let id = item.id {
            let query = table.filter(db_id == id)
            try! _ = db.run(query.delete())
        }
    }
    static func update (_ item: T) -> Void {
        if let id = item.id {
            let query = table.filter(db_id == id)
            _ = try! db.run (query.update(db_id <- item.id!, db_work_id <- item.workId!, db_category_id <- item.categoryId!, db_date <- item.date!, db_amount <- item.amount!, db_boxes <- item.boxes, db_note <- item.note, db_pass <- item.turn, db_sugar <- item.sugar, db_acid <- item.acid, db_ph <- item.ph, db_phenol <- item.phenol))
        }
    }
    static func find(_ id: Int) -> T? {
        let query = table.filter(db_id == id)
        var results: T?
        if let item = try! db.pluck(query) {
            results = Harvest(id: item[db_id], workId: item[db_work_id], categoryId: item[db_category_id], note: item[db_note], amount: item[db_amount], turn: item[db_pass], date: item[db_date], boxes: item[db_boxes], acid: item[db_acid], sugar: item[db_sugar], ph: item[db_ph], phenol: item[db_phenol])
        }
        return results
    }
    static func findWorkId(_ workId: Int) -> [T]? {
        let query = table.filter(db_work_id == workId)
        var retArray = [T]()
        for item in try! db.prepare(query) {
            retArray.append(Harvest(id: item[db_id], workId: item[db_work_id], categoryId: item[db_category_id], note: item[db_note], amount: item[db_amount], turn: item[db_pass], date: item[db_date], boxes: item[db_boxes], acid: item[db_acid], sugar: item[db_sugar], ph: item[db_ph], phenol: item[db_phenol]))
        }
        return retArray
    }
    static func deleteHarvestForWorkId(_ workId: Int) -> Void {
        
            let query = table.filter(db_work_id == workId)
            _ = try! db.run(query.delete())
        
    }
    static func findWorkIdOrdered(_ workId: Int) -> [T]? {
        let query = table.filter(db_work_id == workId).order(db_id.desc)
        var retArray = [T]()
        for item in try! db.prepare(query) {
            retArray.append(Harvest(id: item[db_id], workId: item[db_work_id], categoryId: item[db_category_id], note: item[db_note], amount: item[db_amount], turn: item[db_pass], date: item[db_date], boxes: item[db_boxes], acid: item[db_acid], sugar: item[db_sugar], ph: item[db_ph], phenol: item[db_phenol]))
        }
        return retArray
    }
    static func exists (_ workId: Int) -> Bool {
        let query = table.filter (db_work_id == workId)
        if try! db.scalar(query.count) > 0 {
            return true
        }
        return false
    }
    static func existingHarvest(_ id: Int) -> Bool {
        let query = table.filter(db_id==id)
        if try! db.scalar(query.count)>0 {
            return true
        }
        return false
    }
    
    static func insertHarvestArray (_ items : [T], currWorkId : Int) {
        for item in items {
            if existingHarvest(item.id!) {
                 item.workId = currWorkId
                 update(item)
            }else{
                item.workId = currWorkId
                _ = insert(item)
            }
        }
    }
}
