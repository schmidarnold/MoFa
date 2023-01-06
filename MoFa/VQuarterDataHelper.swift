//
//  VQuarterDataHelper.swift
//  MoFa
//
//  Created by Arnold Schmid on 21.07.15.
//  Copyright (c) 2015 Arnold Schmid. All rights reserved.
//

import Foundation
import SQLite

class VQuarterDataHelper {
    
    static let db = DaoSqlLite.sharedInstance.dbConn
    static let TABLE_NAME = "vquarter"
    static let db_id = Expression<Int>("id")
    static let db_code = Expression<String?>("code")
    static let db_name = Expression<String>("variety")
    static let db_land_id = Expression<Int>("land_id")
    static let db_plantyear = Expression<Int?>("plantYear")
    static let db_clone = Expression<String?>("clone")
    static let db_wateramount = Expression<Double?>("wateramount")
    static let db_size = Expression<Int?>("size")
    
    static let table = Table(TABLE_NAME)
    
    
    typealias T = VQuarter
    static func insert(_ item: T) {
        
        let exists = table.filter(db_id == item.id!)
        
            if try! db.scalar(exists.count) == 1 {
                try! _ = db.run (exists.update(db_code <- item.code, db_name <- item.name!, db_land_id <- item.landId!, db_plantyear <- item.plantYear!, db_clone <- item.clone, db_wateramount <- item.waterAmount, db_size <- item.size))
            }else {
                try! _ = db.run (table.insert(db_id <- item.id!, db_code <- item.code, db_name <- item.name!, db_land_id <- item.landId!, db_plantyear <- item.plantYear, db_clone <- item.clone, db_wateramount <- item.waterAmount, db_size <- item.size))
            }
       
        
        
    }
    static func find(_ id: Int) -> T? {
        let query = table.filter(db_id == id)
        
        var results: T?
        if let item = try! db.pluck(query) {
            
            results = VQuarter(id:item[db_id], code: item[db_code]!, name: item[db_name], landId: item[db_land_id], plantYear: item[db_plantyear]!, clone: item[db_clone]!, waterAmount: item[db_wateramount]!, size: item[db_size]!  )
        }
        return results
    }
    
    static func findAll() -> [T]? {
        var retArray = [T]()
        for item in try! db.prepare(table) {
            retArray.append(VQuarter(id:item[db_id], code: item[db_code], name: item[db_name], landId: item[db_land_id], plantYear: item[db_plantyear], clone: item[db_clone], waterAmount: item[db_wateramount], size: item[db_size]))
        }
        let asaSorted = Settings.getUserDefaultsBoolean(keyValue: Settings.asaSortingByCode)
        if (asaSorted){
            return retArray.sorted(by: { $0.code! > $1.code! })
        }else {
            return retArray
        }
        
    }
    static func findAllSorted() -> [T]? {
        var retArray = [T]()
        for item in try! db.prepare(table) {
            retArray.append(VQuarter(id:item[db_id], code: item[db_code], name: item[db_name], landId: item[db_land_id], plantYear: item[db_plantyear], clone: item[db_clone], waterAmount: item[db_wateramount], size: item[db_size]))
        }
        return retArray.sorted(by: { $0.code! < $1.code! })
    }
    static func findVquarterFromLand (_ landId: Int) -> [T]? {
        var retArray = [T]()
        let result =  table.filter(db_land_id == landId)
        for item in try! db.prepare(result) {
            retArray.append(VQuarter(id:item[db_id], code: item[db_code], name: item[db_name], landId: item[db_land_id], plantYear: item[db_plantyear], clone: item[db_clone], waterAmount: item[db_wateramount], size: item[db_size]))
        }
        return retArray
    }
    static func findSelectedVquarters (_ vqSet: Set<Int>) -> [T]? {
        var retArray = [T]()
        let result = table.filter(vqSet.contains(db_id)).order(db_land_id.asc)
        for item in try! db.prepare(result) {
            retArray.append(VQuarter(id:item[db_id], code: item[db_code], name: item[db_name], landId: item[db_land_id], plantYear: item[db_plantyear], clone: item[db_clone], waterAmount: item[db_wateramount], size: item[db_size]))
        }
        return retArray
    }
    static func findCodeForId(_ id: Int) -> String {
        let query = table.filter(db_id == id)
        var code: String = ""
        if let item = try! db.pluck(query) {
            code = item[db_code]!
            
        }
        return code
    }
    static func findFirstLandIdForId(_ id: Int) -> Int? {
        let query = table.filter(db_id == id)
        var landId : Int?
        if let item = try! db.pluck(query) {
            landId = item[db_land_id]
            return landId
        }else {
            return nil
        }
    }
    
    static func sumWaterAmount (_ vqSet: Set<Int>) -> Double {
        let waterSum =  try! db.scalar (table.filter(vqSet.contains(db_id)).select(db_wateramount.sum))
        if waterSum != nil {
            return waterSum!
        }else {
            return 0.00
        }
        
    }
    static func sumSize (_ vqSet: Set<Int>) -> Int? {
        let sizeSum =  try! db.scalar (table.filter(vqSet.contains(db_id)).select(db_size.sum))
        return sizeSum
    }
    
    static func deleteAll() {
        try! _ = db.run (table.delete())
    }
}
