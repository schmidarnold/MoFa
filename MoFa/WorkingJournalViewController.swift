//
//  WorkingJournalViewController.swift
//  MoFa
//
//  Created by Arnold Schmid on 23.06.15.
//  Copyright (c) 2015 Arnold Schmid. All rights reserved.
//

import UIKit
import SQLite
import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class WorkingJournalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, workSaveDelegate {

       @IBOutlet weak var tableView: UITableView!
    
   
    
    let dateMaker = DateFormatter()
    
    var update: Bool = false
    var works : [Work] = []
    var expandedIndexPaths = NSMutableSet()
    var detailsText = ""
    override func viewDidLoad() {
        print("[WorkingJournalViewController] calling viewDidLoad")
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "worksListCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "workCell")
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 50        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func uploadWorks(_ sender: UIBarButtonItem) {
        let numberOfWorksToSend = WorkDataHelper.countAllNotSendedAndValid()
        if (numberOfWorksToSend == 0) {
            let alertController = UIAlertController(title: "MoFa", message: "Keine Arbeiten zum Senden vorhanden!", preferredStyle: .alert)
            let closeAction = UIAlertAction(title: "Schließen", style: .default, handler: nil)
            alertController.addAction(closeAction)
            self.present(alertController, animated: true, completion:nil)
        }else {
            let alertController = UIAlertController(title: "MoFa", message: "Alle Arbeiten vom Arbeitsjournal werden gesendet! Diese sind danach im Arbeitsjournal nicht mehr vorhanden. Möchten Sie fortfahren!", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "Ja", style: .default,handler: startUpload)
            let CancelAction = UIAlertAction(title: "Nein", style: .default, handler: nil)
            alertController.addAction(OKAction)        //TODO
            alertController.addAction(CancelAction)
            self.present(alertController, animated: true, completion:nil)
 
        }
                print("upload clicked")
    }
    func startUpload(_ alert: UIAlertAction!) {
        // check internet connectivity
        let backend = Settings.getBackendSoftware()
        switch backend {
        case .asa:
            let asa16 = Settings.getUserDefaultsBoolean(keyValue: Settings.asaVer16Key)
            //check if there are pest reasons in DB
            if let record = GlobalDataHelper.getDataByTypeInfo(typeInfo: Constants.GlobalDataType.PestReasons.rawValue){
                    if record.data == nil{
                        let alertController = UIAlertController(title: "MoFa", message: "Bitte Einsatzgründe einlesen", preferredStyle: .alert)
                        let OKAction = UIAlertAction(title: "OK", style: .default,handler: { action in
                            return
                        })
                        alertController.addAction(OKAction)
                        self.present(alertController, animated: true, completion:nil)
                        
                    }
                }
                //only if we have internet connection
                if Util.connectedToNetwork() == true {
                let priority = DispatchQoS.QoSClass.default
                DispatchQueue.global(qos: priority).async {
                    
                    GenerateFile.createAsaXml(asaVer16 : asa16)
                    sleep(1)
                    DispatchQueue.main.async {
                        WorkDataHelper.setSendedToTrue()
                        self.works = WorkDataHelper.findAllNotSended()!
                        self.tableView.reloadData()
                        let alertController = UIAlertController(title: "MoFa", message: "Upload erfolgreich durchgeführt", preferredStyle: .alert)
                        let OKAction = UIAlertAction(title: "OK", style: .default,handler: nil)
                        alertController.addAction(OKAction)
                        self.present(alertController, animated: true, completion:nil)
                    }
                }
                // GenerateFile.createAsaXml()
            }else {
                let alertController = UIAlertController(title: "MoFa", message: "Keine Internetverbindung verfügbar", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default,handler: nil)
                alertController.addAction(OKAction)
                self.present(alertController, animated: true, completion:nil)
            }
            
            
        case .excel:
            if Util.connectedToNetwork() == true {
                let priority = DispatchQoS.QoSClass.default
                DispatchQueue.global(qos: priority).async {
                    
                    GenerateFile.createExcelXml()
                    sleep(1)
                    DispatchQueue.main.async {
                        WorkDataHelper.setSendedToTrue()
                        self.works = WorkDataHelper.findAllNotSended()!
                        self.tableView.reloadData()
                        let alertController = UIAlertController(title: "MoFa", message: "Upload erfolgreich durchgeführt", preferredStyle: .alert)
                        let OKAction = UIAlertAction(title: "OK", style: .default,handler: nil)
                        alertController.addAction(OKAction)
                        self.present(alertController, animated: true, completion:nil)
                    }
                }
                // GenerateFile.createAsaXml()
            }else {
                let alertController = UIAlertController(title: "MoFa", message: "Keine Internetverbindung verfügbar", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default,handler: nil)
                alertController.addAction(OKAction)
                self.present(alertController, animated: true, completion:nil)
            }
            
        }
       DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
        let worksToDelete = WorkDataHelper.getAllOldSendedNotSprayWorks()
        for work in worksToDelete {
                WorkDataHelper.deleteWorkAndAllReferencedData(work)
            }
        
        }
    }
    
    // MARK: - TableView DataSource and Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       // print ("numberofRowsInSection")
        return works.count
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print ("Row \(indexPath.row) selected")
        let curWork = works[indexPath.row]
        self.performSegue(withIdentifier: "workEditSegue", sender: curWork)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       // print ("Filling the cells")
      // let cell = tableView.dequeueReusableCellWithIdentifier("workCell", forIndexPath: indexPath) as! WorkTableViewCell
        let cell:WorkCell = tableView.dequeueReusableCell(withIdentifier: "workCell") as! WorkCell
        let curWork = works[indexPath.row]
        dateMaker.dateFormat = "dd.MM.YY"
        let curDate = ((curWork.workDate!))
        let curTask = TaskDataHelper.find(curWork.taskId!)
        let x = Date(timeIntervalSince1970: TimeInterval(curDate))
        cell.lblWorkDesc?.text = dateMaker.string(from: x) + " - " + curTask!.work!
        cell.lblWorkInfo?.text = detailsText
        if curWork.valid == false { // no valid data
            cell.backgroundColor = UIColor.red
        }else {
            cell.backgroundColor = UIColor.white
        }
        cell.showDetails = (expandedIndexPaths.contains(indexPath))
        return cell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCell.EditingStyle.delete) {
            let workItem = self.works[indexPath.row]
            self.delWorkItem(workItem)
            works.remove(at: indexPath.row)
            tableView.reloadData()
            //tableView.deleteRowsAtIndexPaths([indexPath.row], withRowAnimation: UITableViewRowAnimation.Automatic)
        }

    }
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Löschen"
    }
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        //print ("Tapped on indexpath: \(indexPath))")
        let workItem = self.works[indexPath.row]
        if self.expandedIndexPaths.contains(indexPath){ //expanded, collapse it
            self.expandedIndexPaths.remove(indexPath)
            tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        }else {
            createShowDetailsText(workItem.workId!) //calling only if we expand
            self.expandedIndexPaths.add(indexPath)
            tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        }
    }
    func delWorkItem(_ item: Work) {
        
//        WorkVQuarterDataHelper.deleteVQuartersForWork(item.workId!)
//        WorkWorkerDataHelper.deleteWorkersForWork(item.workId!)
//        if let sp = SprayingDataHelper.findSprayingForWork(item.workId!) { //removing SprayEntry
//            let sprayId = sp.id
//            SprayPesticideHelper.deletePesticidesForSpray(sprayId)
//            SprayFertilizerHelper.deleteFertilizersForSpray(sprayId)
//            SprayingDataHelper.delete(sp)
//        }
//        
//        WorkDataHelper.delete(item)
        WorkDataHelper.deleteWorkAndAllReferencedData(item)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let identifier = segue.identifier {
            switch identifier {
                case "workEditSegue":
                    //let row = tableView.indexPathForCell(sender as! UITableViewCell)!.row
                   // let x = self.works[row] as Work
                    let x = sender as! Work
                    let tabBarC : WorkTabBarController = segue.destination as! WorkTabBarController
                    let desView: WorkEditViewController = tabBarC.viewControllers?.first as! WorkEditViewController
                    print("prepare for segue: workEditSegue")
                    self.update = true
                    desView.work = x
                    tabBarC.newEntry = false
                    
                    
                    tabBarC.workDelegate = self
                
                case "workNewSegue":
                    if MultQueries.checkIfDataExists() {
                        let tabBarC : WorkTabBarController = segue.destination as! WorkTabBarController
                        //_: WorkEditViewController = tabBarC.viewControllers?.first as! WorkEditViewController
                        print ("prepare for segue: workNewSegue")
                        tabBarC.newEntry = true
                        self.update = false
                        tabBarC.workDelegate = self
                    }else {
                        let alertController = UIAlertController(title: "MoFa", message: "Keine Stammdaten vorhanden. Starten Sie im Punkt Update einen Abgleich mit LibreOffice/ASA!", preferredStyle: .alert)
                        let closeAction = UIAlertAction(title: "Schließen", style: .default, handler: nil)
                        alertController.addAction(closeAction)
                        self.present(alertController, animated: true, completion:nil)
                    }
                
                    
                
                default: break
            }
    
    }
        

    }
    
    
 
// MARK: - save delegate
    func saveWorkData(_ curWork: Work, curVquarters: Set<Int>, selectedWorkers : [Int: Double], selectedMachines : [Int: Double], spraying: Spraying?, sprayPest : [SprayPesticide]?, sprayFert: [SprayFertilizer]?, harvestEntries: [Harvest]?, soilFert: [WorkFertilizer]?, globalDat: GlobalData?) {
        print ("WorkingjournalViewController - saveWorkData")
        curWork.valid = checkValidity(curWork, curVquarters: curVquarters, selectedWorkers : selectedWorkers, selectedMachines : selectedMachines, spraying: spraying, sprayPest : sprayPest, sprayFert: sprayFert)
        let sprayId : Int?
        if (update == true) {
            WorkDataHelper.update(curWork)
            WorkVQuarterDataHelper.insertVquarters(curVquarters, workId: curWork.workId!)
            WorkWorkerDataHelper.saveWorkerDic(selectedWorkers, workId: curWork.workId!)
            WorkMachineDataHelper.saveMachineDic(selectedMachines, workId: curWork.workId!)
            if spraying != nil {
                
                if SprayingDataHelper.exists(curWork.workId!){
                    SprayingDataHelper.update(spraying!)
                    sprayId = spraying?.id
                }else {
                    sprayId = SprayingDataHelper.insert(spraying!)
                }
                if sprayPest?.count > 0 {
                    SprayPesticideHelper.insertPestArray(sprayPest!, sprayId: sprayId!)
                }
                if sprayFert?.count > 0 {
                    SprayFertilizerHelper.insertFertArray(sprayFert!, sprayId: sprayId!)
                }
            }
            if harvestEntries != nil {
                HarvestDataHelper.insertHarvestArray(harvestEntries!, currWorkId: curWork.workId!)
            }
            if soilFert != nil {
                WorkFertilizerDataHelper.insertSoilFertArray(soilFert!, currWorkId: curWork.workId!)
            }
            if globalDat != nil {
                if globalDat?.id != nil {
                    GlobalDataHelper.update(globalDat!)
                }else {
                    _ = GlobalDataHelper.insert(globalDat!) //only case if stored work, but not stored water entry
                }
                
                
            }
        }else{
            let newWorkId = WorkDataHelper.insert(curWork)
            WorkVQuarterDataHelper.insertVquarters(curVquarters, workId: newWorkId)
            WorkWorkerDataHelper.saveWorkerDic(selectedWorkers, workId: newWorkId)
            WorkMachineDataHelper.saveMachineDic(selectedMachines, workId: newWorkId)
            if spraying != nil {
                spraying?.work_id = newWorkId
                sprayId = SprayingDataHelper.insert(spraying!)
                if sprayPest?.count > 0 {
                    SprayPesticideHelper.insertPestArray(sprayPest!, sprayId: sprayId!)
                }
                if sprayFert?.count > 0 {
                    SprayFertilizerHelper.insertFertArray(sprayFert!, sprayId: sprayId!)
                }
                setLastConcValue((spraying?.concentration)!)
            }
            if harvestEntries != nil {
                HarvestDataHelper.insertHarvestArray(harvestEntries!, currWorkId: newWorkId)
            }
            if soilFert != nil {
               WorkFertilizerDataHelper.insertSoilFertArray(soilFert!, currWorkId: newWorkId)
            }
            if globalDat != nil {
                globalDat!.workId = newWorkId
                _ = GlobalDataHelper.insert(globalDat!)
            }
        }
        works = WorkDataHelper.findAllNotSended()!
        tableView.reloadData()
        setLastTaskId(curWork.taskId!) //saving last taskId in nsuserdefaults
    }
    func checkValidity(_ curWork: Work, curVquarters: Set<Int>, selectedWorkers : [Int: Double], selectedMachines : [Int: Double], spraying: Spraying?, sprayPest : [SprayPesticide]?, sprayFert: [SprayFertilizer]?) -> Bool {
        var valid = true
        if curVquarters.count == 0 || selectedWorkers.count == 0 {
            valid = false
        }
        if spraying != nil {
            if sprayPest == nil && sprayFert == nil {
                valid = false
            }
            if sprayPest?.count == 0 && sprayFert?.count == 0 {
                valid = false
            }
        }
        print ("check of Data: \(valid)")
    return valid
    }
    
    func createShowDetailsText(_ workId: Int) {
        var vqStr = ""
        var workerStr = ""
        
        let vqSet = WorkVQuarterDataHelper.getWorkVQuarter(workId)
        let vquartersFromSet = VQuarterDataHelper.findSelectedVquarters(vqSet)
        for vq in vquartersFromSet!  {
            let land = LandDataHelper.find(vq.landId!)
            vqStr = vqStr + "\(land!.name!) \(vq.name!),"
        }
        let subString = vqStr[..<vqStr.index(before: vqStr.endIndex)]
        vqStr = String(subString)
        let workerDic = WorkWorkerDataHelper.findWorkerForWorkDictionary(workId)
        var counter = 1
        for (id,hours) in workerDic! {
            let worker = WorkerDataHelper.find(id)
            workerStr = workerStr + "- \(worker!.lastName)  \(worker!.firstName!)  \(hours)"
            if counter < workerDic!.count {
                workerStr = workerStr + "\n"
            }
            counter += 1
        }
        detailsText = vqStr + "\n" + workerStr
        if SprayingDataHelper.exists(workId) {
            let concDesc = "Konz.: "
            let hlDesc  = "hl: "
            let sprayEntry = SprayingDataHelper.findSprayingForWork(workId)
            let strHl = sprayEntry!.wateramount!.description
            let strConc = sprayEntry!.concentration.description
            var sprayStr = "\n \(concDesc) \(strConc)x \(hlDesc) \(strHl)"
            if let sprayPest = SprayPesticideHelper.findPestForSpray(sprayEntry!.id) {
                for p in sprayPest {
                    let pestId = p.prod_id
                    let prodName = PesticideDataHelper.findProdNameForId(pestId)
                    let pestOutput = "- \(prodName) Dosis: \(p.dose) Menge: \(p.doseAmount) "
                    sprayStr = sprayStr + "\n \(pestOutput) "
                }
            }
            if let sprayFert = SprayFertilizerHelper.findFertForSpray(sprayEntry!.id) {
                for f in sprayFert {
                    let fertId = f.prod_id
                    let prodName = FertilizerDataHelper.findProdNameForId(fertId)
                    let fertOutput = "- \(prodName) Dosis: \(f.dose) Menge: \(f.doseAmount) "
                    sprayStr = sprayStr + "\n \(fertOutput) "
                }
            }
            
            
            
            detailsText = detailsText + sprayStr
            
           // detailsText = detailsText + "\n \(sprayStr)"
        }
        if HarvestDataHelper.exists(workId){
            var harvestStr = ""
            if let harEntries = HarvestDataHelper.findWorkIdOrdered(workId) {
                for h in harEntries {
                    harvestStr += "-Liefernr: \(h.id!), Menge: \(h.amount!), \(CategoryDataHelper.getQuality(h.categoryId!))\n"
                }
            }
            detailsText = detailsText + "\n\(harvestStr)"
        }
        
        
    
    }
    func setLastTaskId (_ taskId:Int){
        UserDefaults.standard.set(taskId, forKey: "lastTaskId");
    }
    func setLastConcValue (_ concValue:Double){
        UserDefaults.standard.set(concValue, forKey: "lastConcValue")
    }
    
}
