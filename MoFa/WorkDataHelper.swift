//
//  WorkDataHelper.swift
//  MoFa
//
//  Created by Arnold Schmid on 05.07.15.
//  Copyright (c) 2015 Arnold Schmid. All rights reserved.
//

import Foundation
import SQLite
class WorkDataHelper{
    static let db = DaoSqlLite.sharedInstance.dbConn
    static let TABLE_NAME = "work"
    static let db_id = Expression<Int>("id")
    static let db_task_id = Expression<Int>("task_id")
    static let db_date = Expression<Int>("date")
    static let db_valid = Expression<Bool>("valid")
    static let db_sended = Expression<Bool>("sended")
    static let db_note = Expression<String?>("note")
    static let table = Table(TABLE_NAME)
    
    typealias T = Work
    
    static func insert(_ item: T) -> Int {
        do {
            let rowId =  try db.run(table.insert(or:.replace, db_task_id <- item.taskId!, db_date <- item.workDate!, db_note <- item.note, db_sended <- item.sended, db_valid <- item.valid))
            return Int(rowId)
        }catch {
             return -1
        }
        
       
        
    }
    static func delete (_ item: T) -> Void {
        if let id = item.workId {
            let query = table.filter(db_id == id)
            try! _ = db.run(query.delete())
        }
    }
    static func update (_ item: T) -> Void {
        if let id = item.workId {
            let query = table.filter(db_id == id)
            try! _ = db.run (query.update(db_task_id <- item.taskId!, db_date <- item.workDate!, db_note <- item.note, db_sended <- item.sended, db_valid <- item.valid))
        }
    }
    static func find(_ id: Int) -> T? {
        let query = table.filter(db_id == id)
        var results: T?
        if let item = try! db.pluck(query) {
            results = Work(workId: item[db_id], note: item[db_note], workDate: item[db_date], taskId: item[db_task_id], valid: item[db_valid], sended: item[db_sended])
        }
        return results
    }
    static func findAll() -> [T]? {
        var retArray = [T]()
        for item in try! db.prepare(table) {
            retArray.append(Work(workId: item[db_id], note: item[db_note], workDate: item[db_date], taskId: item[db_task_id], valid: item[db_valid], sended: item[db_sended]))
        }
        return retArray
    }
    
    static func findAllNotSended() -> [T]? {
        let query = table.filter(db_sended == false).order(db_date.desc)
        var retArray = [T]()
        for item in try! db.prepare(query) {
            retArray.append(Work(workId: item[db_id], note: item[db_note], workDate: item[db_date], taskId: item[db_task_id], valid: item[db_valid], sended: item[db_sended]))
        }
        return retArray
    }
    static func findAllNotSendedAndValid() -> [T]? {
        let query = table.filter(db_sended == false && db_valid == true).order(db_date.asc)
        var retArray = [T]()
        for item in try! db.prepare(query) {
            retArray.append(Work(workId: item[db_id], note: item[db_note], workDate: item[db_date], taskId: item[db_task_id], valid: item[db_valid], sended: item[db_sended]))
        }
        return retArray
    }
    static func countAllNotSendedAndValid() -> Int {
        let query = table.filter(db_sended == false && db_valid == true).order(db_date.desc)
        let count = try! db.scalar (query.count)
        return count
        
    }
    static func countAll() -> Int {
        //let query = table.filter(db_sended == false && db_valid == true).order(db_date.desc)
        let count = try! db.scalar (table.count)
        return count
        
    }
    static func getAllOldSendedNotSprayWorks() -> [T] {
        let userCalendar = Calendar.current
        let fortyDaysAgo = Int((userCalendar as NSCalendar).date(
            byAdding: [.day],
            value: -40,
            to: Date(),
            options: [])!.timeIntervalSince1970)
        let notSprayTask = TaskDataHelper.getNotSprayCodesOnly()
        var retArray = [T]()
        let works = table.filter(db_sended == true && db_date < fortyDaysAgo && notSprayTask.contains(db_task_id))
        for item in try! db.prepare(works) {
            retArray.append(Work(workId: item[db_id], note: item[db_note], workDate: item[db_date], taskId: item[db_task_id], valid: item[db_valid], sended: item[db_sended]))
        }
        return retArray
    }
    static func setSendedToTrue() {
        //let query = table.filter(db_sended == false && db_valid == true).order(db_date.desc)
         let query = table.filter(db_sended == false && db_valid == true)
        try! _ = db.run (query.update(db_sended <- true))
    }
    static func deleteWorkAndAllReferencedData(_ item:T) {
        do {
            try db.transaction {
                WorkVQuarterDataHelper.deleteVQuartersForWork(item.workId!)
                WorkWorkerDataHelper.deleteWorkersForWork(item.workId!)
                if let sp = SprayingDataHelper.findSprayingForWork(item.workId!) { //removing SprayEntry
                    let sprayId = sp.id
                    SprayPesticideHelper.deletePesticidesForSpray(sprayId)
                    SprayFertilizerHelper.deleteFertilizersForSpray(sprayId)
                    SprayingDataHelper.delete(sp)
                }
                HarvestDataHelper.deleteHarvestForWorkId(item.workId!)
                WorkFertilizerDataHelper.deleteSoilFertForWorkId(item.workId!)
                GlobalDataHelper.deleteWaterForWorkId(item.workId!)
                delete(item)
            }
        }catch _ {
            print ("error in deleting data")
        }
    }
    static func clearArchiv() -> Int {
        let query = table.filter(db_sended == true)
        var retArray = [T]()
        for item in try! db.prepare(query) {
            retArray.append(Work(workId: item[db_id], note: item[db_note], workDate: item[db_date], taskId: item[db_task_id], valid: item[db_valid], sended: item[db_sended]))
        }
        for item in retArray {
            deleteWorkAndAllReferencedData(item)
        }
        return retArray.count
    }
}
