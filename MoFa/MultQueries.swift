//
//  MultQueries.swift
//  MoFa
//
//  Created by Arnold Schmid on 17.01.16.
//  Copyright © 2016 Arnold Schmid. All rights reserved.
//

import Foundation
import SQLite
class MultQueries {
   static let db = DaoSqlLite.sharedInstance.dbConn
   static let workid = Expression<Int>("id")
   static let sprayworkid = Expression<Int>("work_id")
   static let vqworkid = Expression<Int>("work_id")
   static let vquarterid = Expression<Int>("vquarter_id")
   static let workDate = Expression<Int>("date")
   static let workWorkerWorkId = Expression<Int>("work_id")
    static let db_hours = Expression<Double>("hours")
    
    static func getLastSprayWorkForVQ (_ vqId : Int) -> [Int] {
        var resultWorks = [Int]()
        let sprayWorks = WorkDataHelper.table.join(SprayingDataHelper.table, on: SprayingDataHelper.table[sprayworkid] == WorkDataHelper.table[workid]).join(WorkVQuarterDataHelper.table, on: WorkVQuarterDataHelper.table[WorkVQuarterDataHelper.db_work_id] == WorkDataHelper.table[workid]).filter(WorkVQuarterDataHelper.db_vquarter_id == vqId).order(workDate.desc).limit(3)
        for work in (try! db.prepare(sprayWorks.select(WorkDataHelper.table[WorkDataHelper.db_id]))){
            resultWorks.append(work[WorkDataHelper.db_id])
           }
        
        return resultWorks
    
    }
    static func getAllSprayWorkForVQ (_ vqId : Int) -> [Int] {
        var resultWorks = [Int]()
        let sprayWorks = WorkDataHelper.table.join(SprayingDataHelper.table, on: SprayingDataHelper.table[sprayworkid] == WorkDataHelper.table[workid]).join(WorkVQuarterDataHelper.table, on: WorkVQuarterDataHelper.table[WorkVQuarterDataHelper.db_work_id] == WorkDataHelper.table[workid]).filter(WorkVQuarterDataHelper.db_vquarter_id == vqId).order(workDate.desc).limit(3)
        for work in (try!db.prepare(sprayWorks.select(WorkDataHelper.table[WorkDataHelper.db_id]))){
            resultWorks.append(work[WorkDataHelper.db_id])
        }
        return resultWorks
        
    }
    
    static func getLastSprayings (_ vquarterList : [VQuarter]) -> Dictionary<Int,[String]> {
        var vqSprayList = Dictionary<Int,[String]>()
        let noValue = "Kein Eintrag vorhanden"
        for vq in vquarterList {
            
            var sprayEntries = [String]()
            let vqId  = vq.id!
            let worksId = getLastSprayWorkForVQ(vqId)
            for w in worksId {
                if let curWork = WorkDataHelper.find(w){
                    let dateOfWork =  (getDateAsString(curWork.workDate!))
                    let spray = SprayingDataHelper.findSprayingForWork(w)
                    let pestEntries = SprayPesticideHelper.findPestForSpray((spray?.id)!)
                    for pest in pestEntries! {
                        
                        let pestName = PesticideDataHelper.findProdNameForId(pest.prod_id)
                        let strPest = "\(dateOfWork) \(pestName) \(pest.dose)"
                        sprayEntries.append(strPest)
                    }
                    let fertEntries = SprayFertilizerHelper.findFertForSpray((spray?.id)!)!
                    for fert in fertEntries {
                       
                        let fertName = FertilizerDataHelper.findProdNameForId(fert.prod_id)
                        let strFert = "\(dateOfWork) \(fertName) \(fert.dose)"
                        sprayEntries.append(strFert)
                    }
                    
                    
                }

            }
            if worksId.count == 0 {
                sprayEntries.append(noValue)
            }
            vqSprayList[vqId] = sprayEntries
        }
      return vqSprayList
    }
    
    static func getProdForVQ (_ vquarterList: [VQuarter], product: Product) -> Dictionary<Int, [String]> {
        var vqSprayList = Dictionary<Int,[String]>()
        let noValue = "Kein Eintrag vorhanden"
        let selectedProduct = product
        for vq in vquarterList {
            var noResult = true
            var sprayEntries = [String]()
            let vqId  = vq.id!
            let worksId = getAllSprayWorkForVQ(vqId)
            for w in worksId {
                
                if let curWork = WorkDataHelper.find(w){
                    let dateOfWork =  (getDateAsString(curWork.workDate!))
                    let spray = SprayingDataHelper.findSprayingForWork(w)
                    if let isPest = selectedProduct as? Pesticide {
                        let pestEntries = SprayPesticideHelper.findPestIdsAndSprayId(isPest.id, sprayId: (spray?.id)!)
                        for pest in pestEntries! {
                            noResult = false
                            let pestName = PesticideDataHelper.findProdNameForId(pest.prod_id)
                            let strPest = "\(dateOfWork) \(pestName) \(pest.dose)"
                            sprayEntries.append(strPest)
                        }
                    }
                    if let isFert = selectedProduct as? Fertilizer {
                        let fertEntries = SprayFertilizerHelper.findFertIdsAndSprayId(isFert.id, sprayId: (spray?.id)!)
                        for fert in fertEntries! {
                            noResult = false
                            let fertName = FertilizerDataHelper.findProdNameForId(fert.prod_id)
                            let strFert = "\(dateOfWork) \(fertName) \(fert.dose)"
                            sprayEntries.append(strFert)
                        }
                    }
                }
                
            }
            if noResult{
                sprayEntries.append(noValue)
            }
            vqSprayList[vqId] = sprayEntries
        }
        return vqSprayList
    }
    
    static func getDateAsString(_ date:Int) -> String {
        let dateMaker = DateFormatter()
        dateMaker.dateFormat = "dd.MM.YY"
        let x = Date(timeIntervalSince1970: TimeInterval(date))
        let strDate = dateMaker.string(from: x)
        return strDate
    }
    static func checkIfDataExists() -> Bool {
        
        if try! TaskDataHelper.db.scalar(TaskDataHelper.table.count) > 0 {
            return true
        }else{
            return false
        
        }
    }
    static func sumOfHours(_ workerId: Int, fromDate: Date, toDate: Date) -> Double {
        let startDate = Int(fromDate.timeIntervalSince1970)
        let endDate = Int(toDate.timeIntervalSince1970)
        let filteredWork = WorkDataHelper.table.filter(WorkDataHelper.db_date > startDate && WorkDataHelper.db_date < endDate)
        let filteredWorkWorker = WorkWorkerDataHelper.table.filter(WorkWorkerDataHelper.db_worker_id == workerId)
        let workerHours = filteredWorkWorker.join(filteredWork, on: filteredWork[workid] == filteredWorkWorker[workWorkerWorkId])
        let sum =  try! db.scalar(workerHours.select(db_hours.sum))
        if sum != nil {
            return sum!
        } else {
            return 0.00
        }
        
    }
    static func getDbVersion()-> Int {
        return db.userVersion
    }
    static func createGlobalTable() {
        print("Creating Table global")
        let global = Table("global")
        let globalId = Expression<Int> ("id")
        let globalTypInfo = Expression<String?>("typeInfo")
        let globalData = Expression<String?>("data")
        let globalWorkId = Expression<Int?>("workId")
        try! db.run(global.create { t in     // CREATE TABLE "global" (
            t.column(globalId, primaryKey: .autoincrement) //     "id" INTEGER PRIMARY KEY AutoIncrement,
            t.column(globalTypInfo)  //
            t.column(globalData)
            t.column(globalWorkId)
            })
        db.userVersion = 12
        
    }
    static func convertConToDouble(){
        print ("trying to convert Spraying Table");
        try! db.execute(
            "BEGIN TRANSACTION;" +
                "ALTER TABLE spraying RENAME TO tmp;" +
                "CREATE TABLE spraying (concentration DOUBLE PRECISION, id INTEGER PRIMARY KEY AUTOINCREMENT," +
                "wateramount DOUBLE PRECISION,weather INTEGER, work_id INTEGER);" +
                "INSERT INTO spraying(concentration, id, wateramount,weather," +
                "work_id)SELECT concentration, id, wateramount,weather, work_id FROM tmp;" +
                "DROP TABLE tmp;" +
            "COMMIT TRANSACTION;"
        )
        db.userVersion = 14
    }
    static func updateToVer17(){
        print("trying to upgrade to version 17")
        try! db.execute(
            "BEGIN TRANSACTION;" +
                "ALTER TABLE spraypesticide add column periodCode VarChar;" +
                "ALTER TABLE spraypesticide add column reason VarChar;" +
                "ALTER TABLE pesticide add column status VarChar;" +
                "ALTER TABLE vquarter add column data VarChar;" +
                "ALTER TABLE pesticide add column data VarChar;" +
                "ALTER TABLE fertilizer add column data VarChar;" +
                "ALTER TABLE task add column data VarChar;" +
                "ALTER TABLE work add column data VarChar;" +
                "ALTER TABLE purchasefertilizer add column data VarChar;" +
                "ALTER TABLE purchasepesticide add column data VarChar;" +
            "COMMIT TRANSACTION;"
        )
        db.userVersion = 17
        
    }

}
