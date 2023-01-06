//
//  PurchaseFertilizer.swift
//  MoFa
//
//  Created by Arnold Schmid on 17.12.15.
//  Copyright © 2015 Arnold Schmid. All rights reserved.
//

import Foundation
class PurchaseFertilizer:PurchaseProduct{
    @objc var id: Int = 0
    @objc var purchase_id: Int = 0
    @objc var fert_id: Int = 0
    @objc var amount: Double = 0.00
    
    
    init(){
        
    }
    
    init (id: Int, purchaseId: Int, fertId: Int, amount: Double) {
        self.id = id
        self.purchase_id = purchaseId
        self.fert_id = fertId
        self.amount = amount
        
    }
    @objc func getProdId() -> Int {
        return self.fert_id
    }
    @objc func getProductName() -> String {
        return FertilizerDataHelper.findProdNameForId(fert_id)
    }
}