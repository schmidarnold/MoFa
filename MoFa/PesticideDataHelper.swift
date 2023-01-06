//
//  PesticideDataHelper.swift
//  MoFa
//
//  Created by Arnold Schmid on 06.08.15.
//  Copyright (c) 2015 Arnold Schmid. All rights reserved.
//

import Foundation
import SQLite

class PesticideDataHelper{
    static let db = DaoSqlLite.sharedInstance.dbConn
    static let TABLE_NAME = "pesticide"
    static let db_id = Expression<Int>("id")
    static let db_code = Expression<String?>("code")
    static let db_regnr = Expression<Int?>("regNumber")
    static let db_prodName = Expression<String>("productName")
    static let db_defaultDose = Expression<Double?>("defaultDose")
    static let db_constraints = Expression<String?>("constraints")
    
    
    static let table = Table(TABLE_NAME)
    
    
    typealias T = Pesticide
    static func find(_ id: Int) -> T? {
        let query = table.filter(db_id == id)
        var results: T?
        if let item = try! db.pluck(query) {
            results = Pesticide(id: item[db_id], code: item[db_code], productName: item[db_prodName], regNumber: item[db_regnr], defaultDose: item[db_defaultDose], constraints: item[db_constraints])
        }
        return results
    }
    
    
    static func insert(_ item: T) {
        
        let pest = table.filter(db_id == item.id)
        if try! db.scalar(pest.count) == 1 {
            try! _ = db.run (pest.update(db_code <- item.code, db_regnr <- item.regNumber, db_prodName <- item.productName, db_defaultDose <- item.defaultDose, db_constraints <- item.constraints))
        }else {
            try! _ = db.run (table.insert(db_id <- item.id, db_code <- item.code, db_regnr <- item.regNumber, db_prodName <- item.productName, db_defaultDose <- item.defaultDose, db_constraints <- item.constraints))
        }
        
    }
    static func findAll() -> [T]? {
        var retArray = [T]()
        for item in try! db.prepare(table) {
            retArray.append(Pesticide(id: item[db_id], code: item[db_code], productName: item[db_prodName], regNumber: item[db_regnr], defaultDose: item[db_defaultDose], constraints: item[db_constraints]))
        }
        return retArray
    }
    static func findAllSorted() -> [T]? {
        var retArray = [T]()
        let tableS = try! db.prepare (table.order(db_prodName))
        for item in tableS {
            retArray.append(Pesticide(id: item[db_id], code: item[db_code], productName: item[db_prodName], regNumber: item[db_regnr], defaultDose: item[db_defaultDose], constraints: item[db_constraints]))
        }
        return retArray
    }
    
    static func findCodeForId(_ id: Int) -> String {
        let query = table.filter(db_id == id)
        var code: String = ""
        if let item = try!db.pluck (query) {
            code = item[db_code]!
            
        }
        return code
    }
    static func findProdNameForId(_ id: Int) -> String {
        let query = table.filter(db_id == id)
        var name: String = ""
        if let item = try! db.pluck (query) {
            name = item[db_prodName]
            
        }
        return name
    }
    
    static func deleteAll() {
        try! _ = db.run (table.delete())
    }
}
