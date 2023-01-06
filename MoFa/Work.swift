//
//  Work.swift
//  MoFa
//
//  Created by Arnold Schmid on 24.06.15.
//  Copyright (c) 2015 Arnold Schmid. All rights reserved.
//

import Foundation

class Work {
    var workId: Int?
    var note: String?
    var workDate: Int?
    var taskId: Int?
    var valid: Bool = false
    var sended: Bool = false
    
    init(){
        
    }
    
    init(workId: Int, note: String?, workDate: Int, taskId: Int, valid: Bool, sended: Bool){
        self.workId = workId
        self.note = note
        self.workDate = workDate
        self.taskId = taskId
        self.valid = valid
        self.sended = sended

    }
    
    
}