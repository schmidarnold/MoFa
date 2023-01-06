//
//  SprayingViewController.swift
//  MoFa
//
//  Created by Arnold Schmid on 10.08.15.
//  Copyright (c) 2015 Arnold Schmid. All rights reserved.
//

import UIKit

class SprayingViewController: UIViewController, UIPickerViewDataSource,UIPickerViewDelegate,returnPestFertListDelegate, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate, getPestDelegate, getFertDelegate{
    
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var txtConcValues: UITextField!
    
    @IBOutlet weak var lblWarning: UILabel!
    @IBOutlet weak var weatherSegControl: UISegmentedControl!
    @IBOutlet weak var txtWateramount: UITextField!
    var concentration: Double? {
        didSet {
            txtConcValues.text = concentration?.description
            tbvc.spraying?.concentration = Double(concentration!)
        }
    }
    var wateramount: Double?{
        didSet {
//            txtWateramount.text = wateramount?.description
            tbvc.spraying?.wateramount = wateramount
        }
    }
    var productList = [SprayProduct]()
    var currentSprayPesticides :[SprayPesticide]?
    var currentSprayFertlilizers: [SprayFertilizer]?
    var arrayIndex : Int?
    var isPesticide : Bool = true
    let concValues = [Double](arrayLiteral: 1.0,1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,7.0,8.0,9.0,10.0)
    let numberToolbar: UIToolbar = UIToolbar() //for done key
    var tbvc = WorkTabBarController()
    var msg = "Keine Warnungen"
    
   
    override func viewDidLoad() {
        tbvc = self.tabBarController  as! WorkTabBarController
        
        if tbvc.newEntry == false {
            tbvc.spraying?.work_id = tbvc.curWork.workId!
            if tbvc.spraying != nil { //spraying is stored
                concentration = tbvc.spraying?.concentration
                wateramount = tbvc.spraying?.wateramount
                txtWateramount.text = wateramount?.description
                weatherSegControl.selectedSegmentIndex = (tbvc.spraying?.weather)! - 1
                
                fillProductList(tbvc.sprayPest)
                fillProductList(tbvc.sprayFert)
                checkConstraints()
                }else { //work exists, but not a spraying entry
                concentration = getLastConcValue()
                wateramount = updateWaterAmount()
                
            }
            
            
            
        } else { // new Entry
            tbvc.spraying = Spraying()
            concentration = getLastConcValue()
            wateramount = updateWaterAmount()
            
            
        }
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SprayProductCell.self, forCellReuseIdentifier: "Cell")
        let nib = UINib (nibName: "sprayProductCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        configureTableView()
        numberToolbar.barStyle = UIBarStyle.blackTranslucent
        numberToolbar.items=[
            
            UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Fertig", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.dismissKeyBoard))
        ]
        //#selector(Stream.close))
        numberToolbar.sizeToFit()
        
        txtWateramount.inputAccessoryView = numberToolbar
    }
    @objc func dismissKeyBoard(){
        view.endEditing(true)
    }
    func fillProductList(_ items: [SprayProduct]?) {
        
        
        if items != nil {
            for item in items! {
                productList.append(item)
            }
        }
        
    }
    func close() {
        txtWateramount.resignFirstResponder()
    }
    @IBAction func concStartEditing(_ sender: UITextField) {
        let concPickerView: UIPickerView = UIPickerView()
        concPickerView.dataSource = self
        concPickerView.delegate = self
        
        //ToDo preselect the current value
        if let curConc = (Int(txtConcValues.text!)) {
            concPickerView.selectRow(curConc-1,inComponent: 0,animated: false)        }
        
        
        
        sender.inputView = concPickerView
        
    }
    
    @IBAction func txtWaterAmountChanged(_ sender: UITextField) {
        let water = (sender.text! as NSString).doubleValue
        //saveWater()
       wateramount = Double(round(100*water)/100) //formatting to 2 decimals
        
        
    }
    func saveWater() {
        let water = (txtWateramount.text! as NSString).doubleValue
        wateramount = Double(round(100*water)/100)
        
    }
    @IBAction func refreshButtonClick(_ sender: UIButton) {
        wateramount = updateWaterAmount()
    }
    
    @IBAction func weatherSegChanged(_ sender: UISegmentedControl) {
        tbvc.spraying?.weather = weatherSegControl.selectedSegmentIndex + 1
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "pesticideSegue":
                let vc = segue.destination as? PesticideFertilizerController
                vc?.callingSource = Constants.Spraying
                vc?.wateramount = self.wateramount
                vc?.concentration = self.concentration
                let sprayList = productList.filter(){$0.isPest == true}
                vc?.currentSprayPesticides = sprayList as? [SprayPesticide]
                let fertList = productList.filter(){$0.isPest == false}
                vc?.currentSprayFertilizers = fertList as? [SprayFertilizer]
                vc?.pestFertDelegate = self
                if let sumSize = VQuarterDataHelper.sumSize(tbvc.curVQuarters) {
                   vc?.sumSize = sumSize
                }
                
            default: break
            }
            
        }
        
    }
    func configureTableView() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 180.0
    }
    
    //MARK: - Delegates and data sources
    //MARK: Data Sources
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return concValues.count
    }
    //MARK: Delegates
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        return concValues[row].description
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        concentration = concValues[row]
        txtConcValues.resignFirstResponder()
        
    }
    func updateWaterAmount() -> Double {
        let conc = concentration
        let sumofWater =  VQuarterDataHelper.sumWaterAmount(tbvc.curVQuarters)
        let result = sumofWater / Double(conc!)
        txtWateramount.text = (round(100*result)/100).description
        return Double(round(100*result)/100) //formatting to 2 decimals
        
    }
    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        
        print("SprayingViewController: Go back")
    }
    //MARK: - Show input for Dose and amount and callback
    func showInputDoseWindow(_ product: Product, row: Int) {
        let popoverContent = self.storyboard?.instantiateViewController(withIdentifier: "inputDoseBox") as! InputDoseAmountViewController
        let nav = UINavigationController(rootViewController: popoverContent)
        nav.modalPresentationStyle = UIModalPresentationStyle.popover
        let popover = nav.popoverPresentationController
        popoverContent.preferredContentSize = CGSize(width: 280,height: 200)
        popoverContent.wateramount = wateramount
        popoverContent.concentration = concentration
        popoverContent.title = product.productName
        popoverContent.initDose = productList[row].dose
        if let sumSize = VQuarterDataHelper.sumSize(tbvc.curVQuarters) {
            popoverContent.sumSize = sumSize
        }
        popoverContent.product = product
        popoverContent.isNewProd = false
        popoverContent.pestDelegate = self
        popoverContent.fertDelegate = self
        popover!.delegate = self
        popover!.sourceView = self.view
        popover!.sourceRect = CGRect(x: 280,y: 200,width: 0,height: 0)
        
        self.present(nav, animated: true, completion: nil)
    }
    func showInputDoseWindowASA16(_ product: Product, row: Int) {
        let popoverContent = self.storyboard?.instantiateViewController(withIdentifier: "inputDoseBoxASA16") as! InputDoseAmountViewController
        let nav = UINavigationController(rootViewController: popoverContent)
        nav.modalPresentationStyle = UIModalPresentationStyle.popover
        let popover = nav.popoverPresentationController
        popoverContent.preferredContentSize = CGSize(width: 280,height: 350)
        popoverContent.wateramount = wateramount
        popoverContent.concentration = concentration
        popoverContent.title = product.productName
        popoverContent.initDose = productList[row].dose
        if let sumSize = VQuarterDataHelper.sumSize(tbvc.curVQuarters) {
            popoverContent.sumSize = sumSize
        }
        if let sprayPestProduct = productList[row] as? SprayPesticide{
            let reasonData = (reason: sprayPestProduct.reason!, periodCode: sprayPestProduct.periodCode!)
            
            popoverContent.reasonData = reasonData
            //print (sprayPestProduct.reason ?? "default Pest Value")
        }
        
        popoverContent.asa16=true
        popoverContent.product = product
        popoverContent.isNewProd = false
        popoverContent.pestDelegate = self
        popoverContent.fertDelegate = self
        popover!.delegate = self
        popover!.sourceView = self.view
        popover!.sourceRect = CGRect(x: 280,y: 350,width: 0,height: 0)
        
        self.present(nav, animated: true, completion: nil)
    }
    func getPestInfos(_ dose: Double, amount:Double) {
        productList[arrayIndex!].dose = dose
        productList[arrayIndex!].doseAmount = amount
        checkConstraints()
        tableView.reloadData()
    }
    func getPestInfosASA16(dose: Double, amount: Double, reason: String, periodCode: String) {
        productList[arrayIndex!].dose = dose
        productList[arrayIndex!].doseAmount = amount
        let prodId = productList[arrayIndex!].prod_id
        let curProd = tbvc.sprayPest?.filter({$0.prod_id == prodId})
        curProd?[0].reason = reason
        curProd?[0].periodCode = periodCode
        checkConstraints()
        tableView.reloadData()
    }
    func getFertInfos(_ dose: Double, amount: Double) {
        productList[arrayIndex!].dose = dose
        productList[arrayIndex!].doseAmount = amount
        
        tableView.reloadData()
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        // Return no adaptive presentation style, use default presentation behaviour
        return .none
    }
    
    
    
    //MARK: - Delegate, callback from PesticideFertilizerController
    func getPestFertList(_ pestList: [SprayPesticide], fertList: [SprayFertilizer]) {
      
        productList.removeAll()
        fillProductList(pestList)
        fillProductList(fertList)
        tbvc.sprayPest = pestList
        tbvc.sprayFert = fertList
        tableView.reloadData()
        checkConstraints()
        
    }
    //MARK: - Delegate, DataSource for tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return productList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! SprayProductCell
        
            let sprayProduct = productList[indexPath.row]
            let productId = sprayProduct.prod_id
            if sprayProduct.isPest == true{
                let product = PesticideDataHelper.find(productId)
                cell.productLabel.text = product?.productName
                cell.backgroundColor = UIColor.orange
               
                
            }else {
                let product = FertilizerDataHelper.find(productId)
                cell.productLabel.text = product?.productName
                cell.backgroundColor = UIColor.green
            }
            cell.doseLabel.text = productList[indexPath.row].dose.description
            cell.amountLabel.text = productList[indexPath.row].doseAmount.description
        
        cell.trashButton.tag = indexPath.row
        cell.trashButton.addTarget(self, action: #selector(SprayingViewController.delProduct(_:)), for: .touchUpInside)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let product : Product?
        
       
            let x = productList[indexPath.row]
            if x.isPest == true {
                product = PesticideDataHelper.find(x.prod_id)
            }else {
                product = FertilizerDataHelper.find(x.prod_id)
            }
        
       
        arrayIndex = indexPath.row
        //only call detailPestInputDose for ASA16 and only for pesticide
        if (x.isPest && Settings.getUserDefaultsBoolean(keyValue: Settings.asaVer16Key)) {
            showInputDoseWindowASA16(product!, row: arrayIndex!)
        }else{
            showInputDoseWindow(product!, row: arrayIndex!)
            
        }
        
    }
   
    @objc func delProduct(_ sender: AnyObject) {
        let delButton = sender as! UIButton
        let prodToDel = productList[delButton.tag]
        productList.remove(at: delButton.tag)
        if prodToDel.isPest == true {
            let sprayList = productList.filter(){$0.isPest == true}
            tbvc.sprayPest = sprayList as? [SprayPesticide]
            SprayPesticideHelper.delete(prodToDel.id)
        }else {
            let fertList = productList.filter(){$0.isPest == false}
            tbvc.sprayFert = fertList as? [SprayFertilizer]
            SprayFertilizerHelper.delete(prodToDel.id)
        }
        
        tableView.reloadData()
    }
    
    func checkConstraints() {
        var first : Bool = true
        msg = "Keine Warnungen"
        lblWarning.backgroundColor = UIColor.green
        for prod in productList{
            if prod.isPest{
                let pesticide = PesticideDataHelper.find(prod.prod_id)
                let constraints = pesticide!.constraints
                let data = constraints!.data(using: String.Encoding.utf8, allowLossyConversion: false)!
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: AnyObject]
                    if let maxAmount = json["maxAmount"] as? Double {
                        var curAmount : Double
                        if let sumSize = VQuarterDataHelper.sumSize(tbvc.curVQuarters) {
                            if Settings.getBackendSoftware() == Settings.BackendSoftware.excel {
                                curAmount = prod.doseAmount/1000 //we have the amount in gramm, convert to kg
                            }else{
                                curAmount = prod.doseAmount
                            }
                            let amountProHa = curAmount/Double (sumSize) * 10000
                            if (amountProHa > maxAmount) {
                                if first {
                                    lblWarning.backgroundColor = UIColor.red
                                    msg = ("Warnung: \(pesticide!.productName) max Menge/ha überschritten")
                                    first = false
                                } else {
                                    msg += ",\(pesticide!.productName) max Menge/ha überschritten"
                                }
                                
                            }
                        }
                    }
                    if let maxDose = json["maxDose"] as? Double {
                        if prod.dose > maxDose {
                            if first {
                                lblWarning.backgroundColor = UIColor.red
                                msg = ("Warnung: \(pesticide!.productName) max Dosis/hl überschritten")
                                first = false
                            }else{
                                msg += ",\(pesticide!.productName) max Dosis/hl überschritten"
                            }
                            
                            
                            
                        }
                        
                    }
                } catch let error as NSError {
                    print("Failed to load: \(error.localizedDescription)")
                }
            }
        }
        lblWarning.text = msg
        
    }
    func getLastConcValue() -> Double{
        if UserDefaults.standard.object(forKey: "lastConcValue") != nil {
            let concentration = UserDefaults.standard.double(forKey: "lastConcValue")
            return concentration
        }else{
            return 1.00 //default value
        }
    }

}
