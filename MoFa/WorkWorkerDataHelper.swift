//
//  WorkWorkerDataHelper.swift
//  MoFa
//
//  Created by Arnold Schmid on 29.07.15.
//  Copyright (c) 2015 Arnold Schmid. All rights reserved.
//

import Foundation
import SQLite
class WorkWorkerDataHelper {
    static let db = DaoSqlLite.sharedInstance.dbConn
    static let TABLE_NAME = "workworker"
    static let db_id = Expression<Int>("id")
    static let db_worker_id = Expression<Int>("worker_id")
    static let db_work_id = Expression<Int>("work_id")
    static let db_hours = Expression<Double>("hours")
    static let table = Table(TABLE_NAME)
    
    typealias T = WorkWorker
    static func insert(_ item: T) -> Int {
        do {
            let rowId = try db.run (table.insert(or:.replace, db_worker_id <- item.worker_id, db_work_id <- item.work_id, db_hours <- item.hours))
            return Int(rowId)
        }catch{
            return -1
        }
        
        
    }
    static func update (_ item: T) -> Void {
        let query = table.filter(db_work_id == item.work_id && db_worker_id == item.worker_id)
        _ = try! db.run (query.update(db_worker_id <- item.worker_id, db_work_id <- item.work_id, db_hours <- item.hours))
        
    }
    static func exists (_ workId: Int, workerId: Int) -> Bool {
        let query = table.filter (db_work_id == workId && db_worker_id == workerId)
        if try! db.scalar(query.count) > 0 {
            return true
        }
        return false
    }
    static func exists (_ item: T) -> Bool {
        let query = table.filter (db_work_id == item.work_id && db_worker_id == item.worker_id)
        if try! db.scalar(query.count) > 0 {
            return true
        }
        return false
    }
    
    static func findWorkerForWork(_ workId: Int) -> [T]? {
        let query = table.filter(db_work_id == workId)
        var retArray = [T]()
        for item in try! db.prepare(query) {
            retArray.append(WorkWorker(id: item[db_id], workerid: item[db_worker_id], workid: item[db_work_id], hours: item[db_hours]))
        }
        return retArray
    }
    static func findWorkerIdsForWork(_ workId: Int) -> [Int]? {
        let query = table.filter(db_work_id == workId)
        var retArray = [Int]()
        for item in try! db.prepare(query) {
            retArray.append(item[db_worker_id])
        }
        return retArray
    }
    static func findWorkerForWorkDictionary(_ workId: Int) -> [Int:Double]? {
        let query = table.filter(db_work_id == workId).order(db_worker_id.asc)
        var retDic = [Int:Double]()
        for item in try! db.prepare(query) {
            retDic[item[db_worker_id]] = item[db_hours]
        }
        return retDic
    }
    static func delete (_ item: T) -> Void {
        let query = table.filter(db_id == item.id)
        _ = try! db.run(query.delete())
        
    }
    static func delete (_ workId: Int, workerToDelIds: Set<Int>) {
        for wid in workerToDelIds {
            let query = table.filter(db_work_id == workId && db_worker_id == wid)
            _ = try! db.run(query.delete())
        }
        
    }
    static func deleteWorkersForWork (_ workid: Int) {
        let workersForWork = table.filter(db_work_id == workid)
        _ = try! db.run(workersForWork.delete())
    }
    
    static func saveWorkerDic (_ workerDic:[Int:Double], workId: Int) {
            let existingWorkersIds = Set(findWorkerIdsForWork(workId)!)
            if !existingWorkersIds.isEmpty { //not empty
                let newWorkerIds = Set([Int](workerDic.keys))
                let setToDel = existingWorkersIds.subtracting(newWorkerIds)
                //println("set to del: \(setToDel)")
                delete(workId,workerToDelIds: setToDel)
            }
        for (workerId, hours) in workerDic { //iterating over the data
            let element = WorkWorker()
            element.work_id = workId
            element.worker_id = workerId
            element.hours = hours
            if existingWorkersIds.contains(workerId){
                update(element)
               //println ("update workerid: \(workerId) with hours: \(element.hours)")
            }else{
                _ = insert(element)
                //println("insert workerid:\(workerId)")
            }
            
        }
    }
    
    
}
