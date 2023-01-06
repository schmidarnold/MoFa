//
//  SprayFertilizer.swift
//  MoFa
//
//  Created by Arnold Schmid on 09.09.15.
//  Copyright (c) 2015 Arnold Schmid. All rights reserved.
//

import Foundation
class SprayFertilizer : SprayProduct{
    @objc var id: Int = 0
    @objc var spray_id: Int = 0
    @objc var prod_id: Int = 0
    @objc var dose: Double = 0.00
    @objc var doseAmount: Double = 0.00
    @objc var isPest: Bool = false 
    init(){
        
    }
    
    init (id: Int, sprayId: Int, fertId: Int, dose: Double, doseAmount: Double) {
        self.id = id
        self.spray_id = sprayId
        self.prod_id = fertId
        self.dose = dose
        self.doseAmount = doseAmount
    }
}