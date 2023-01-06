//
//  WorkVQuarterDataHelper.swift
//  MoFa
//
//  Created by Arnold Schmid on 23.07.15.
//  Copyright (c) 2015 Arnold Schmid. All rights reserved.
//

import Foundation
import SQLite

class WorkVQuarterDataHelper {
    static let db = DaoSqlLite.sharedInstance.dbConn
    static let TABLE_NAME = "workvquarter"
    static let db_id = Expression<Int>("id")
    static let db_vquarter_id = Expression<Int>("vquarter_id")
    static let db_work_id = Expression<Int>("work_id")
    static let db_amount = Expression<Double?>("amount")
    static let table = Table(TABLE_NAME)
    
    
    static func getWorkVQuarter (_ workId: Int) -> Set<Int> {
        var vqs = Set<Int>()
        let result = table.filter(db_work_id == workId)
            for item in try! db.prepare (result) {
                vqs.insert(item[db_vquarter_id])
            }
        return vqs
    }
    static func insertVquarters (_ newSet : Set<Int>, workId: Int) {
       let savedVqs = getWorkVQuarter(workId)
       let setToDel = savedVqs.subtracting(newSet)
       removeItemForVqs(setToDel)
       let newVqs = newSet.subtracting(savedVqs)
        for vq in newVqs {
            insert (workId, vqId: vq)
        }
    }
    static func removeItemForVqs (_ vqSet: Set<Int>) {
       let vqs = table.filter(vqSet.contains(db_vquarter_id))
        _ = try! db.run (vqs.delete())
    }
    static func insert (_ workId: Int, vqId : Int) {
        _ = try! db.run (table.insert(db_work_id <- workId, db_vquarter_id <- vqId))
    }
    static func deleteVQuartersForWork (_ workid: Int) {
        let vqs = table.filter(db_work_id == workid)
        _ = try! db.run (vqs.delete())
    }
    
    
}
