//
//  Pesticide.swift
//  MoFa
//
//  Created by Arnold Schmid on 31.05.15.
//  Copyright (c) 2015 Arnold Schmid. All rights reserved.
//
import AEXML
import Foundation
import SQLite
class Pesticide : ImportDataInterface, Product {
    @objc var id : Int = 0
    var code : String? = ""
    @objc var productName : String = ""
    var regNumber : Int? = 0
    var defaultDose : Double?
    var constraints : String?
    init () {
        
    }
    init(id : Int, code : String?, productName : String, regNumber : Int?, defaultDose: Double? , constraints: String?){
        self.id = id
        self.code = code
        self.productName = productName
        self.regNumber = regNumber
        self.defaultDose = defaultDose
        self.constraints = constraints
        
    }
    func importAsaData(_ data: Data) {
        let asaVer16 = Settings.getUserDefaultsBoolean(keyValue: Settings.asaVer16Key)
        if (asaVer16){
            importASAVer16(data)
        }else {
            var jsonToStore: String = ""
            do {
                let xmlDoc = try AEXMLDocument(xml: data)
                if let pesticides = xmlDoc.root["Spritzmittel"].all {
                    for pesticide in pesticides {
                        jsonToStore=""
                        id = pesticide["ID"].int!
                        code = pesticide["Code"].value!
                        productName = pesticide["Name"].value!
                        regNumber = pesticide["Zulassungsnummer"].int
                        defaultDose = pesticide["DosierungProHl"].double
                        let beeRestriction = pesticide["Bienenschutz"].int
                        var restrictions = [String : AnyObject]()
                        restrictions["beeRestriction"] = beeRestriction as AnyObject?
                        if let constraints = (pesticide["Einschraenkung"].all) {
                            for constraint in constraints {
                                let prodLine = constraint["Name"].value
                                let culture = constraint["Kultur"].value
                                if (prodLine == "Agrios" && culture == "Apfel") {
                                    if (constraint["MaximaleAnzahlAnwendungen"].int != 0) {
                                        let maxAnwendung = constraint["MaximaleAnzahlAnwendungen"].int
                                        restrictions["maxUsage"] = maxAnwendung as AnyObject?
                                    }
                                    if (constraint["MaximaleDosierungProJahr"].int != 0) {
                                        let maxDosJahr = constraint["MaximaleDosierungProJahr"].double
                                        restrictions["maxDoseYear"] = maxDosJahr as AnyObject?
                                    }
                                    if (constraint["MaximaleDosierungProAnwendung"].double != 0) {
                                        let maxDosAnwendung = constraint["MaximaleDosierungProAnwendung"].double
                                        restrictions["maxAmount"] = maxDosAnwendung as AnyObject?
                                    }
                                    if let notiz = (constraint["Notiz"].first) {
                                        restrictions["restriction"] = notiz.value! as AnyObject?
                                    }
                                }
                            }
                            
                        }
                        if let waitTimes = (pesticide["Karenzzeit"].all) {
                            for waitTime in waitTimes {
                                let prodLine = waitTime["Name"].value
                                let culture = waitTime["Kultur"].value
                                if (prodLine == "Agrios" && culture == "Apfel") {
                                    if (waitTime["Tage"].int != 0) {
                                        let waitTime = waitTime["Tage"].int
                                        restrictions["waitingPeriod"] = waitTime as AnyObject?
                                    }
                                }
                            }
                        }
                        let jsonData = try! JSONSerialization.data(withJSONObject: restrictions, options: .prettyPrinted)
                        if  jsonData.count > 0 {
                            
                            let jsonString = NSString (data: jsonData, encoding: String.Encoding.utf8.rawValue)!
                            jsonToStore = jsonString as String
                            //println("JSON to store: \(jsonToStore)")
                            
                        }
                        PesticideDataHelper.insert(Pesticide(id: id, code: code, productName: productName, regNumber: regNumber, defaultDose: defaultDose, constraints: jsonToStore))
                    }
                }
            }catch {
                print ("\(error)")
            }
        }
    }
    
    func importASAVer16(_ data:Data){
        var jsonToStore: String = ""
        do {
            let xmlDoc = try AEXMLDocument(xml: data)
            if let pesticides = xmlDoc.root["Pflanzenschutzmittel"].all {
                for pesticide in pesticides {
                    var wirkungen = [Wirkung]()
                    var warteFristen = [WarteFrist]()
                    jsonToStore=""
                    id = pesticide["ID"].int!
                    code = pesticide["Code"].value!
                    productName = pesticide["Name"].value!
                    regNumber = pesticide["Zulassungsnummer"].int
                    defaultDose = pesticide["DosierungProHl"].double
                    let beeRestriction = pesticide["Bienenschutz"].int
                    var restrictions = [String : AnyObject]()
                    restrictions["beeRestriction"] = beeRestriction as AnyObject?
                    if let constraints = (pesticide["Wirkung"].all) {
                        for constraint in constraints {
                            let pestReason = constraint["Wirkungsname"].value ?? "Wirkung fehlt"
                            let pestPeriod = constraint["Einsatzperiode"].value ?? "Einsatzperiode fehlt"
                            let pestPeriodCode = constraint["EinsatzperiodeCode"].value ?? "EinsatzperiodeCode fehlt"
                            let wirkung = Wirkung(maxDose: constraint["Hoechstdosierung"].double,
                                    minDose: constraint["Mindestdosierung"].double,
                                    maxUseProYear: constraint["MaximaleEinsaetzeProJahr"].int,
                                    maxAmountProUse:  constraint["MaximaleMengeProEinsatz"].double,
                                    reason: pestReason,
                                    period: pestPeriod,
                                    cultur:  constraint["WirkungKultur"].value!,
                                    periodCode: pestPeriodCode)
                            wirkungen.append(wirkung)
                        }
                        
                    }
                    if let waitTimes = (pesticide["Wartefrist"].all) {
                        for waitTime in waitTimes {
                            let warteFrist = WarteFrist(
                                waitTime: waitTime["Karenzzeit"].value!,
                                cultur: waitTime["Kultur"].value!,
                                prodType: waitTime["Anbauart"].value!,
                                beeRestriction: beeRestriction!,
                                status: waitTime["ZulStatus"].value)
                            warteFristen.append(warteFrist)
                           
                        }
                    }
                    let wirkungAndWarteFrist = PestRestrictions(wirkungen: wirkungen, warteFristen:warteFristen);
                    let encoder = JSONEncoder()
                    //encoder.outputFormatting = .prettyPrinted
                    if let jsondata = try? encoder.encode(wirkungAndWarteFrist),
                        let jsonstr = String(data: jsondata,encoding: .utf8){
                        jsonToStore = jsonstr
                        
                    }
                    
                    PesticideDataHelper.insert(Pesticide(id: id, code: code, productName: productName, regNumber: regNumber, defaultDose: defaultDose, constraints: jsonToStore))
                }
            }
        }catch {
            print ("\(error)")
        }
        
    }
    func importExcelData(_ data: Data) {
        let germanyLocale = Locale(identifier: "de_DE")
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = germanyLocale
        
        var jsonToStore: String = ""
        do {
            let xmlDoc = try AEXMLDocument(xml: data)
            if let pesticides = xmlDoc.root["pesticide"].all {
                for pesticide in pesticides {
                    var restrictions = [String : AnyObject]()
                    jsonToStore = ""
                    id = pesticide["id"].int!
                    productName = pesticide["product"].value!
                    regNumber = pesticide["regnr"].int
                    defaultDose = pesticide["dose"].double
                    let beeRestriction = pesticide["beeDanger"].int
                    restrictions["beeRestriction"] = beeRestriction as AnyObject?
                    if let wez = pesticide["wez"].first{
                       restrictions["wez"] = wez.int as AnyObject?
                    }
                    if let waitPeriod = pesticide["waitPeriod"].first{
                        restrictions["waitingPeriod"] = waitPeriod.int as AnyObject?
                    }
                    if let maxUsage = pesticide["maxUsage"].first{
                        restrictions["maxUsage"] = maxUsage.int as AnyObject?
                    }
                    if let maxAmount = pesticide["maxAmount"].first{
                        restrictions["maxAmount"] = numberFormatter.number(from: maxAmount.value!)
                    }
                    if let restriction = pesticide["restriction"].first {
                        restrictions["restriction"] = restriction.value! as AnyObject?
                    }
                    if let maxDose = pesticide["maxDose"].first{
                        restrictions["maxDose"] = Double(maxDose.int!) as AnyObject?
                    }
                    
                    
                    
                    
                    
                    
                    
                    let jsonData = try! JSONSerialization.data(withJSONObject: restrictions, options: .prettyPrinted)
                    if  jsonData.count > 0 {
                        
                            let jsonString = NSString (data: jsonData, encoding: String.Encoding.utf8.rawValue)!
                            jsonToStore = jsonString as String
                            //print("JSON to store: \(jsonToStore)")
                        
                    }
                    PesticideDataHelper.insert(Pesticide(id: id, code: code, productName: productName, regNumber: regNumber, defaultDose: defaultDose, constraints: jsonToStore))
                }
            }
        }catch {
            Util.showImportError("ExcelImport", errorMsg: "Import Error for Pesticide Data")
        }

       
    }
    
    
    
}
