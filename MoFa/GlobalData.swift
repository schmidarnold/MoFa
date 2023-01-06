//
//  GlobalData.swift
//  MoFa
//
//  Created by Arnold Schmid on 09.08.16.
//  Copyright © 2016 Arnold Schmid. All rights reserved.
//

import Foundation
class GlobalData{
    var id: Int?
    var typeInfo: String?
    var data: String?
    var workId: Int?
    
    
    init(){
        
    }
    
    init(id: Int, typeInfo: String?, data: String?, workId: Int?){
        self.id = id
        self.typeInfo = typeInfo
        self.data = data
        self.workId = workId
        
        
    }
}