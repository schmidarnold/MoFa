//
//  PesticideFertilizerController.swift
//  MoFa
//
//  Created by Arnold Schmid on 28.08.15.
//  Copyright (c) 2015 Arnold Schmid. All rights reserved.
//

import UIKit
protocol returnPestFertListDelegate {
    func getPestFertList(_ pestList: [SprayPesticide], fertList: [SprayFertilizer])
}
protocol ReturnPurchaseListDelegate {
    func getPurchaseList(_ purchaseList: [PurchaseProduct])
}
protocol ReturnCurrentProductDelegate {
    func getProduct(_ product: Product)
}
class PesticideFertilizerController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIPopoverPresentationControllerDelegate,getPestDelegate, getFertDelegate, PurchaseAmountDelegate   {
    
    

    @IBOutlet weak var searchBar: UISearchBar!
    
    
    @IBOutlet weak var tableView: UITableView!
    var dose: Double? {
        didSet {
            
        }
    }
    var doseAmount: Double? {
        didSet {
            
        }
    }
    var purchaseId:Int?
    var purchaseProducts : [PurchaseProduct]?
    var getPurchaseDelegate: ReturnPurchaseListDelegate?
    var pestFertDelegate: returnPestFertListDelegate?
    var getProductDelegate: ReturnCurrentProductDelegate?
    var currentSprayPesticides :[SprayPesticide]?
    var currentSprayFertilizers : [SprayFertilizer]?
    var searchActive : Bool = false
    var prodData : [Product] = []
    var pestData  = PesticideDataHelper.findAllSorted()
    var fertData  = FertilizerDataHelper.findAllSorted()
    var filteredData:[Product] = []
    var isPesticide : Bool = true
    var wateramount : Double?
    var concentration : Double?
    var currentProduct : Product?
    var callingSource : Int?
    var sumSize : Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        self.prodData = self.pestData!
        isPesticide = true
    }
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if searchBar.text != "" {
            searchActive = true;
        }
        
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filteredData = self.prodData.filter({( pest: Product) -> Bool in
            // to start, let's just search by name
            return pest.productName.lowercased().range(of: searchText.lowercased()) != nil
        })
        
        //        filtered = data.filter({ (text) -> Bool in
//            let tmp: NSString = text
//            let range = tmp.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
//            return range.location != NSNotFound
//        })
       if(filteredData.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
       self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive) {
            return filteredData.count
        }
        return prodData.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        if(searchActive){
            let p = filteredData[indexPath.row]
            cell.textLabel?.text = p.productName
            // cell.textLabel?.text = filtered[indexPath.row]
        } else {
            let p = prodData[indexPath.row]
            cell.textLabel?.text = p.productName
        }
        if isPesticide == true {
            cell.accessoryType = UITableViewCell.AccessoryType.detailButton
        }else {
            cell.accessoryType = UITableViewCell.AccessoryType.none
        }
        
        return cell;
    }
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if(searchActive){
            let p = filteredData[indexPath.row]
            showProductInfo(p)
            // cell.textLabel?.text = filtered[indexPath.row]
        } else {
            let p = prodData[indexPath.row]
            showProductInfo(p)
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (searchActive){
            currentProduct = filteredData[indexPath.row]
        }else {
            currentProduct = prodData[indexPath.row]
        }
        if callingSource! == Constants.Spraying {
            //checking if asaver16
            if Settings.getUserDefaultsBoolean(keyValue: Settings.asaVer16Key) && isPesticide {
                showInputDoseWindowASA16()
            }else {
                showInputDoseWindow()
                
            }
            
        }
        if callingSource! == Constants.Purchase {
            showInputPurchaseWindow()
        }
        if callingSource! == Constants.Search{
            getProductDelegate?.getProduct(currentProduct!)
            _ = navigationController?.popViewController(animated: true)
            
        }
        
    }
    
    func valueChanged(_ segmentedControl: UISegmentedControl) {
//        print("Coming in : \(segmentedControl.selectedSegmentIndex)")
//        if(segmentedControl.selectedSegmentIndex == 0){
//            self.prodData = self.pestData!
//            isPesticide = true
//        } else {
//            self.prodData = self.fertData!
//            isPesticide = false
//        }
//        self.tableView.reloadData()
    }
    
    @IBAction func segIndexChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex
        {
        case 0:
            self.prodData = self.pestData!
            isPesticide = true
        case 1:
            self.prodData = self.fertData!
            isPesticide = false
        default:
            break; 
        }
        self.tableView.reloadData()
    }
    
    //MARK: popUpWindows
    func showInputDoseWindow() {
        let popoverContent = self.storyboard?.instantiateViewController(withIdentifier: "inputDoseBox") as! InputDoseAmountViewController
        let nav = UINavigationController(rootViewController: popoverContent)
        nav.modalPresentationStyle = UIModalPresentationStyle.popover
        let popover = nav.popoverPresentationController
        popoverContent.preferredContentSize = CGSize(width: 280,height: 200)
        popoverContent.title = currentProduct!.productName
        popoverContent.wateramount = wateramount
        if sumSize != nil {
            popoverContent.sumSize = sumSize
        }
        popoverContent.concentration = concentration
        popoverContent.product = currentProduct
        popoverContent.pestDelegate = self
        popoverContent.fertDelegate = self
        popover!.delegate = self
        popover!.sourceView = self.view
        popover!.sourceRect = CGRect(x: 280,y: 200,width: 0,height: 0)
        
        self.present(nav, animated: true, completion: nil)
    }
    // MARK:popUpWindow ASAAGRAR Ver>16
    func showInputDoseWindowASA16() {
        
        let popoverContent = self.storyboard?.instantiateViewController(withIdentifier: "inputDoseBoxASA16") as! InputDoseAmountViewController
        let nav = UINavigationController(rootViewController: popoverContent)
        nav.modalPresentationStyle = UIModalPresentationStyle.popover
        let popover = nav.popoverPresentationController
        popoverContent.preferredContentSize = CGSize(width: 280,height: 350)
        popoverContent.title = currentProduct!.productName
        popoverContent.wateramount = wateramount
        if sumSize != nil {
            popoverContent.sumSize = sumSize
        }
        popoverContent.asa16=true
        popoverContent.concentration = concentration
        popoverContent.product = currentProduct
        popoverContent.pestDelegate = self
        popoverContent.fertDelegate = self
        popover!.delegate = self
        popover!.sourceView = self.view
        popover!.sourceRect = CGRect(x: 280,y: 350,width: 0,height: 0)
        
        self.present(nav, animated: true, completion: nil)
    }
    
    func showInputPurchaseWindow() {
        let popoverContent = self.storyboard?.instantiateViewController(withIdentifier: "inputPurchase") as! InputPurchaseAmountViewController
        let nav = UINavigationController(rootViewController: popoverContent)
        nav.modalPresentationStyle = UIModalPresentationStyle.popover
        let popover = nav.popoverPresentationController
        popoverContent.preferredContentSize = CGSize(width: 280,height: 150)
        popoverContent.title = currentProduct!.productName
        popoverContent.getPurchaseAmountDelegate = self
        popover!.sourceRect = CGRect(x: 280,y: 150,width: 0,height: 0)
        popover!.delegate = self
        popover!.sourceView = self.view
        self.present(nav, animated: true, completion: nil)
    }
    func showProductInfo(_ p: Product) {
        let pest = p as! Pesticide
        let popoverContent = self.storyboard?.instantiateViewController(withIdentifier: "productInfoViewController") as! ProductInfoViewController
        let nav = UINavigationController(rootViewController: popoverContent)
        nav.modalPresentationStyle = UIModalPresentationStyle.popover
        let popover = nav.popoverPresentationController
        popoverContent.preferredContentSize = CGSize(width: 280,height: 200)
        popoverContent.title = pest.productName
        popoverContent.pesticide = pest
        popover!.sourceRect = CGRect(x: 280,y: 200,width: 0,height: 0)
        popover!.delegate = self
        popover!.sourceView = self.view
        self.present(nav, animated: true, completion: nil)
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        // Return no adaptive presentation style, use default presentation behaviour
        return .none
    }
    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        if callingSource! == Constants.Spraying {
            print("returning from PesticideFertilizerController with this pestList \(currentSprayPesticides?.count ?? 0)")
            pestFertDelegate?.getPestFertList(currentSprayPesticides!, fertList: currentSprayFertilizers!)
        }
        if callingSource! == Constants.Purchase {
            getPurchaseDelegate?.getPurchaseList(purchaseProducts!)
        }
        
    }
    //MARK: Delegate from InputBoxes
    func getPestInfos(_ dose: Double, amount: Double) {
        var index : Int?
        var new : Bool?
        var currSprayPest : SprayPesticide?
        if let found = currentSprayPesticides!.map({ $0.prod_id }).firstIndex(of: currentProduct!.id) {
            index = found
            new = false
        } else {
            currSprayPest = SprayPesticide()
            new = true
        }
        if (new == true){
            currSprayPest?.prod_id = currentProduct!.id
            currSprayPest?.dose = dose
            currSprayPest?.doseAmount = amount
            currentSprayPesticides?.append(currSprayPest!)
        }else {
            currentSprayPesticides![index!].dose = dose
            currentSprayPesticides![index!].doseAmount = amount
        }
        if Settings.getUserDefaultsBoolean(keyValue: Settings.showPsmKey) { //only if in settings enabled
            showProductInfo(currentProduct!)
        }
        
    }
    func getPestInfosASA16(dose: Double, amount: Double, reason: String, periodCode: String) {
        var index : Int?
        var new : Bool?
        var currSprayPest : SprayPesticide?
        if let found = currentSprayPesticides!.map({ $0.prod_id }).firstIndex(of: currentProduct!.id) {
            index = found
            new = false
        } else {
            currSprayPest = SprayPesticide()
            new = true
        }
        if (new == true){
            currSprayPest?.prod_id = currentProduct!.id
            currSprayPest?.dose = dose
            currSprayPest?.doseAmount = amount
            currSprayPest?.reason = reason
            currSprayPest?.periodCode = periodCode
            currentSprayPesticides?.append(currSprayPest!)
        }else {
            currentSprayPesticides![index!].dose = dose
            currentSprayPesticides![index!].doseAmount = amount
            currentSprayPesticides![index!].reason = reason
            currentSprayPesticides![index!].periodCode = periodCode
            
        }
        if Settings.getUserDefaultsBoolean(keyValue: Settings.showPsmKey) { //only if in settings enabled
            showProductInfo(currentProduct!)
        }
    }
    func getFertInfos(_ dose: Double, amount: Double) {
        var index : Int?
        var new : Bool?
        var currSprayFert : SprayFertilizer?
        if let found = currentSprayFertilizers!.map({ $0.prod_id }).firstIndex(of: currentProduct!.id) {
            index = found
            new = false
        } else {
            currSprayFert = SprayFertilizer()
            new = true
        }
        if (new == true){
            currSprayFert?.prod_id = currentProduct!.id
            currSprayFert?.dose = dose
            currSprayFert?.doseAmount = amount
            currentSprayFertilizers?.append(currSprayFert!)
        }else {
            currentSprayFertilizers![index!].dose = dose
            currentSprayFertilizers![index!].doseAmount = amount
        }
        
    }
    func getPurchaseAmount( _ amount: Double) {
        if isPesticide == true { // creating a new purchasepest entry
          let curPurchasePest = PurchasePesticide()
          curPurchasePest.purchase_id = purchaseId!
          curPurchasePest.pest_id = (currentProduct?.id)!
          curPurchasePest.amount = amount
          let id = PurchasePestDataHelper.insert(curPurchasePest)
          curPurchasePest.id = id
          purchaseProducts!.append(curPurchasePest)
        }else{ // creating a new purchasefert entry
            let curPurchaseFert = PurchaseFertilizer()
            curPurchaseFert.purchase_id = purchaseId!
            curPurchaseFert.fert_id = (currentProduct?.id)!
            curPurchaseFert.amount = amount
            let id = PurchaseFertDataHelper.insert(curPurchaseFert)
            curPurchaseFert.id = id
            purchaseProducts!.append(curPurchaseFert)
        }
    }
    func ifIsInArray (_ prodId: Int) -> Bool {
        if (isPesticide == true){
            if let _ = currentSprayPesticides!.map({ $0.prod_id }).firstIndex(of: prodId) {
                return true
            }
            
        }else {
            if let _ = currentSprayFertilizers!.map({ $0.prod_id }).firstIndex (of: prodId){
                return true
            }
        }
        
        return false
    }
    
}
