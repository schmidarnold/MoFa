//
//  SettingsTableViewController.swift
//  MoFa
//
//  Created by Arnold Schmid on 24.04.15.
//  Copyright (c) 2015 Arnold Schmid. All rights reserved.
//

import UIKit
import SwiftyDropbox
class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var dropBoxSwitch: UISwitch!
    @IBOutlet var asaButton: CustomButton!
    @IBOutlet var excelButton: CustomButton!
    
    @IBOutlet weak var psmSwitch: UISwitch!
    
    @IBOutlet weak var asaNoteSwitch: UISwitch!
    
    @IBOutlet weak var asaSortingSwitch: UISwitch!
    @IBOutlet weak var asaCultivationSegment: UISegmentedControl!
    @IBOutlet weak var asaVer16Switch: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()
        if Settings.getBackendSoftware() == Settings.BackendSoftware.asa{
           asaButton?.activeBackGroundColor = UIColor.green
        }else{
            excelButton.activeBackGroundColor = UIColor.green
        }
        //asaButton?.activeBackGroundColor = UIColor.greenColor()
        asaButton?.myAlternateButton = [excelButton!]
        
        //excelButton?.activeBackGroundColor = UIColor.greenColor()
        excelButton?.myAlternateButton = [asaButton!]
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        if DropboxClientsManager.authorizedClient != nil {
            dropBoxSwitch.isOn = true
        }else {
            dropBoxSwitch.isOn = false
        }
        if Settings.getUserDefaultsBoolean(keyValue: Settings.showPsmKey){
            psmSwitch.isOn = true
        }else{
            psmSwitch.isOn = false //userdefaults not set or false
        }
        if Settings.getUserDefaultsBoolean(keyValue: Settings.asaNoteKey){
            asaNoteSwitch.isOn = true
        } else {
            asaNoteSwitch.isOn = false //userdefaults not set or false
        }
        if Settings.getUserDefaultsBoolean(keyValue: Settings.asaVer16Key){
            asaVer16Switch.isOn = true
            }else{
            asaVer16Switch.isOn = false
        }
        if Settings.getUserDefaultsBoolean(keyValue: Settings.asaSortingByCode){
            asaSortingSwitch.isOn = true
            }else{
            asaSortingSwitch.isOn = false
        }
        if let cultivationType = Settings.getUserDefaultsString(keyValue: Settings.asaCultivationType){
            switch cultivationType{
                case "Agrios":
                    asaCultivationSegment.selectedSegmentIndex = 0
                case "Bio":
                    asaCultivationSegment.selectedSegmentIndex = 1
                case "Gesetzlich":
                    asaCultivationSegment.selectedSegmentIndex = 2
                default:
                    asaCultivationSegment.selectedSegmentIndex = 1
                
            }
            
        }else{ //default value or no settings set
             Settings.setUserDefaultsString(keyValue: Settings.asaCultivationType, value: asaCultivationSegment.titleForSegment(at: 0)!)
            asaCultivationSegment.selectedSegmentIndex = 0
            
        }
        
    }

    @IBAction func changedDropBoxSwitch(_ sender: UISwitch) {
        if sender.isOn {
            //DropboxClientsManager.authorizeFromController(self)
            DropboxClientsManager.authorizeFromController(UIApplication.shared,
                                                          controller: self,
                                                          openURL: { (url: URL) -> Void in
                                                            UIApplication.shared.openURL(url)
            })
            
        } else {
            let _ = DropboxClientsManager.unlinkClients()
            //DropboxClientsManager.unlinkClient()
        }
    }
    
    @IBAction func changedPsmSwitch(_ sender: UISwitch) {
        if sender.isOn {
            Settings.setUserDefaultsBoolean(keyValue: Settings.showPsmKey, value: true)
        }else{
            Settings.setUserDefaultsBoolean(keyValue: Settings.showPsmKey, value: false)
        }
        
    }
    
    @IBAction func changedAsaNoteSwitch(_ sender: UISwitch) {
        if sender.isOn {
            Settings.setUserDefaultsBoolean(keyValue: Settings.asaNoteKey, value: true)
        }else{
            Settings.setUserDefaultsBoolean(keyValue: Settings.asaNoteKey, value: false)
        }
    }
    
    @IBAction func changedAsaVersion(_ sender: UISwitch) {
        if sender.isOn {
            Settings.setUserDefaultsBoolean(keyValue: Settings.asaVer16Key, value: true)
        }else{
            Settings.setUserDefaultsBoolean(keyValue: Settings.asaVer16Key, value: false)
        }
        
    }
    
    @IBAction func sortingAsaByCode(_ sender: UISwitch) {
        if sender.isOn {
            Settings.setUserDefaultsBoolean(keyValue: Settings.asaSortingByCode, value: true)
        }else{
            Settings.setUserDefaultsBoolean(keyValue: Settings.asaSortingByCode, value: false)
        }
        
    }
    @IBAction func setBackendToASA(_ sender: CustomButton) {
        if WorkDataHelper.countAll() > 0 {
            showAlert()
        } else {
            Settings.setBackendSoftware(Settings.BackendSoftware.asa)
        }
        
    }
    
    @IBAction func setBackendToExcel(_ sender: CustomButton) {
        if WorkDataHelper.countAll() > 0 {
            showAlert()
        }else {
            Settings.setBackendSoftware(Settings.BackendSoftware.excel)
        }
        
    }
    
    @IBAction func cultivationSegmentIndexChanged(_ sender: UISegmentedControl) {
        switch asaCultivationSegment.selectedSegmentIndex
        {
        case 0:
            Settings.setUserDefaultsString(keyValue: Settings.asaCultivationType, value: asaCultivationSegment.titleForSegment(at: 0)!)
        case 1:
             Settings.setUserDefaultsString(keyValue: Settings.asaCultivationType, value: asaCultivationSegment.titleForSegment(at: 1)!)
        case 2:
             Settings.setUserDefaultsString(keyValue: Settings.asaCultivationType, value: asaCultivationSegment.titleForSegment(at: 2)!)
        default:
            break
        }
    }
    func showAlert() {
        let alertController = UIAlertController(title: "MoFa", message: "Arbeiten noch vorhanden!! Senden oder Löschen Sie noch alle vorhandenen Arbeiten und Leeren Sie das Archiv", preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "Schließen", style: .default, handler: nil)
        alertController.addAction(closeAction)
        self.present(alertController, animated: true, completion:nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func archivButtonTouched(_ sender: UIButton) {
        let alertController = UIAlertController(title: "MoFa", message: "Alle gesendeten Arbeiten werden gelöscht!", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "Fortfahren", style: .default,handler: delAllSendedWorks)
        let CancelAction = UIAlertAction(title: "Abbrechen", style: .default, handler: nil)
        alertController.addAction(OKAction)        //TODO
        alertController.addAction(CancelAction)
        self.present(alertController, animated: true, completion:nil)
    }
    func delAllSendedWorks(_ alert: UIAlertAction!){
        let delRecords = WorkDataHelper.clearArchiv()
        let alertController = UIAlertController(title: "MoFa", message: "Archiv wurde geleert! \(delRecords) Einträge wurden gelöscht", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default,handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion:nil)
    }

}
