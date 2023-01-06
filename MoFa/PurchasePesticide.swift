//
//  PurchasePesticide.swift
//  MoFa
//
//  Created by Arnold Schmid on 17.12.15.
//  Copyright © 2015 Arnold Schmid. All rights reserved.
//

import Foundation
class PurchasePesticide:PurchaseProduct{
    @objc var id: Int = 0
    @objc var purchase_id: Int = 0
    @objc var pest_id: Int = 0
    @objc var amount: Double = 0.00
    
    
    init(){
        
    }
    
    init (id: Int, purchaseId: Int, pestId: Int, amount: Double) {
        self.id = id
        self.purchase_id = purchaseId
        self.pest_id = pestId
        self.amount = amount
        
    }
    @objc func getProdId() -> Int {
        return self.pest_id
    }
    @objc func getProductName() -> String {
        return PesticideDataHelper.findProdNameForId(pest_id)
    }
}