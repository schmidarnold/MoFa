//
//  SprayPesticide.swift
//  MoFa
//
//  Created by Arnold Schmid on 05.09.15.
//  Copyright (c) 2015 Arnold Schmid. All rights reserved.
//

import Foundation

class SprayPesticide: SprayProduct {
    @objc var id: Int = 0
    @objc var spray_id: Int = 0
    @objc var prod_id: Int = 0
    @objc var dose: Double = 0.00
    @objc var doseAmount: Double = 0.00
    @objc var isPest: Bool = true
    var reason: String?
    var periodCode: String?
    init(){
        
    }
    
    init (id: Int, sprayId: Int, pestId: Int, dose: Double, doseAmount: Double) {
        self.id = id
        self.spray_id = sprayId
        self.prod_id = pestId
        self.dose = dose
        self.doseAmount = doseAmount
    }
    // for ASA16 with reason and periodCode
    init (id: Int, sprayId: Int, pestId: Int, dose: Double, doseAmount: Double,reason: String?, periodCode: String?) {
        self.id = id
        self.spray_id = sprayId
        self.prod_id = pestId
        self.dose = dose
        self.doseAmount = doseAmount
        self.reason = reason
        self.periodCode = periodCode
    }
}
