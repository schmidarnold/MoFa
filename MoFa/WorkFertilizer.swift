//
//  WorkFertilizer.swift
//  MoFa
//
//  Created by Arnold Schmid on 20.11.15.
//  Copyright © 2015 Arnold Schmid. All rights reserved.
//

import Foundation
class WorkFertilizer{
    var id: Int?
    var workId : Int = 0
    var soilFertId: Int = 0
    var amount: Double = 0.00
    
    
    init(){
        
    }
    
    init (id: Int, workId: Int, soilFertId: Int, amount: Double) {
        self.id = id
        self.workId = workId
        self.soilFertId = soilFertId
        self.amount = amount
        
    }
}