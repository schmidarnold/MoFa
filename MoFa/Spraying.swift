//
//  Spraying.swift
//  MoFa
//
//  Created by Arnold Schmid on 13.08.15.
//  Copyright (c) 2015 Arnold Schmid. All rights reserved.
//

import Foundation
class Spraying {
    var id: Int = 0
    var work_id: Int = 0
    var wateramount: Double?
    var concentration : Double = 1.00
    var weather : Int = 1
    init(){
        
    }
    
    init (id: Int, workid: Int, wateramount: Double, concentration: Double, weather: Int) {
        self.id = id
        self.work_id = workid
        self.wateramount = wateramount
        self.concentration = concentration
        self.weather = weather
        
    }
}
