//
//  Settings.swift
//  MoFa
//
//  Created by Arnold Schmid on 18.04.15.
//  Copyright (c) 2015 Arnold Schmid. All rights reserved.
//

import Foundation

class Settings{
    
    static var currentSetting : BackendSoftware = BackendSoftware.asa
    static var database : String?
    static let showPsmKey = "PSMKey"
    static let asaNoteKey = "ASANote"
    static let asaVer16Key = "ASAVer16"
    static let asaSortingByCode = "ASASortingByCode"
    static let key = "backend"
    static let asaCultivationType = "ASACultivation"
    
    enum BackendSoftware : Int{
        case asa
        case excel
    }
    
    
    static func getBackendSoftware() -> BackendSoftware{
        if keyAlreadyExist(){
            let defaults = UserDefaults.standard
            let myEnv = BackendSoftware(rawValue: defaults.integer(forKey: key))!
            return myEnv
        } else {
            setBackendSoftware(BackendSoftware.asa)
            return .asa
        }
    }
    
    static func getDatabase()-> String{
        return database!
    }
    static func setDatabase(_ db : String){
        database = db
    }
    
    static func setBackendSoftware(_ backend: BackendSoftware){
        let defaults = UserDefaults.standard
        print("Setting Backendsoftware to \(backend.rawValue)")
        defaults.set(backend.rawValue, forKey: key)
        
    }
    static func keyAlreadyExist() -> Bool {
        if (UserDefaults.standard.object(forKey: key) != nil) {
            return true
        }else {
            return false
        }
    }
    
    static func setUserDefaultsBoolean(keyValue:String, value:Bool){
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: keyValue)
    }

    static func getUserDefaultsBoolean(keyValue:String) -> Bool{
        let defaults = UserDefaults.standard
        let value = defaults.bool(forKey: keyValue)
        return value
    }
    static func setUserDefaultsString(keyValue:String, value:String){
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: keyValue)
    }
    static func getUserDefaultsString(keyValue:String)->String?{
        let defaults = UserDefaults.standard
        let value = defaults.string(forKey: keyValue)
        return value
    }
}
