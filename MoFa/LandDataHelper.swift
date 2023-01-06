//
//  LandDataHelper.swift
//  MoFa
//
//  Created by Arnold Schmid on 21.07.15.
//  Copyright (c) 2015 Arnold Schmid. All rights reserved.
//

import Foundation
import SQLite
class LandDataHelper {
    static let db = DaoSqlLite.sharedInstance.dbConn
    static let TABLE_NAME = "land"
    static let db_id = Expression<Int>("id")
    static let db_name = Expression<String>("name")
    static let db_code = Expression<String?>("code")
    
    static let table = Table(TABLE_NAME)
    
    
    typealias T = Land
    
    static func insert(_ item: T) {
        let curLand = table.filter(db_id == item.id!)
        if try! db.scalar(curLand.count) == 1 {
            _ = curLand.update(db_name <- item.name!, db_code <- item.code!)
        }else {
            try! _ = db.run (table.insert(db_id <- item.id!, db_name <- item.name!, db_code <- item.code!))
        }
        
    }
    static func find(_ id: Int) -> T? {
        let query = table.filter(db_id == id)
        var results: T?
        if let item = try! db.pluck (query) {
            results = Land(id:item[db_id], code: item[db_code]!, name : item[db_name] )
        }
        return results
    }
    
    static func findAll() -> [T]? {
        var retArray = [T]()
        for item in try! db.prepare(table) {
            retArray.append(Land(id:item[db_id], code: item[db_code]!, name : item[db_name]))
        }
        let asaSorted = Settings.getUserDefaultsBoolean(keyValue: Settings.asaSortingByCode)
        if (asaSorted) {
            return retArray.sorted(by: { $0.code! < $1.code! })
        }else {
            return retArray
        }
        
    }
    
    static func findLandNameForId(_ id: Int) -> String {
        let query = table.filter(db_id == id)
        var name: String = ""
        if let item = try! db.pluck (query) {
            name = item[db_name]
            
        }
        return name
    }
    static func deleteAll() {
        try! _ = db.run (table.delete())
    }
    
}
