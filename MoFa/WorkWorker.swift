//
//  WorkWorker.swift
//  MoFa
//
//  Created by Arnold Schmid on 29.07.15.
//  Copyright (c) 2015 Arnold Schmid. All rights reserved.
//

import Foundation
class WorkWorker {
    var id: Int = 0
    var worker_id: Int = 0
    var work_id: Int = 0
    var hours: Double = 0.00
    
    init(){
        
    }
    
    init (id: Int, workerid: Int, workid: Int, hours: Double) {
        self.id = id
        self.worker_id = workerid
        self.work_id = workid
        self.hours = hours
    }
}