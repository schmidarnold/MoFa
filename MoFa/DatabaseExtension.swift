//
//  Database.swift
//  MoFa
//
//  Created by Arnold Schmid on 08.08.16.
//  Copyright © 2016 Arnold Schmid. All rights reserved.
//

import Foundation
import SQLite
extension Connection {
    public var userVersion: Int {
        get { return Int(try! scalar("PRAGMA user_version") as! Int64) }
        set { try! run("PRAGMA user_version = \(newValue)") }
    }
}
