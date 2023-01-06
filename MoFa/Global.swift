//
//  Global.swift
//  MoFa
//
//  Created by Arnold Schmid on 17.12.15.
//  Copyright © 2015 Arnold Schmid. All rights reserved.
//

import Foundation
struct Constants {
    static let Spraying = 1
    static let Purchase = 2
    static let Search = 3
    enum SearchType {
        case lastSprayEntries
        case searchProd
    }
    enum Weather:Int {
        case sunny=1
        case partCloudy=2
        case cloudy=3
        case rainLight=4
        case rainHeavy=5
        case night=6
    }
    enum Water:Int {
        case irrigation = 1
        case frost = 2
        case drip = 3
    }
    enum GlobalDataType:String {
        case Irrigation = "Irrigation"
        case pest = "Pest"
        case control = "ControlType"
        case BlossomStart = "BlossomStart"
        case BlossomEnd = "BlossomEnd"
        case HarvestStart = "HarvestStart"
        case CropAmount = "CropAmount"
        case PestReasons = "PestReasons"
    }
}
