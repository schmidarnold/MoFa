//
//  CategoryDataHelper.swift
//  MoFa
//
//  Created by Arnold Schmid on 07.11.15.
//  Copyright © 2015 Arnold Schmid. All rights reserved.
//

import Foundation
import SQLite
class CategoryDataHelper {
    static let db = DaoSqlLite.sharedInstance.dbConn
    static let TABLE_NAME = "fruitquality"
    static let db_id = Expression<Int>("id")
    static let db_code = Expression<String?>("code")
    static let db_quality = Expression<String>("quality")
    static let table = Table(TABLE_NAME)
    
    static func getQuality(_ qualityId:Int) -> String {
        var quality : String = ""
        let query = table.filter(db_id == qualityId)
        if let item = try! db.pluck(query) {
           quality = item[db_quality]
        }
        return quality
    }
    static func findAll() -> [Category]? {
        var retArray = [Category]()
        for item in try! db.prepare(table) {
            retArray.append(Category(id:item[db_id], name: item[db_quality] ))
        }
        return retArray
    }
    static func findFirst() -> (Int, String)? {
        if let first = try! db.pluck(table) {
            return (first[db_id], first[db_quality])
        }else {
            return nil
        }
    }
    static func deleteAll() {
        try! _ = db.run (table.delete())
    }
    static func getCode(_ id: Int) -> String {
        var code : String = ""
        let query = table.filter(db_id == id)
        if let item = try! db.pluck(query) {
            code = item[db_code]!
        }
        return code
    }
    
}
