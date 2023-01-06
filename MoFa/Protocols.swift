//
//  Protocols.swift
//  MoFa
//
//  Created by Arnold Schmid on 14.05.15.
//  Copyright (c) 2015 Arnold Schmid. All rights reserved.
//
import SQLite
enum dataType:Int {
    case worker=1, machine
}
protocol ImportDataInterface{
    func importAsaData(_ data:Data)
    func importExcelData(_ data:Data)
    
}
protocol Value {
    associatedtype Datatype: Binding
    static var declaredDatatype: String { get }
    static func fromDatatypeValue(_ datatypeValue: Datatype) -> Self
    var datatypeValue: Datatype { get }
}
protocol getResourceDataDelegate {
    func getResDictionary(_ resDic: [Int:Double], source: dataType, lastUsedHour : Float)
}
@objc protocol Product : class {
    var id : Int {get}
    var productName: String {get}
   
}
@objc protocol SprayProduct : class {
    var id: Int {get}
    var spray_id: Int {get}
    var prod_id: Int {get}
    var dose: Double {get set}
    var doseAmount: Double {get set}
    var isPest: Bool {get}
   
}
@objc protocol PurchaseProduct : class {
    var id: Int {get}
    var purchase_id: Int {get}
    var amount: Double {get set}
    func getProdId() -> Int
    func getProductName() -> String
}
