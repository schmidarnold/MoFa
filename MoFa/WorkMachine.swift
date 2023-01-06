//
//  WorkMachine.swift
//  MoFa
//
//  Created by Arnold Schmid on 04.08.15.
//  Copyright (c) 2015 Arnold Schmid. All rights reserved.
//

import Foundation
class WorkMachine {
    var id: Int = 0
    var machine_id: Int = 0
    var work_id: Int = 0
    var hours: Double = 0.00
    
    init(){
        
    }
    
    init (id: Int, machineid: Int, workid: Int, hours: Double) {
        self.id = id
        self.machine_id = machineid
        self.work_id = workid
        self.hours = hours
    }
}