//
//  WorkMachineDataHelper.swift
//  MoFa
//
//  Created by Arnold Schmid on 04.08.15.
//  Copyright (c) 2015 Arnold Schmid. All rights reserved.
//

import Foundation
import SQLite
class WorkMachineDataHelper {
    static let db = DaoSqlLite.sharedInstance.dbConn
    static let TABLE_NAME = "workmachine"
    static let db_id = Expression<Int>("id")
    static let db_machine_id = Expression<Int>("machine_id")
    static let db_work_id = Expression<Int>("work_id")
    static let db_hours = Expression<Double>("hours")
    static let table = Table(TABLE_NAME)
    
    typealias T = WorkMachine
    static func insert(_ item: T) -> Int {
        do {
            let rowId = try db.run(table.insert(or:.replace, db_machine_id <- item.machine_id, db_work_id <- item.work_id, db_hours <- item.hours))
            return Int(rowId)
        } catch {
            return -1
        }
        
    }
    static func update (_ item: T) -> Void {
        let query = table.filter(db_work_id == item.work_id && db_machine_id == item.machine_id)
        try! _ = db.run (query.update(db_machine_id <- item.machine_id, db_work_id <- item.work_id, db_hours <- item.hours))
        
    }
    static func exists (_ workId: Int, machineId: Int) -> Bool {
        let count = try! db.scalar (table.filter (db_work_id == workId && db_machine_id == machineId).select(db_machine_id.count))
        if count > 0 {
            return true
        }
        return false
    }
    static func exists (_ item: T) -> Bool {
        let count = try! db.scalar (table.filter (db_work_id == item.work_id && db_machine_id == item.machine_id).select(db_machine_id.count))
        if count > 0 {
            return true
        }
        return false
    }
    
    static func findMachineForWork(_ workId: Int) -> [T]? {
        let query = table.filter(db_work_id == workId)
        var retArray = [T]()
        for item in try! db.prepare(query) {
            retArray.append(WorkMachine(id: item[db_id], machineid: item[db_machine_id], workid: item[db_work_id], hours: item[db_hours]))
        }
        return retArray
    }
    static func findMachineIdsForWork(_ workId: Int) -> [Int]? {
        let query = table.filter(db_work_id == workId)
        var retArray = [Int]()
        for item in try! db.prepare(query) {
            retArray.append(item[db_machine_id])
        }
        return retArray
    }
    static func findMachineForWorkDictionary(_ workId: Int) -> [Int:Double]? {
        let query = table.filter(db_work_id == workId).order(db_machine_id.asc)
        var retDic = [Int:Double]()
        for item in try! db.prepare(query) {
            retDic[item[db_machine_id]] = item[db_hours]
        }
        return retDic
    }
    static func delete (_ item: T) -> Void {
        let query = table.filter(db_id == item.id)
        try! _ = db.run (query.delete())
        
    }
    static func delete (_ workId: Int, machineToDelIds: Set<Int>) {
        for mid in machineToDelIds {
            let query = table.filter(db_work_id == workId && db_machine_id == mid)
            try! _ = db.run (query.delete())
        }
        
    }
    static func deleteMachinesForWork (_ workid: Int) {
        let machinesForWork = table.filter(db_work_id == workid)
        try! _ = db.run (machinesForWork.delete())
    }
    
    static func saveMachineDic (_ machineDic:[Int:Double], workId: Int) {
        let existingMachineIds = Set(findMachineIdsForWork(workId)!)
        if !existingMachineIds.isEmpty { //not empty
            let newMachineIds = Set([Int](machineDic.keys))
            let setToDel = existingMachineIds.subtracting(newMachineIds)
            delete(workId,machineToDelIds: setToDel)
        }
        for (machineId, hours) in machineDic { //iterating over the data
            let element = WorkMachine()
            element.work_id = workId
            element.machine_id = machineId
            element.hours = hours
            if existingMachineIds.contains(machineId){
                update(element)
                print ("update machineid: \(machineId)")
            }else{
                _ = insert(element)
                print("insert machineid:\(machineId)")
            }
            
        }
    }
}
