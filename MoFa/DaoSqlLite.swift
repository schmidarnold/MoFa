//
//  DaoSqlLite.swift
//  MoFa
//
//  Created by Arnold Schmid on 26.06.15.
//  Copyright (c) 2015 Arnold Schmid. All rights reserved.
//

import Foundation
import SQLite

class DaoSqlLite{
    static let sharedInstance = DaoSqlLite()
    let settings: Settings = Settings()
    let dbConn : Connection
    
    init() {
        dbConn = try! Connection(Settings.getDatabase())
        
    }
    
    
    
    
    
}