//
//  StartViewController.swift
//  MoFa
//
//  Created by Arnold Schmid on 24.04.15.
//  Copyright (c) 2015 Arnold Schmid. All rights reserved.
//

import UIKit
import SwiftyDropbox
class StartViewController: UIViewController, UIPopoverPresentationControllerDelegate, ImportDataDelegate {
    let viewTitle:String = "MoFa"
    var listOfUpdateFiles = [String:String]()
    let updateArray : [String] = ["land","vquarter","machine","worker","task","pesticide","fertilizer","category","soilfertilizer","extra","reason"]
    let updateArrayDE : [String:String] = ["land":"Anlagen", "vquarter":"Sortenquartiere" , "machine":"Maschinen","worker":"Arbeiter", "task":"Tätigkeiten" , "pesticide":"Spritzmittel","fertilizer":"Blattdünger","category":"Erntekategorien","soilfertilizer":"Bodendünger","extra":"extra","reason":"Einsatzgründe"]
    let progressView = UIProgressView(progressViewStyle: .bar)
    var progressLabel : UILabel!
    var turn = 0
    
    var counter:Int = 0 {
        didSet {
                turn += 1
                let fractionalProgress = Float(self.counter) / 100.0
                let animated = self.counter != 0
                self.progressView.setProgress(fractionalProgress, animated: animated)
                self.progressLabel.text = ("\(self.counter)%")
            if turn == listOfUpdateFiles.count {
                  counter = 0
                  progressView.removeFromSuperview()
                  progressLabel.removeFromSuperview()
            }
            
            
        }
    }
    
    override func viewDidLoad() {
        
         super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        
        if Settings.getBackendSoftware() == Settings.BackendSoftware.asa {
            self.title = "\(viewTitle) - ASA"
        }else{
            self.title = "\(viewTitle) - Excel"
        }
        var image = UIImage(named: "infoBlue")
        image = image?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        _ = self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: UIBarButtonItem.Style.plain, target: self, action: #selector(StartViewController.showInfo))
    
    }
    @objc func showInfo(){
        print("show info controller")
        self.performSegue(withIdentifier: "infoSegue", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
                case "workListSegue":
                    if let vc = segue.destination as? WorkingJournalViewController {
                        print("prepare for segue: workListSegue")
                        vc.works = WorkDataHelper.findAllNotSended()!
                    }
                case "purchaseSegue":
                    if let vc = segue.destination as? PurchaseViewController {
                        vc.title = "Einkauf Spritz/Düngemittel"
                }
                case "searchSegue":
                    if let vc = segue.destination as? SearchViewController {
                        vc.title = "Suche Einträge"
                }                default: break
            }
    
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBAction func updateButtonClicked(_ sender: UIButton) {
        var outputString = String()
        
        if let client = DropboxClientsManager.authorizedClient {
            spinner?.startAnimating()
            DropboxSyncService.hasUpdates(client, fileList: updateArray) { [unowned me = self]result in
                me.listOfUpdateFiles = result
                // listOfUpdateFiles =  DropboxSyncService.hasUpdateFile(client, fileList: updateArray)
                if me.listOfUpdateFiles.count > 0 { //containing at least one file to import
                    self.spinner?.stopAnimating()
                    for myKey in me.listOfUpdateFiles.keys {
                        outputString += me.updateArrayDE[myKey]! + "\n"
                    }
                    
                }else { //no file to import
                    self.spinner?.stopAnimating()
                    outputString = "Keine Updates verfügbar"
                }
                
                me.showUpdatePopOver(outputString)
            
            
            
            }
        }else{
            outputString = "Aktivieren Sie unter Einstellungen die Dropboxverbindung"
            showUpdatePopOver(outputString)
    
    }
    
    

    
    }

    @IBAction func lastButtonClicked(_ sender: UIButton) {
       // initProgressView()
        _ = WorkDataHelper.getAllOldSendedNotSprayWorks()
    }
    
    
    func importData(_ reImport: Bool = false) {
        //print (listOfUpdateFiles)
        if listOfUpdateFiles.count > 0 {
            //initProgressView()
           // let progressChunk = 100/listOfUpdateFiles.count //calculating the portion of progress
            if reImport {
                clearAllData()
            }
            for (file,path) in listOfUpdateFiles {
                switch file {
                case "task", "Arbeiten":
                    DropboxSyncService.getDatav2(path, client: DropboxClientsManager.authorizedClient!){result in
                        if let resultTask = result {
                            let task = Task()
                            self.importData(task,data: resultTask)
                            self.removeImportedFile(path)
                        }
                        
                    }
                   
                case "land", "Anlage":
                    DropboxSyncService.getDatav2(path, client: DropboxClientsManager.authorizedClient!){result in
                        if let resultLand = result {
                            let land = Land()
                            self.importData(land,data: resultLand)
                            self.removeImportedFile(path)
                        }
                        
                    }
                    
                    
                case "vquarter", "Sortenquartiere":
                    
                    DropboxSyncService.getDatav2(path, client: DropboxClientsManager.authorizedClient!){result in
                        if let resultVquarter = result {
                            let vquarter = VQuarter()
                            self.importData(vquarter,data: resultVquarter)
                            self.removeImportedFile(path)
                        }
                        
                    }
                    
                    
                case "worker", "Arbeiter":
                    
                    DropboxSyncService.getDatav2(path, client: DropboxClientsManager.authorizedClient!){result in
                        if let resultWorker = result {
                            let worker = Worker()
                            self.importData(worker,data: resultWorker)
                            self.removeImportedFile(path)
                        }
                        
                    }
                case "machine", "Maschinen":
                    
                    DropboxSyncService.getDatav2(path, client: DropboxClientsManager.authorizedClient!){result in
                        if let resultMachine = result {
                            let machine = Machine()
                            self.importData(machine,data: resultMachine)
                            self.removeImportedFile(path)
                        }
                        
                    }
                    
                case "category", "Erntekategorien":
                    
                    DropboxSyncService.getDatav2(path, client: DropboxClientsManager.authorizedClient!){result in
                        if let resultCategory = result {
                            let category = Category()
                            self.importData(category,data: resultCategory)
                            self.removeImportedFile(path)
                        }
                        
                    }
                    
                case "pesticide", "Pflanzenschutzmittel":
                    
                    DropboxSyncService.getDatav2(path, client: DropboxClientsManager.authorizedClient!){result in
                        if let resultPesticide = result {
                            let pesticide = Pesticide()
                            self.importData(pesticide,data: resultPesticide)
                            self.removeImportedFile(path)
                        }
                        
                    }
                case "fertilizer", "Blattdünger":
                    DropboxSyncService.getDatav2(path, client: DropboxClientsManager.authorizedClient!){result in
                        if let resultFertilizer = result {
                            let fertilizer = Fertilizer()
                            self.importData(fertilizer,data: resultFertilizer)
                            self.removeImportedFile(path)
                        }
                        
                    }
                case "soilfertilizer", "Bodendünger":
                    
                    DropboxSyncService.getDatav2(path, client: DropboxClientsManager.authorizedClient!){result in
                        if let resultSoilFertilizer = result {
                            let soilFertilizer = SoilFertilizer()
                            self.importData(soilFertilizer,data: resultSoilFertilizer)
                            self.removeImportedFile(path)
                        }
                        
                    }
                case "reason","Einsatzgründe:":
                    DropboxSyncService.getDatav2(path, client: DropboxClientsManager.authorizedClient!){result in
                        if let resultPestReasons = result {
                            let pestReason = Einsatzgrund(code: "", name: "")
                            self.importData(pestReason, data: resultPestReasons)
                            self.removeImportedFile(path)
                        }
                    }
                default:
                    print("No such a table")
                }
            }
            
        }
        self.spinner?.stopAnimating();
        //  progressView.removeFromSuperview()
        //  progressLabel.removeFromSuperview()
    }
    
    func removeImportedFile (_ path: String) {
        DropboxSyncService.delFile(path)
    }
    
    func initProgressView(){
        turn = 0
        let xCoord = self.view.center.x
        let yCoord = self.view.center.y + 10
        progressLabel = UILabel(frame: CGRect(x: xCoord, y: yCoord, width: 100, height: 23))
        progressLabel.text = "0 %"
        progressLabel.font = UIFont.boldSystemFont(ofSize: 14)
        progressView.center = self.view.center
        progressView.trackTintColor = UIColor.lightGray
        progressView.tintColor = UIColor.blue
       // self.view.backgroundColor = UIColor.yellowColor()
        self.view.addSubview(progressView)
        self.view.addSubview(progressLabel)
        
       
    }
    
    func importData (_ source : ImportDataInterface, data : Data) {
        var backend:Settings.BackendSoftware{
            get{
                return Settings.getBackendSoftware()
            }
        }
        switch backend {
        case .asa:
            DispatchQueue.global(qos: .background).async(execute: {
                source.importAsaData(data)
                DispatchQueue.main.async(execute: {
                    //self.counter += progressStep
                    return
                })
            })
            
            
        case .excel:
            DispatchQueue.global(qos: .background).async(execute: {
                source.importExcelData(data)
                DispatchQueue.main.async(execute: {
                    //self.counter += progressStep
                    return
                })
            })
            
        }
       
    }
    func clearAllData() { //deleting existing data for reImport
        for (file,_) in listOfUpdateFiles {
            switch file {
            case "task", "Arbeiten":
                TaskDataHelper.deleteAll()
            case "land", "Anlage":
                LandDataHelper.deleteAll()
                VQuarterDataHelper.deleteAll()
            case "vquarter", "Sortenquartiere":
                VQuarterDataHelper.deleteAll()
            case "worker", "Arbeiter":
                WorkerDataHelper.deleteAll()
            case "machine", "Maschinen":
                MachineDataHelper.deleteAll()
            case "category", "Erntekategorien":
               CategoryDataHelper.deleteAll()
            case "pesticide", "Pflanzenschutzmittel":
                PesticideDataHelper.deleteAll()
            case "fertilizer", "Blattdünger":
                FertilizerDataHelper.deleteAll()
            case "soilfertilizer", "Bodendünger":
                SoilFertilizerDataHelper.deleteAll()
                
            default:
                print("No such a table")
            }
        }
    }
    // MARK: - Show Import Popover
    func showUpdatePopOver(_ updateString: String) {
        let popoverContent = self.storyboard?.instantiateViewController(withIdentifier: "ImportDataViewController") as! ImportDataViewController
        let nav = UINavigationController(rootViewController: popoverContent)
        nav.modalPresentationStyle = UIModalPresentationStyle.popover
        let popover = nav.popoverPresentationController
        popoverContent.preferredContentSize = CGSize(width: 280,height: 280)
        popoverContent.title = "Updates"
        popoverContent.updateMessage = updateString
        
        popoverContent.importDataDelegate = self
        popover!.delegate = self
        popover!.sourceView = self.view
        popover!.sourceRect = CGRect(x: 280,y: 280,width: 0,height: 0)
        
        self.present(nav, animated: true, completion: nil)
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        // Return no adaptive presentation style, use default presentation behaviour
        return .none
    }
    // MARK: callback from UpdatePopOver
    func importUpdateFiles(_ reImport: Bool) {
        //initProgressView()
        spinner?.startAnimating()
        let delay = 0.8 * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time){
            self.importData(reImport)
            
        }
        
    }

}

