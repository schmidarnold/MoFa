//
//  GlobalDataHelper.swift
//  MoFa
//
//  Created by Arnold Schmid on 09.08.16.
//  Copyright © 2016 Arnold Schmid. All rights reserved.
//

import Foundation
import SQLite
class GlobalDataHelper{
    static let db = DaoSqlLite.sharedInstance.dbConn
    static let TABLE_NAME = "global"
    
    static let db_id = Expression<Int>("id")
    static let db_typeInfo = Expression<String>("typeInfo")
    static let db_data = Expression<String>("data")
    static let db_work_id = Expression<Int?>("workId")
    
    static let table = Table(TABLE_NAME)
    
    typealias T = GlobalData
    static func insert(_ item: T) -> Int {
        do {
            let rowId =  try db.run(table.insert(or:.replace, db_typeInfo <- item.typeInfo!, db_data <- item.data!, db_work_id <- item.workId))
            return Int(rowId)
        }catch let error as NSError{
            print ("Errror: \(error.localizedDescription)" )
            return -1
        }
        
        
        
    }
    static func delete (_ item: T) -> Void {
        if let id = item.id {
            let query = table.filter(db_id == id)
            try! _ = db.run(query.delete())
        }
    }
    static func deleteWaterForWorkId(_ workId: Int) -> Void {
        
        let query = table.filter(db_work_id == workId)
        try! _ = db.run(query.delete())
        
    }
    static func update (_ item: T) -> Void {
        if let id = item.id {
            print("updating blossom with following data \(item.data!)")
            let query = table.filter(db_id == id)
            try! _ = db.run (query.update(db_typeInfo <- item.typeInfo!, db_data <- item.data!, db_work_id <- item.workId))
        }
    }
    
    static func getWaterData(_ id:Int) -> (irrType:Int?, irrDuration:Double?, irrAmount:Double?, irrTotale: Double?){
        var amount: Double?
        var duration: Double?
        var totale: Double?
        var type: Int?
        let query = table.filter(db_id == id)
        if let item = try! db.pluck (query) {
            let waterData = item [db_data]
            let data = waterData.data(using: String.Encoding.utf8, allowLossyConversion: false)!
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: AnyObject]
                if let irrAmount = json["irramount"] as? Double {
                    amount = irrAmount
                }
                if let irrDuration = json["irrduration"] as? Double {
                    duration = irrDuration
                }
                if let irrType = json["irrtype"] as? Int {
                    type = irrType
                }
                if let irrTotale = json["irrtotale"] as? Double{
                    totale = irrTotale
                }
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
        
        }
        return(type,duration,amount,totale)
        
        
    }
    static func getWaterDataForWorkId(_ workId:Int) -> T? {
        let query = table.filter(db_work_id == workId)
        if let item = try! db.pluck (query) {
            return GlobalData(id: item[db_id], typeInfo: item[db_typeInfo], data: item[db_data], workId: item[db_work_id])
        } else {
            return nil
        }
    }
    
    static func getDataByTypeInfo(typeInfo:String) -> T? {
        let query = table.filter(db_typeInfo == typeInfo)
            if let item = try! db.pluck(query){
                return GlobalData(id: item[db_id], typeInfo: item[db_typeInfo], data: item[db_data], workId: item[db_work_id])
            } else {
                return nil
            
            }
        
    }
    static func saveBlossomData(item:T, type:String) {
        if let storedItem = getDataByTypeInfo(typeInfo: type) {
            item.id = storedItem.id
            update(item)
        }else{
            _ = insert(item)
        }
    }
    static func savePestReasons(item:T){
        if let storedItem = getDataByTypeInfo(typeInfo: item.typeInfo!) {
            item.id = storedItem.id
            update(item)
        }else{
            _ = insert(item)
        }
        
    }
    static func exists (_ workId: Int, type:String) -> Bool {
        let query = table.filter (db_work_id == workId && db_typeInfo == type)
        if try! db.scalar(query.count) > 0 {
            return true
        }
        return false
    }
    
    static func createJsonWater(_ irrType:Int, irrDuration:Double, irrAmount:Double, irrTotale:Double)-> String {
        let jsonDic:NSMutableDictionary = NSMutableDictionary()
        jsonDic.setValue(irrType, forKey:"irrtype")
        jsonDic.setValue(irrDuration, forKey:"irrduration")
        jsonDic.setValue(irrAmount,forKey:"irramount")
        jsonDic.setValue(irrTotale, forKey:"irrtotale")
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonDic, options: JSONSerialization.WritingOptions())
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        print("jsonString: \(jsonString)")
        return jsonString
    }
}
