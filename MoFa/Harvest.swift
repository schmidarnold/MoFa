//
//  Harvest.swift
//  MoFa
//
//  Created by Arnold Schmid on 21.10.15.
//  Copyright © 2015 Arnold Schmid. All rights reserved.
//

import Foundation
class Harvest {
    var id : Int?
    var workId : Int?
    var categoryId : Int?
    var note : String?
    var amount : Int?
    var turn : Int = 1
    var date : Int?
    var boxes : Int?
    var acid : Double?
    var sugar : Double?
    var ph : Double?
    var phenol : Double?
    init() {
        
    }
    init(id: Int, workId: Int, categoryId: Int?, note: String?, amount: Int?, turn: Int, date: Int, boxes: Int?, acid: Double?, sugar: Double?, ph: Double?, phenol: Double?){
        self.id = id
        self.categoryId = categoryId
        self.note = note
        self.amount = amount
        self.turn = turn
        self.date = date
        self.boxes = boxes
        self.acid = acid
        self.sugar = sugar
        self.ph = ph
        self.phenol = phenol
    }
}
