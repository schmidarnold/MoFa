//
//  TaskDataHelper.swift
//  MoFa
//
//  Created by Arnold Schmid on 05.07.15.
//  Copyright (c) 2015 Arnold Schmid. All rights reserved.
//

import Foundation
import SQLite

class TaskDataHelper {
    static let db = DaoSqlLite.sharedInstance.dbConn
    static let TABLE_NAME = "task"
    static let db_id = Expression<Int>("id")
    static let db_task = Expression<String?>("task")
    static let db_code = Expression<String>("code")
    static let db_type = Expression<String?>("type")
    static let table = Table(TABLE_NAME)
    
    
    typealias T = Task
    
    static func find(_ id: Int) -> T? {
        let query = table.filter(db_id == id)
        var results: T?
        if let item = try! db.pluck (query) {
            
            results = Task(id:item[db_id], code: item[db_code], work : item[db_task]!, type : item[db_type])
        }
        return results
    }
    static func findCodeForId(_ id: Int) -> String {
        let query = table.filter(db_id == id)
        var code: String = ""
        if let item = try! db.pluck(query) {
            code = item[db_code]
            
        }
        return code
    }
    static func findTypeForId(_ id: Int) -> String? {
        let query = table.filter(db_id == id)
        var type: String?
        if let item = try! db.pluck (query) {
            type = item[db_type]
            
        }
        return type
    }
    static func getNotSprayCodesOnly() -> [Int] {
        var retArray = [Int]()
        let query = table.filter(db_type != "S" && db_type != "H")
        for item in try! db.prepare(query) {
            retArray.append(item[db_id])
        }
        return retArray
    }
    static func insert(_ item: T) {
        
        let task = table.filter(db_id == item.id!)
         if try! db.scalar(task.count) == 1 {
            _ = try! db.run (task.update(db_task <- item.work!, db_code <- item.code!, db_type <- item.type))
         }else {
          _ =  try! db.run (table.insert(db_id <- item.id!, db_task <- item.work!, db_code <- item.code!, db_type <- item.type))
        }
        
    }
    static func findAll() -> [T]? {
        var retArray = [T]()
        for item in try! db.prepare(table) {
            retArray.append(Task(id:item[db_id], code: item[db_code], work : item[db_task]!, type : item[db_type]))
        }
        return retArray
    }
    static func findAllSorted() -> [T]? {
        var retArray = [T]()
        for item in try! db.prepare(table.order(db_task)) {
            retArray.append(Task(id:item[db_id], code: item[db_code], work : item[db_task]!, type : item[db_type]))
        }
        return retArray
    }
    static func deleteAll() {
        _ = try! db.run (table.delete())
    }
    
}
