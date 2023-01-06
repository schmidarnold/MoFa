//
//  MachineDataHelper.swift
//  MoFa
//
//  Created by Arnold Schmid on 05.08.15.
//  Copyright (c) 2015 Arnold Schmid. All rights reserved.
//

import Foundation
import SQLite

class MachineDataHelper {
    static let db = DaoSqlLite.sharedInstance.dbConn
    static let TABLE_NAME = "machine"
    static let db_id = Expression<Int>("id")
    static let db_name = Expression<String>("name")
    static let db_code = Expression<String?>("code")
    
    static let table = Table(TABLE_NAME)
    
    typealias T = Machine
    
    static func insert(_ item: T) {
        let exists = table.filter(db_id == item.id)
        if try! db.scalar(exists.count) == 1 {
            _ = try! db.run (exists.update(db_name <- item.name, db_code <- item.code!))
        }else {
           _ =  try! db.run (table.insert(db_id <- item.id, db_name <- item.name, db_code <- item.code!))
        }
        
    }
    static func find(_ id: Int) -> T? {
        let query = table.filter(db_id == id)
        var results: T?
        if let item = try! db.pluck(query) {
            results = Machine(id:item[db_id], code: item[db_code]!, name : item[db_name] )
        }
        return results
    }
    static func findCodeForId(_ id: Int) -> String {
        let query = table.filter(db_id == id)
        var code: String = ""
        if let item = try! db.pluck (query) {
            code = item[db_code]!
            
        }
        return code
    }
    
    static func findAll() -> [T]? {
        var retArray = [T]()
        for item in try! db.prepare(table) {
            retArray.append(Machine(id:item[db_id], code: item[db_code]!, name : item[db_name] ))
        }
        return retArray
    }
    static func deleteAll() {
        _ = try! db.run (table.delete())
    }
    
}
