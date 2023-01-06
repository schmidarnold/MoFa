//
//  GenerateFile.swift
//  MoFa
//
//  Created by Arnold Schmid on 14.09.15.
//  Copyright (c) 2015 Arnold Schmid. All rights reserved.
//

import Foundation
import AEXML
class GenerateFile {
    static let exportDropboxPath = "/MoFaBackend/export/"
    static let asaNote = "(MoFa)"
    static func createAsaXml(asaVer16:Bool) {
        var pestReasons = [Einsatzgrund]()
        if (asaVer16){
            if let record = GlobalDataHelper.getDataByTypeInfo(typeInfo: Constants.GlobalDataType.PestReasons.rawValue){
                if let jsonStr = record.data {
                    
                    let decoder = JSONDecoder()
                    
                    if let jsonData = jsonStr.data(using: .utf8),
                        let reasons = try? decoder.decode([Einsatzgrund].self, from:jsonData){
                            pestReasons = reasons
                        
                    }
                    
                }
            }
            
        }
        let dateMaker = DateFormatter()
        dateMaker.dateFormat = "yyyy-MM-dd"
        var workType : String?
        var sprayHeader : AEXMLElement
        if let workArray = WorkDataHelper.findAllNotSendedAndValid() {
            let xmlDoc = AEXMLDocument()
            let arbeitseintraege = xmlDoc.addChild(name: "Arbeitseintraege")
            for w in workArray {
                let arbeitseintrag = arbeitseintraege.addChild(name: "Arbeitseintrag")
                let x = Date(timeIntervalSince1970: TimeInterval(w.workDate!))
                let curDate = (x)
                arbeitseintrag.addChild(name: "Datum", value: dateMaker.string(from: curDate))
                let arbeit = arbeitseintrag.addChild (name: "Arbeit")
                arbeit.addChild(name: "Code", value: TaskDataHelper.findCodeForId(w.taskId!))
                let notiz = w.note
                if Settings.getUserDefaultsBoolean(keyValue: Settings.asaNoteKey) {
                    if notiz != nil {
                        arbeitseintrag.addChild(name: "Notiz", value: "\(asaNote) + \(w.note ?? "")")
                    }else{
                        arbeitseintrag.addChild(name: "Notiz", value: "\(asaNote)")
                    }
                    
                }else{
                    if notiz != nil {
                        arbeitseintrag.addChild(name: "Notiz", value: w.note)
                    }
                    
                }
                
                if let workersOfWork = WorkWorkerDataHelper.findWorkerForWork(w.workId!) {
                    for workers in workersOfWork {
                        let arbeitskraft = arbeitseintrag.addChild(name: "Arbeitskraft")
                        let arbeitsperson = arbeitskraft.addChild(name: "Arbeitskraft")
                        arbeitsperson.addChild(name: "Code", value: WorkerDataHelper.findCodeForId(workers.worker_id))
                        arbeitskraft.addChild(name: "Stunden", value: workers.hours.description)
                        
                    }
                }
                if let machinesOfWork = WorkMachineDataHelper.findMachineForWork(w.workId!) {
                    for machines in machinesOfWork {
                        let machine = arbeitseintrag.addChild(name: "Maschine")
                        let machinemachine = machine.addChild(name: "Maschine")
                        machinemachine.addChild(name: "Code", value: MachineDataHelper.findCodeForId(machines.machine_id))
                        machine.addChild(name: "Stunden", value: machines.hours.description)
                        
                    }
                }
                let vquartersSetOfWork = WorkVQuarterDataHelper.getWorkVQuarter(w.workId!)
                for vqId in vquartersSetOfWork {
                    let vq = arbeitseintrag.addChild(name: "Sortenquartier")
                    let vqItem = vq.addChild(name: "Sortenquartier")
                    vqItem.addChild(name: "Code", value: VQuarterDataHelper.findCodeForId(vqId))
                }
                
                
                workType = TaskDataHelper.findTypeForId(w.taskId!)
                if workType != nil {
                    if workType == "S" || workType == "H" {
                        let spraying = SprayingDataHelper.findSprayingForWork(w.workId!)
                        let witterung = arbeitseintrag.addChild(name: "Witterungsverhaeltnis")
                        witterung.addChild(name:"Code", value: weatherCodeAsa(value:(spraying?.weather)!) )
                        if workType == "S" {
                            sprayHeader = arbeitseintrag.addChild(name:"Spritzung")
                        }else{
                            sprayHeader = arbeitseintrag.addChild(name: "Herbizideinsatz")
                        }
                        
                        
                        
                        sprayHeader.addChild(name : "Konzentration", value: spraying?.concentration.description)
                        sprayHeader.addChild(name: "Wassermenge", value: spraying?.wateramount?.description)
                        let weatherStr = weatherString((spraying?.weather)!)
                        sprayHeader.addChild(name: "Notiz", value: weatherStr)
                        for vqId in vquartersSetOfWork {
                            let vq = sprayHeader.addChild(name: "Sortenquartier")
                            let vqItem = vq.addChild(name: "Sortenquartier")
                            vqItem.addChild(name: "Code", value: VQuarterDataHelper.findCodeForId(vqId))
                        }
                        if let pesticidesOfSpraying = SprayPesticideHelper.findPestForSpray(spraying!.id) {
                            for pest in pesticidesOfSpraying {
                                let spritzBez = asaVer16 ? "Pflanzenschutzmittel" : "Spritzmittel"
                                let spMittel = sprayHeader.addChild(name: spritzBez)
                                let artikel = spMittel.addChild(name: "Artikel")
                                let pestCode = PesticideDataHelper.findCodeForId (pest.prod_id)
                                artikel.addChild(name: "Code", value: pestCode)
                                spMittel.addChild(name: "Menge", value: pest.doseAmount.description)
                                spMittel.addChild(name: "MengeProHl1Mal", value: pest.dose.description)
                                if (asaVer16){
                                    let periode = spMittel.addChild(name:"Einsatzperiode")
                                    periode.addChild(name:"Code", value: pest.periodCode!)
                                    spMittel.addChild(name:"EinsatzgruendeAlsString", value: splitReasonForASA(reason: pest.reason!))
                                    let einsatzGrund = spMittel.addChild(name:"Einsatzgrund")
                                    let einsatzGrundChild = einsatzGrund.addChild(name:"Einsatzgrund")
                                    
                                    
                                    if let grund = pestReasons.first(where: {$0.name == splitReasonForASA(reason: pest.reason!)}){
                                        einsatzGrundChild.addChild(name:"Code", value:grund.code)
                                        print (grund.code)
                                            }else{
                                        einsatzGrundChild.addChild(name:"Code", value:"Einsatzgrund nicht vorhanden")
                                        }
                                    
                                }
                            }
                        }
                        if let fertilizersOfSpraying = SprayFertilizerHelper.findFertForSpray(spraying!.id) {
                            for fert in fertilizersOfSpraying {
                                let spMittel = sprayHeader.addChild(name: "Blattduenger")
                                let artikel = spMittel.addChild(name: "Artikel")
                                let fertCode = FertilizerDataHelper.findCodeForId (fert.prod_id)
                                artikel.addChild(name: "Code", value: fertCode)
                                spMittel.addChild(name: "Menge", value: fert.doseAmount.description)
                                spMittel.addChild(name: "MengeProHl1Mal", value: fert.dose.description)
                            }
                        }
                    }
                    if workType == "E" {
                        if let harvest = HarvestDataHelper.findWorkIdOrdered(w.workId!){
                            for h in harvest{
                                let ernte = arbeitseintrag.addChild(name: "Ernteeintrag")
                                let x = Date(timeIntervalSince1970: TimeInterval(h.date!))
                                let curDate = (x)
                                ernte.addChild(name: "Datum", value: dateMaker.string(from: curDate))
                                ernte.addChild(name: "LieferscheinNummer", value: h.id?.description)
                                ernte.addChild(name: "Menge", value: h.amount?.description)
                                ernte.addChild(name: "Durchgang", value: h.turn.description)
                                let kategorie = ernte.addChild(name: "Kategorie")
                                let katCode = CategoryDataHelper.getCode(h.categoryId!)
                                kategorie.addChild(name: "Code", value: katCode)
                                ernte.addChild(name: "Kisten", value: h.boxes?.description)
                                ernte.addChild(name: "Zucker", value: h.sugar?.description)
                                ernte.addChild(name: "Saeure", value: h.acid?.description)
                                ernte.addChild(name: "Phenole", value: h.phenol?.description)
                                ernte.addChild(name: "PHWert", value: h.ph?.description)
                                ernte.addChild(name: "Notiz", value: h.note)
                                for vqId in vquartersSetOfWork {
                                    let vq = ernte.addChild(name: "Sortenquartier")
                                    let vqItem = vq.addChild(name: "Sortenquartier")
                                    vqItem.addChild(name: "Code", value: VQuarterDataHelper.findCodeForId(vqId))
                                }
                            }
                        }
                    }
                    if workType == "D"{
                        if let duengen = WorkFertilizerDataHelper.findFertilizerForWorkId(w.workId!){
                            for d in duengen{
                                let duengenEntry = arbeitseintrag.addChild(name:"Duengung")
                                for vqId in vquartersSetOfWork {
                                    let vq = duengenEntry.addChild(name: "Sortenquartier")
                                    let vqItem = vq.addChild(name: "Sortenquartier")
                                    vqItem.addChild(name: "Code", value: VQuarterDataHelper.findCodeForId(vqId))
                                }
                                let duengMittel = duengenEntry.addChild(name: "Duengemittel")
                                let artikel = duengMittel.addChild(name: "Artikel")
                                artikel.addChild(name: "Code", value: SoilFertilizerDataHelper.findCodeForId(d.soilFertId))
                                duengMittel.addChild(name: "Menge", value: d.amount.description)
                                
                            }
                        }
                    }
                    if workType == "B" {
                        if let waterData = GlobalDataHelper.getWaterDataForWorkId(w.workId!){
                            let waterEntry = arbeitseintrag.addChild(name: "Bewaesserung")
                            let waterJson = GlobalDataHelper.getWaterData(waterData.id!)
                            waterEntry.addChild(name: "Dauer", value: waterJson.irrDuration!.description)
                            waterEntry.addChild(name: "MengeRelativ", value: waterJson.irrTotale!.description)
                            waterEntry.addChild(name: "MengeProStunde", value: waterJson.irrAmount!.description)
                            waterEntry.addChild(name: "Art", value: waterJson.irrType?.description)
                            for vqId in vquartersSetOfWork {
                                let vq = waterEntry.addChild(name: "Sortenquartier")
                                let vqItem = vq.addChild(name: "Sortenquartier")
                                vqItem.addChild(name: "Code", value: VQuarterDataHelper.findCodeForId(vqId))
                            }
                        }
                    }
                    
                }
                
            }
            let fileName =  exportDropboxPath + generateFileName()
            
            let file = xmlDoc.xml.data(using: String.Encoding.utf8)
            _ = DropboxSyncService.saveFile(fileName,data: file!)
            //let dropboxSyncService = DropboxSyncService()
           // dropboxSyncService.saveFile(fileName, data: file!)
        }
        
        
        
    }
    static func createExcelXml() {
        let dateMaker = DateFormatter()
        dateMaker.dateFormat = "yyyy-MM-dd"
        var workType : String?
        var sprayHeader : AEXMLElement
        if let workArray = WorkDataHelper.findAllNotSendedAndValid() {
            let xmlDoc = AEXMLDocument()
            let arbeitseintraege = xmlDoc.addChild(name: "works")
            for w in workArray {
                let arbeitseintrag = arbeitseintraege.addChild(name: "work")
                let x = Date(timeIntervalSince1970: TimeInterval(w.workDate!))
                let curDate = (x)
                arbeitseintrag.addChild(name: "date", value: dateMaker.string(from: curDate))
                arbeitseintrag.addChild(name: "task", value: w.taskId!.description)
                workType = TaskDataHelper.findTypeForId(w.taskId!)
                if workType != nil {
                    if workType == "S" || workType == "H" || workType == "E" || workType == "D" || workType == "B"{
                        arbeitseintrag.addChild(name: "type", value: TaskDataHelper.findTypeForId(w.taskId!))
                    }else{
                        arbeitseintrag.addChild(name: "type", value: "O") //O for other, needed for LibreOffice
                    }
                }
                arbeitseintrag.addChild(name: "note", value: w.note)
                let vquartersSetOfWork = WorkVQuarterDataHelper.getWorkVQuarter(w.workId!)
                for vqId in vquartersSetOfWork {
                    let vq = arbeitseintrag.addChild(name: "vquarter")
                    vq.addChild(name: "vqid", value: vqId.description)
                }
                if let workersOfWork = WorkWorkerDataHelper.findWorkerForWork(w.workId!) {
                    for workers in workersOfWork {
                        let arbeitskraft = arbeitseintrag.addChild(name: "worker")
                        arbeitskraft.addChild(name: "workerid", value: workers.worker_id.description)
                        arbeitskraft.addChild(name: "workerhours", value: workers.hours.description)
                        
                    }
                }
                if let machinesOfWork = WorkMachineDataHelper.findMachineForWork(w.workId!) {
                    for machines in machinesOfWork {
                        let machine = arbeitseintrag.addChild(name: "machine")
                        machine.addChild(name: "machineid", value: machines.machine_id.description)
                        machine.addChild(name: "machinehours", value: machines.hours.description)
                        
                    }
                }
                
                workType = TaskDataHelper.findTypeForId(w.taskId!)
                if workType != nil {
                    if workType == "S" || workType == "H" {
                        sprayHeader = arbeitseintrag.addChild(name:"spraying")
                        
                        
                        let spraying = SprayingDataHelper.findSprayingForWork(w.workId!)
                        sprayHeader.addChild(name : "concentration", value: spraying?.concentration.description)
                        sprayHeader.addChild(name: "wateramount", value: spraying?.wateramount?.description)
                        let weatherStr = weatherString((spraying?.weather)!)
                        sprayHeader.addChild(name: "weather", value: weatherStr)
                        if let pesticidesOfSpraying = SprayPesticideHelper.findPestForSpray(spraying!.id) {
                            for pest in pesticidesOfSpraying {
                                let spMittel = sprayHeader.addChild(name: "Pesticide")
                                spMittel.addChild(name: "pestid", value: pest.prod_id.description)
                                spMittel.addChild(name: "dose", value: pest.dose.description)
                                spMittel.addChild(name: "amount", value: pest.doseAmount.description)
                            }
                        }
                        if let fertilizersOfSpraying = SprayFertilizerHelper.findFertForSpray(spraying!.id) {
                            for fert in fertilizersOfSpraying {
                                let spMittel = sprayHeader.addChild(name: "Fertilizer")
                                spMittel.addChild(name: "fertid", value: fert.prod_id.description)
                                spMittel.addChild(name: "dose", value: fert.dose.description)
                                spMittel.addChild(name: "amount", value: fert.doseAmount.description)
                            }
                        }
                    }
                    if workType == "E" {
                        if let harvest = HarvestDataHelper.findWorkIdOrdered(w.workId!){
                            for h in harvest{
                                let harvestEntry = arbeitseintrag.addChild(name:"harvest")
                                let x = Date(timeIntervalSince1970: TimeInterval(h.date!))
                                let curDate = (x)
                                harvestEntry.addChild(name: "Datum", value: dateMaker.string(from: curDate))
                                harvestEntry.addChild(name: "LieferscheinNummer", value: h.id?.description)
                                harvestEntry.addChild(name: "Menge", value: h.amount?.description)
                                harvestEntry.addChild(name: "Durchgang", value: h.turn.description)
                                harvestEntry.addChild(name: "Kategorie", value: CategoryDataHelper.getQuality(h.categoryId!))
                                harvestEntry.addChild(name: "Kisten", value: h.boxes?.description)
                                harvestEntry.addChild(name: "Zucker", value: h.sugar?.description)
                                harvestEntry.addChild(name: "Saeure", value: h.acid?.description)
                                harvestEntry.addChild(name: "Phenole", value: h.phenol?.description)
                                harvestEntry.addChild(name: "PHWert", value: h.ph?.description)
                                if h.note != nil {
                                    harvestEntry.addChild(name: "Notiz", value: h.note)
                                }
                                
                                
                            }
                        }
                    }
                    if workType == "D"{
                        if let duengen = WorkFertilizerDataHelper.findFertilizerForWorkId(w.workId!){
                            for d in duengen{
                                let duengenEntry = arbeitseintrag.addChild(name:"soilfertilizer")
                                duengenEntry.addChild(name:"soilfertilizerid", value: d.soilFertId.description)
                                duengenEntry.addChild(name:"soilfertamount", value: d.amount.description)
                            }
                        }
                    }
                    if workType == "B" {
                        if let waterData = GlobalDataHelper.getWaterDataForWorkId(w.workId!){
                            let waterEntry = arbeitseintrag.addChild(name: "irrigation")
                            let waterJson = GlobalDataHelper.getWaterData(waterData.id!)
                            waterEntry.addChild(name: "irrduration", value: waterJson.irrDuration!.description)
                            waterEntry.addChild(name: "irramount", value: waterJson.irrAmount!.description)
                            waterEntry.addChild(name: "irrtotale", value: waterJson.irrAmount!.description)
                            waterEntry.addChild(name: "irrtype", value: waterJson.irrType?.description)
                            
                        }
                    }
                    
                }
                
            }
            let fileName =  exportDropboxPath + generateFileName()
            let file = xmlDoc.xml.data(using: String.Encoding.utf8)
            _ = DropboxSyncService.saveFile(fileName, data: file!)
            }

    }
    static func createPurchaseASAXml() {
        let dateMaker = DateFormatter()
        dateMaker.dateFormat = "yyyy-MM-dd"
        if let purArray = PurchaseDataHelper.findAll() {
            let xmlDoc = AEXMLDocument()
            let purEntries = xmlDoc.addChild(name: "Lagereingaenge")
            for p in purArray {
                let purEntry = purEntries.addChild(name: "Lagereingang")
                let x = Date(timeIntervalSince1970: TimeInterval(p.date))
                let curDate = (x)
                purEntry.addChild(name: "Datum", value: dateMaker.string(from: curDate))
                let pestOfPurchase = PurchasePestDataHelper.findPestForPurchase(p.id)
                for pest in pestOfPurchase! {
                    let stockEntry = purEntry.addChild(name: "Lagereingangsposition")
                    let pestEntry = stockEntry.addChild(name:"Spritzmittel")
                    let pestCode = PesticideDataHelper.findCodeForId (pest.pest_id)

                    pestEntry.addChild(name:"Code", value: pestCode)
                    stockEntry.addChild(name:"Menge", value: pest.amount.description)
                }
                let fertOfPurchase = PurchaseFertDataHelper.findPestForPurchase(p.id)
                for fert in fertOfPurchase! {
                    let stockEntry = purEntry.addChild(name: "Lagereingangsposition")
                    let fertEntry = stockEntry.addChild(name:"Duengemittel")
                    let fertCode = FertilizerDataHelper.findCodeForId (fert.fert_id)
                    fertEntry.addChild(name:"Code", value: fertCode)
                    stockEntry.addChild(name:"Menge", value: fert.amount.description)
                }
            }
            let fileName =  exportDropboxPath + generatePurchaseFileName()
            let file = xmlDoc.xml.data(using: String.Encoding.utf8)
            _ = DropboxSyncService.saveFile(fileName, data: file!)
            
        }
        
    }

    static func createPurchaseExcelXml() {
        let dateMaker = DateFormatter()
        dateMaker.dateFormat = "yyyy-MM-dd"
        if let purArray = PurchaseDataHelper.findAll() {
            let xmlDoc = AEXMLDocument()
            let purEntries = xmlDoc.addChild(name: "purchases")
            for p in purArray {
                let purEntry = purEntries.addChild(name: "purchase")
                let x = Date(timeIntervalSince1970: TimeInterval(p.date))
                let curDate = (x)
                purEntry.addChild(name: "date", value: dateMaker.string(from: curDate))
                let pestOfPurchase = PurchasePestDataHelper.findPestForPurchase(p.id)
                for pest in pestOfPurchase! {
                    let pestEntry = purEntry.addChild(name:"pesticide")
                    pestEntry.addChild(name:"pestid", value: pest.pest_id.description)
                    pestEntry.addChild(name:"amount", value: pest.amount.description)
                }
                let fertOfPurchase = PurchaseFertDataHelper.findPestForPurchase(p.id)
                for fert in fertOfPurchase! {
                    let fertEntry = purEntry.addChild(name:"fertilizer")
                    fertEntry.addChild(name:"fertid", value: fert.fert_id.description)
                    fertEntry.addChild(name:"amount", value: fert.amount.description)
                }
            }
            let fileName =  exportDropboxPath + generatePurchaseFileName()
            let file = xmlDoc.xml.data(using: String.Encoding.utf8)
            _ = DropboxSyncService.saveFile(fileName, data: file!)
        }
        
    }
    static func createVegDataExcelXml(){
        var dicOfBlossomStart = [String:String]()
        var dicOfBlossomEnd = [String:String]()
        var dicOfHarvestStart = [String:String]()
        var dicOfCropAmount = [String:String]()
        if let blossStart = GlobalDataHelper.getDataByTypeInfo(typeInfo: Constants.GlobalDataType.BlossomStart.rawValue) {
                if let jsonData = blossStart.data {
                    dicOfBlossomStart = getDicFromJson(jsonString: jsonData)
                }
            }
        if let blossEnd = GlobalDataHelper.getDataByTypeInfo(typeInfo: Constants.GlobalDataType.BlossomEnd.rawValue) {
                if let jsonData = blossEnd.data {
                    dicOfBlossomEnd = getDicFromJson(jsonString: jsonData)
                }
            }
        if let harvestStart = GlobalDataHelper.getDataByTypeInfo(typeInfo: Constants.GlobalDataType.HarvestStart.rawValue){
                if let jsonData = harvestStart.data {
                    dicOfHarvestStart = getDicFromJson(jsonString: jsonData)
                }
            }
        if let cropAmount = GlobalDataHelper.getDataByTypeInfo(typeInfo: Constants.GlobalDataType.CropAmount.rawValue){
                if let jsonData = cropAmount.data {
                    dicOfCropAmount = getDicFromJson(jsonString: jsonData)
                }
        }
        let vquarters = VQuarterDataHelper.findAll()
        let xmlDoc = AEXMLDocument()
        let vegVquarters = xmlDoc.addChild(name: "vquarters")
        for vq in vquarters! {
           
            let blossStart = dicOfBlossomStart[(vq.id?.description)!]
            let blossEnd = dicOfBlossomEnd[(vq.id?.description)!]
            let harvestStart = dicOfHarvestStart[(vq.id?.description)!]
            let cropAmount = dicOfCropAmount[(vq.id?.description)!]
            if blossStart != nil || blossEnd != nil || harvestStart != nil || cropAmount != nil {
                let vquarter = vegVquarters.addChild(name: "vquarter")
                vquarter.addChild(name:"vqid",value:vq.id?.description)
                if blossStart != nil {
                    vquarter.addChild(name:"blossomStart",value: String(blossStart!.prefix(5))) //only first 5 chars, not the year for libreoffice
                }
                if blossEnd != nil {
                    vquarter.addChild(name:"blossomEnd", value: String(blossEnd!.prefix(5)))
                }
                if harvestStart != nil {
                    vquarter.addChild(name:"harvestStart", value:String(harvestStart!.prefix(5)))
                }
                if cropAmount != nil {
                    vquarter.addChild(name:"cropAmount", value:cropAmount)
                }
                
            }
            
            
        }
        let fileName =  exportDropboxPath + generateVegDataFileName()
        let file = xmlDoc.xml.data(using: String.Encoding.utf8)
        _ = DropboxSyncService.saveFile(fileName, data: file!)
    
    }
    static func createVegDataAsaXml(){
        let curDate = Date()
        let calendar = NSCalendar.current
        let components = calendar.dateComponents([.year], from: curDate)
        let curYear = components.year
        
        var dicOfBlossomStart = [String:String]()
        var dicOfBlossomEnd = [String:String]()
        var dicOfHarvestStart = [String:String]()
        var dicOfCropAmount = [String:String]()
        if let blossStart = GlobalDataHelper.getDataByTypeInfo(typeInfo: Constants.GlobalDataType.BlossomStart.rawValue) {
            if let jsonData = blossStart.data {
                dicOfBlossomStart = getDicFromJson(jsonString: jsonData)
            }
        }
        if let blossEnd = GlobalDataHelper.getDataByTypeInfo(typeInfo: Constants.GlobalDataType.BlossomEnd.rawValue) {
            if let jsonData = blossEnd.data {
                dicOfBlossomEnd = getDicFromJson(jsonString: jsonData)
            }
        }
        if let harvestStart = GlobalDataHelper.getDataByTypeInfo(typeInfo: Constants.GlobalDataType.HarvestStart.rawValue){
            if let jsonData = harvestStart.data {
                dicOfHarvestStart = getDicFromJson(jsonString: jsonData)
            }
        }
        if let cropAmount = GlobalDataHelper.getDataByTypeInfo(typeInfo: Constants.GlobalDataType.CropAmount.rawValue){
            if let jsonData = cropAmount.data {
                dicOfCropAmount = getDicFromJson(jsonString: jsonData)
            }
        }
        let vquarters = VQuarterDataHelper.findAll()
        let xmlDoc = AEXMLDocument()
        let vegVquarters = xmlDoc.addChild(name: "Sortenquartiere")
        for vq in vquarters! {
            
            let blossStart = dicOfBlossomStart[(vq.id?.description)!]
            let blossEnd = dicOfBlossomEnd[(vq.id?.description)!]
            let harvestStart = dicOfHarvestStart[(vq.id?.description)!]
            let cropAmount = dicOfCropAmount[(vq.id?.description)!]
            if blossStart != nil || blossEnd != nil || harvestStart != nil || cropAmount != nil {
                let vquarter = vegVquarters.addChild(name: "Sortenquartier")
                vquarter.addChild(name:"Code",value:vq.code!.description)
                let jahresDaten = vquarter.addChild(name:"Jahresdaten")
                jahresDaten.addChild(name:"Erntejahr", value:curYear!.description)
                if blossStart != nil {
                    jahresDaten.addChild(name:"Bluehbeginn",value: getAsaDateFromStringDate(curValue: blossStart!))                 }
                if blossEnd != nil {
                    jahresDaten.addChild(name:"Bluehende", value: getAsaDateFromStringDate(curValue:blossEnd!))
                }
                if harvestStart != nil {
                    jahresDaten.addChild(name:"Erntebeginn", value:getAsaDateFromStringDate(curValue:harvestStart!))
                }
                if cropAmount != nil {
                    jahresDaten.addChild(name:"ErnteschaetzungProHa", value:getKiloFromAmount(amount: cropAmount!))
                }
                
            }
            
            
        }
        let fileName =  exportDropboxPath + generateVegDataFileName()
        let file = xmlDoc.xml.data(using: String.Encoding.utf8)
        _ = DropboxSyncService.saveFile(fileName, data: file!)
    }
    static func getKiloFromAmount(amount: String) -> String {
        let amountInTon = Int (amount)
        let amountInKilo = amountInTon! * 1000
        return String (amountInKilo)
    }
    static func getAsaDateFromStringDate(curValue: String) -> String {
        let splitArray = curValue.components(separatedBy: ".")
        let modifiedDate = splitArray[2] + "-" + splitArray[1] + "-" + splitArray[0]
        return modifiedDate
        
    }
    static func getDicFromJson (jsonString: String) -> [String:String] {
        
        let emptyDic = [String:String]()
        if let data = jsonString.data(using: .utf8){
            do{
                let decoded = try JSONSerialization.jsonObject(with: data, options: [])
                if let dictFromJSON = decoded as? [String:String] {
                    return dictFromJSON
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        return emptyDic
    }

    static func generateFileName()-> String {
        let dateMaker = DateFormatter()
        dateMaker.dateFormat = "yyyy-MM-dd-hh-mm-ss"
        let date = Date()
        let strDate = dateMaker.string(from: date)
        return "worklist" + strDate + ".xml"
    }
    static func generatePurchaseFileName()-> String {
        let dateMaker = DateFormatter()
        dateMaker.dateFormat = "yyyy-MM-dd-hh-mm-ss"
        let date = Date()
        let strDate = dateMaker.string(from: date)
        return "purchaselist" + strDate + ".xml"
    }
    static func generateVegDataFileName() -> String {
        let dateMaker = DateFormatter()
        dateMaker.dateFormat = "yyyy-MM-dd-hh-mm-ss"
        let date = Date()
        let strDate = dateMaker.string(from: date)
        return "vegdata" + strDate + ".xml"
    }
    static func weatherString(_ value: Int) -> String {
        
        let curWeather = Constants.Weather(rawValue: value)
        switch curWeather! {
            case .sunny:
                return "Wetter: schön"
        case .partCloudy:
                return "Wetter: Leicht bewölkt"
        case .cloudy:
                return "Wetter: bewölkt"
        case .rainLight:
                return "Wetter: leichter Regen"
        case .rainHeavy:
                return "Wetter: Regen"
        case .night:
            return "Nacht"
        
        }
    }
    static func weatherCodeAsa (value: Int) -> String{
        return "0" + value.description
        
    }
    
    
    static func splitReasonForASA(reason:String)-> String{
        let strArray = reason.components(separatedBy: ",")
        return strArray[0]
    }
    
}
