//
//  SprayPesticideHelper.swift
//  MoFa
//
//  Created by Arnold Schmid on 05.09.15.
//  Copyright (c) 2015 Arnold Schmid. All rights reserved.
//

import Foundation
import SQLite
class SprayPesticideHelper {
    static let db = DaoSqlLite.sharedInstance.dbConn
    static let TABLE_NAME = "spraypesticide"
    static let db_id = Expression<Int>("id")
    static let db_spray_id = Expression<Int>("spray_id")
    static let db_pest_id = Expression<Int>("pest_id")
    static let db_dose = Expression<Double>("dose")
    static let db_dose_amount = Expression<Double>("dose_amount")
    static let db_reason = Expression<String?>("reason")
    static let db_periodCode = Expression<String?>("periodCode")
    static let table = Table(TABLE_NAME)
    
    typealias T = SprayPesticide
    static func insert(_ item: T) -> Int {
        do {
            let rowId = try db.run (table.insert(or:.replace, db_spray_id <- item.spray_id, db_pest_id <- item.prod_id, db_dose <- item.dose, db_dose_amount <- item.doseAmount, db_reason <- item.reason, db_periodCode <- item.periodCode))
            return Int(rowId)
            
        }catch {
            return -1
        }
    }
    static func update (_ item: T) -> Void {
        let query = table.filter(db_spray_id == item.spray_id && db_pest_id == item.prod_id)
        try! _ = db.run (query.update(db_spray_id <- item.spray_id, db_pest_id <- item.prod_id, db_dose <- item.dose, db_dose_amount <- item.doseAmount,db_reason <- item.reason, db_periodCode <- item.periodCode))
        
    }
    static func insertPestArray (_ items : [T], sprayId: Int) {
        for item in items {
            if exists(sprayId, pestId: item.prod_id) {
                
                update(item)
            }else{
                item.spray_id = sprayId
                _ = insert(item)
            }
        }
    }
    static func exists (_ sprayId: Int, pestId: Int) -> Bool {
        let query = table.filter (db_spray_id == sprayId && db_pest_id == pestId)
        if try! db.scalar(query.count) > 0 {
            return true
        }
        return false
    }
    static func exists (_ item: T) -> Bool {
        let query = table.filter (db_spray_id == item.spray_id && db_pest_id == item.prod_id)
        if try! db.scalar(query.count) > 0 {
            return true
        }
        return false
    }
    
    static func findPestForSpray(_ sprayId: Int) -> [T]? {
        let query = table.filter(db_spray_id == sprayId)
        var retArray = [T]()
        for item in try! db.prepare(query) {
            retArray.append(SprayPesticide(id: item[db_id], sprayId: item[db_spray_id], pestId: item[db_pest_id], dose: item[db_dose], doseAmount: item[db_dose_amount],reason: item[db_reason], periodCode:item[db_periodCode]))
        }
        return retArray
    }
    static func findPestIdsForSpray(_ sprayId: Int) -> [Int]? {
        let query = table.filter(db_spray_id == sprayId)
        var retArray = [Int]()
        for item in try! db.prepare(query) {
            retArray.append(item[db_pest_id])
        }
        return retArray
    }
    static func findPestIdsAndSprayId(_ pestId: Int, sprayId: Int) -> [T]? { //used to search the pesticide for spraying in search controller
        let query = table.filter(db_pest_id == pestId && db_spray_id == sprayId)
        var retArray = [T]()
        for item in try! db.prepare(query) {
            retArray.append(SprayPesticide(id: item[db_id], sprayId: item[db_spray_id], pestId: item[db_pest_id], dose: item[db_dose], doseAmount: item[db_dose_amount]))
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
    static func delete (_ sprayId: Int, pestToDelIds: Set<Int>) {
        for wid in pestToDelIds {
            let query = table.filter(db_spray_id == sprayId && db_pest_id == wid)
            try! _ = db.run (query.delete())
        }
        
    }
    static func deletePesticidesForSpray (_ sprayId: Int) {
        let pesticidesForSpray = table.filter(db_spray_id == sprayId)
        try! _ = db.run (pesticidesForSpray.delete())
    }
    
    
}
