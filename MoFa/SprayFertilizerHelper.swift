//
//  SprayFertilizerHelper.swift
//  MoFa
//
//  Created by Arnold Schmid on 09.09.15.
//  Copyright (c) 2015 Arnold Schmid. All rights reserved.
//

import Foundation
import SQLite
class SprayFertilizerHelper{
    static let db = DaoSqlLite.sharedInstance.dbConn
    
   
    static let TABLE_NAME = "sprayfertilizer"
    static let db_id = Expression<Int>("id")
    static let db_spray_id = Expression<Int>("spray_id")
    static let db_fert_id = Expression<Int>("fert_id")
    static let db_dose = Expression<Double>("dose")
    static let db_dose_amount = Expression<Double>("dose_amount")
    static let table = Table(TABLE_NAME)
    
    typealias T = SprayFertilizer
    static func insert(_ item: T) -> Int {
        do {
            let rowId = try db.run (table.insert(or:.replace, db_spray_id <- item.spray_id, db_fert_id <- item.prod_id, db_dose <- item.dose, db_dose_amount <- item.doseAmount))
            return Int(rowId)
            
        }catch {
            return -1
        }
        
    }
    static func update (_ item: T) -> Void {
        let query = table.filter(db_spray_id == item.spray_id && db_fert_id == item.prod_id)
        _ = try! db.run (query.update(db_spray_id <- item.spray_id, db_fert_id <- item.prod_id, db_dose <- item.dose, db_dose_amount <- item.doseAmount))
        
    }
    static func insertFertArray (_ items : [T], sprayId: Int) {
        for item in items {
            if exists(sprayId, fertId: item.prod_id) {
                
                update(item)
            }else{
                item.spray_id = sprayId
                _ = insert(item)
            }
        }
    }
    static func exists (_ sprayId: Int, fertId: Int) -> Bool {
        let query = table.filter (db_spray_id == sprayId && db_fert_id == fertId)
        if try! db.scalar(query.count) > 0 {
            return true
        }
        return false
    }
    static func exists (_ item: T) -> Bool {
        let query = table.filter (db_spray_id == item.spray_id && db_fert_id == item.prod_id)
        if try! db.scalar(query.count) > 0 {
            return true
        }
        return false
    }
    
    static func findFertForSpray(_ sprayId: Int) -> [T]? {
        let query = table.filter(db_spray_id == sprayId)
        var retArray = [T]()
        for item in try! db.prepare(query) {
            retArray.append(SprayFertilizer(id: item[db_id], sprayId: item[db_spray_id], fertId: item[db_fert_id], dose: item[db_dose], doseAmount: item[db_dose_amount]))
        }
        return retArray
    }
    static func findFertIdsForSpray(_ sprayId: Int) -> [Int]? {
        let query = table.filter(db_spray_id == sprayId)
        var retArray = [Int]()
        for item in try! db.prepare(query) {
            retArray.append(item[db_fert_id])
        }
        return retArray
    }
    
    static func findFertIdsAndSprayId(_ fertId: Int, sprayId: Int) -> [T]? {  //used to search the fertilizer for spraying in search controller
        let query = table.filter(db_fert_id == fertId && db_spray_id == sprayId)
        var retArray = [T]()
        for item in try! db.prepare(query) {
            retArray.append(SprayFertilizer(id: item[db_id], sprayId: item[db_spray_id], fertId: item[db_fert_id], dose: item[db_dose], doseAmount: item[db_dose_amount]))
        }
        return retArray
    }
    
    static func delete (_ item: T) -> Void {
        let query = table.filter(db_id == item.id)
        _ = try! db.run(query.delete())
        
    }
    static func delete (_ itemId: Int) -> Void {
        let query = table.filter(db_id == itemId)
        _ = try! db.run(query.delete())
        
    }

    static func delete (_ sprayId: Int, fertToDelIds: Set<Int>) {
        for wid in fertToDelIds {
            let query = table.filter(db_spray_id == sprayId && db_fert_id == wid)
            _ = try! db.run (query.delete())
        }
        
    }
    static func deleteFertilizersForSpray (_ sprayId: Int) {
        let fertilizersForSpray = table.filter(db_spray_id == sprayId)
        _ = try! db.run(fertilizersForSpray.delete())
    }
}
