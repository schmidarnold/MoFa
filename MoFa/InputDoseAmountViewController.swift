//
//  InputDoseAmountViewController.swift
//  MoFa
//
//  Created by Arnold Schmid on 06.09.15.
//  Copyright (c) 2015 Arnold Schmid. All rights reserved.
//

import UIKit
protocol getPestDelegate {
    func getPestInfos(_ dose: Double, amount: Double)
    func getPestInfosASA16(dose: Double, amount: Double, reason: String , periodCode: String)
}
protocol getFertDelegate {
    func getFertInfos(_ dose: Double, amount: Double)
}

class InputDoseAmountViewController: UIViewController{
   
    @IBOutlet weak var pickerTextField: UITextField!
    @IBOutlet weak var doseTextView: UITextField!
    
    @IBOutlet weak var amountHaTextView: UITextField!
    
    @IBOutlet weak var timeConstraintsTextView: UITextView!
    
    @IBOutlet weak var timePeriodLabel: UILabel!
    @IBOutlet weak var totalSizeLabel: UILabel!
    @IBOutlet weak var amountTextView: UITextField!
    var dose: Double?
//        {
//        didSet {
//            doseTextView.text = dose?.description
//            
//            
//        }
//    }
    var doseAmount: Double?
//        {
//        didSet {
//            amountTextView.text = doseAmount?.description
//            if sumSize != nil {
//              amountProHaLabel.text =   Double(round(doseAmount!/Double(sumSize!) * 10000)).description
//            }
//        }
//    }
    var reason: String?
        
    
    var periodCode: String?
    var isNewProd : Bool = true //helper variable to check if we select it from PesticideFertilizerController or SprayinViewController
    var fertDelegate : getFertDelegate?
    var pestDelegate : getPestDelegate?
    var initDose : Double? // helperVariable to store the dose for existin values from SprayinViewController
    var isPesticide:Bool = true
    var wateramount: Double?
    var concentration: Double?
    var product : Product?
    var sumSize : Int?
    //only true if asa16 in settings is checked
    var asa16 :Bool =  false
    var reasonData:(reason:String,periodCode:String)?
    var wirkungen = [Wirkung]()
    var warteFristen = [WarteFrist]()
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyBoard))
        self.view.addGestureRecognizer(tap)
        if (isNewProd) {
            if let pest = product as? Pesticide {
                isPesticide = true
                if let defaultDose = pest.defaultDose {
                    self.dose = defaultDose
                    doseTextView.text = dose?.description
                    calcAmount()
                    calcAmountHa()
                    
                }
            } else if let fert = product as? Fertilizer {
                isPesticide = false
                if let defaultDose = fert.defaultDose {
                    self.dose = defaultDose
                    doseTextView.text = dose?.description
                    calcAmount()
                    calcAmountHa()
                }
                
            }
        } else {
            if let _ = product as? Pesticide {
                isPesticide = true
                self.dose = initDose
                doseTextView.text = dose?.description
                calcAmount()
                calcAmountHa()
                if reasonData != nil {
                    let (r,p) = reasonData! //tuple: r for reason and p for period
                    reason = r
                    
                    periodCode = p
                }
            } else if let _ = product as? Fertilizer {
                isPesticide = false
                self.dose = initDose
                doseTextView.text = dose?.description
                calcAmount()
                calcAmountHa()
            }
        }
        if sumSize != 0 {
            totalSizeLabel.text! += sumSize!.description
        }
        if  let pest = product as? Pesticide, asa16 == true{
            var indexPos  = 0 //setting position for wirkungen
            let anbauArt = Settings.getUserDefaultsString(keyValue: Settings.asaCultivationType)
            let jsonPest = pest.constraints
            let decoder = JSONDecoder()
            if let jsonData = jsonPest!.data(using: .utf8),
                let constraints = try? decoder.decode(PestRestrictions.self, from:jsonData){
                    wirkungen = constraints.wirkungen
                    warteFristen = constraints.warteFristen.filter{$0.prodType == anbauArt}
                }
            //let wirkungsList = wirkungen.map{$0.reason  + ", " + $0.cultur}
           // pickerTextField.loadDropdownData(data:wirkungen)
            
            if(self.reason != nil){ //setting the textfield to the right value
                if let index = wirkungen.firstIndex(where: {$0.description == self.reason! && $0.periodCode == self.periodCode!} ) {
                    indexPos = index
                }
                
            }
            
            timePeriodLabel.text =  wirkungen[indexPos].period
            pickerTextField.loadDropDownData(data: wirkungen, onSelect: wirkungen_Changed, indexPosition: indexPos)
            formatWarteFristen(warteFristen: warteFristen, selectedWirkung: wirkungen[indexPos])
            
        }
        // Do any additional setup after loading the view.
    }
    func wirkungen_Changed(selectedWirkung: Wirkung){
        reason = selectedWirkung.description
        periodCode = selectedWirkung.periodCode
        timePeriodLabel.text = selectedWirkung.period
    }
    @objc func hideKeyBoard(sender: UITapGestureRecognizer? = nil){
        view.endEditing(true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func okButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
        if (isPesticide == true) {
            if asa16 {
                if reason == nil{
                    reason = wirkungen[0].description
                    periodCode = wirkungen[0].periodCode
                    }
                    print (dose!)
                    pestDelegate?.getPestInfosASA16(dose: dose!, amount: doseAmount!, reason: reason!, periodCode: periodCode!)
                }else{
                    pestDelegate?.getPestInfos (dose!,amount: doseAmount!)
                
                }
            
            } else {
            fertDelegate?.getFertInfos (dose!,amount: doseAmount!)
        }
        
        
        
    }
    @IBAction func cancelButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }

  
    @IBAction func dosisTxtFieldChanged(_ sender: UITextField) {
        dose = (sender.text! as NSString).doubleValue
        calcAmount()
        calcAmountHa()
    }
    
    
    @IBAction func amountTxtFieldChanged(_ sender: UITextField) {
        doseAmount = (sender.text! as NSString).doubleValue
        calcDose()
        calcAmountHa()
    }
    
   
    @IBAction func amountHaTxtFieldChanged(_ sender: UITextField) {
        let amountHa = (sender.text! as NSString).doubleValue
        doseAmount = amountHa/10000 * Double(sumSize!)
        amountTextView.text = doseAmount?.description
        calcDose()
    }
    
    
    func calcAmount(){
        let amount = (dose! * wateramount!)
        let calcAmount = amount * Double(concentration!)
        doseAmount = Double(round(1000*calcAmount)/1000)
        amountTextView.text = doseAmount?.description
        
    }
    func calcAmountHa(){
        if sumSize != nil {
            if Settings.getBackendSoftware() == Settings.BackendSoftware.excel {
                amountHaTextView.text =   Double(round(doseAmount!/Double(sumSize!) * 10000)).description
            }else {
                let valueProHa = round((doseAmount!/Double(sumSize!) * 10000) * 1000) / 1000
                
                amountHaTextView.text = valueProHa.description
            }
            
        }
        
    }
    func calcDose(){
        let amount = doseAmount! / wateramount!
        let calcDose = amount / Double(concentration!)
        dose =  Double(round(1000*calcDose)/1000)
        doseTextView.text = dose?.description
    }
    func formatWarteFristen(warteFristen:[WarteFrist], selectedWirkung:Wirkung){
        var waitStr=""
        if warteFristen.count > 0 {
            if warteFristen[0].beeRestriction == 1 {
                waitStr = "🐝ACHTUNG BIENENGEFÄHRLICH🐝+ \n"
            }
        }
        for warteFrist in warteFristen{
            if let status = warteFrist.status {
                waitStr += warteFrist.cultur + " - Status: " + status + "\n"
                
            }
            
        }
        
        for warteFrist in warteFristen{
            waitStr += "Karenzzeit: " + warteFrist.cultur + " - " + warteFrist.prodType + ": " + warteFrist.waitTime + "\n"
        }
        
       waitStr += "Max Dosierung: \(selectedWirkung.maxDose ?? 0.00) \n"
        waitStr += "Min Dosierung: \(selectedWirkung.minDose ?? 0.00) \n"
        waitStr += "Max Menge pro ha: \(selectedWirkung.maxAmountProUse ?? 0.00) \n"
        waitStr += "Max Anzahl pro Jahr: \(selectedWirkung.maxUseProYear ?? 0) \n"
        timeConstraintsTextView.text = waitStr
    }
   }
