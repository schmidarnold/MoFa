//
//  PurchaseViewController.swift
//  MoFa
//
//  Created by Arnold Schmid on 12.12.15.
//  Copyright © 2015 Arnold Schmid. All rights reserved.
//

import UIKit
import RATreeView
class PurchaseViewController: UIViewController, RATreeViewDataSource, RATreeViewDelegate, ReturnPurchaseListDelegate, UIPopoverPresentationControllerDelegate, PurchaseAmountDelegate  {
    var currentId : Int = 0
    var table : RATreeView!
    let dateMaker = DateFormatter()
    var purchaseList = [Purchase]()
    var purchaseId: Int?
    var purchaseProductList = [PurchaseProduct]()
    var selectedProduct : PurchaseProduct?
    var selectedPurchase : Purchase?
    let headerCellId = "pHeaderCell"
    let detailCellId = "pProductCell"
    @IBOutlet weak var tableView: UIView!
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        table = RATreeView(frame:tableView.bounds)
        // let frame = tableView.frame
       // tableView.removeFromSuperview()
        loadData()
       // table.frame = frame
        table.dataSource = self
        table.delegate = self
        table.autoresizingMask = UIView.AutoresizingMask(rawValue:UIView.AutoresizingMask.flexibleWidth.rawValue | UIView.AutoresizingMask.flexibleHeight.rawValue)
        let headerCell = UINib(nibName: "purchaseHeaderCell", bundle:nil)
        let detailCell = UINib(nibName: "purchaseProduct", bundle:nil)
        table.register( headerCell, forCellReuseIdentifier: headerCellId)
        table.register(detailCell, forCellReuseIdentifier: detailCellId)
        table.rowHeight = 43
        tableView.addSubview(table)
        table.reloadData()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func newPurchaseButtonClicked(_ sender: UIBarButtonItem) {
        DatePickerDialog().show("Datum", doneButtonTitle: "OK", cancelButtonTitle: "Abbrechecn", datePickerMode: UIDatePicker.Mode.date) {
            (date) -> Void in
            let dateToSave = Int(date.timeIntervalSince1970)
            self.currentId = PurchaseDataHelper.insert(dateToSave)
            print ("\(dateToSave)")
            
            self.purchaseList = PurchaseDataHelper.findAll()!
            self.table.reloadData()
        }
    }
    
    @IBAction func uploadPurchasesClicked(_ sender: AnyObject) {
        
        if (purchaseList.count == 0) {
            let alertController = UIAlertController(title: "MoFa", message: "Keine Einkäufe zum Senden vorhanden!", preferredStyle: .alert)
            let closeAction = UIAlertAction(title: "Schließen", style: .default, handler: nil)
            alertController.addAction(closeAction)
            self.present(alertController, animated: true, completion:nil)
        }else {
            let alertController = UIAlertController(title: "MoFa", message: "Alle Einkäufe werden gesendet! Diese sind danach im Einkaufsjournal nicht mehr vorhanden. Möchten Sie fortfahren!", preferredStyle: .alert)
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
            if Util.connectedToNetwork() == true {
                let priority = DispatchQoS.QoSClass.default
                DispatchQueue.global(qos: priority).async {
                    
                    GenerateFile.createPurchaseASAXml()
                    sleep(1)
                    DispatchQueue.main.async {
                        PurchaseDataHelper.deleteAllWithRefs()
                        self.purchaseList = PurchaseDataHelper.findAll()!
                        self.table.reloadData()
                        let alertController = UIAlertController(title: "MoFa", message: "Upload erfolgreich durchgeführt", preferredStyle: .alert)
                        let OKAction = UIAlertAction(title: "OK", style: .default,handler: nil)
                        alertController.addAction(OKAction)
                        self.present(alertController, animated: true, completion:nil)
                    }
                }
                
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
                    
                    GenerateFile.createPurchaseExcelXml()
                    sleep(1)
                    DispatchQueue.main.async {
                        PurchaseDataHelper.deleteAllWithRefs()
                        self.purchaseList = PurchaseDataHelper.findAll()!
                        self.table.reloadData()
                        let alertController = UIAlertController(title: "MoFa", message: "Upload erfolgreich durchgeführt", preferredStyle: .alert)
                        let OKAction = UIAlertAction(title: "OK", style: .default,handler: nil)
                        alertController.addAction(OKAction)
                        self.present(alertController, animated: true, completion:nil)
                    }
                }
                
            }else {
                let alertController = UIAlertController(title: "MoFa", message: "Keine Internetverbindung verfügbar", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default,handler: nil)
                alertController.addAction(OKAction)
                self.present(alertController, animated: true, completion:nil)
            }
            
        }
        
    }
    
    func treeView(_ treeView: RATreeView, numberOfChildrenOfItem item: Any?) -> Int {
        var i=0
        if item == nil {
            i = purchaseList.count
        }else if item is Purchase {
            let currPurchase = item as! Purchase
            let childs = getChildren(currPurchase.id)
            i = Int (childs.count)
            
        }
        
        return i
    }
    // helper func to filter the child nodes
    func getChildren(_ purchaseId: Int) -> [PurchaseProduct]{
        return purchaseProductList.filter(){$0.purchase_id == purchaseId}
    }
    
    func treeView(_ treeView: RATreeView, child index: Int, ofItem item: Any?) -> Any {
        var childToReturn : AnyObject = NSObject()
        if item == nil{
            let b = purchaseList[Int(index)]
            childToReturn = b
        }else if item is Purchase{
            let currPurchase = item as! Purchase
            let childs = getChildren(currPurchase.id)
            let s = childs[Int(index)]
            childToReturn = s
            
        }
        return childToReturn
    }
    func treeView(_ treeView: RATreeView, cellForItem item: Any?) -> UITableViewCell {
        var cell = UITableViewCell()
        //treeView.separatorStyle = RATreeViewCellSeparatorStyleSingleLine
        let level = treeView.levelForCell(forItem: item)
        
        if level == 0{
            let dateMaker = DateFormatter()
            dateMaker.dateFormat = "dd.MM.YYYY"
            let purchaseCell = treeView.dequeueReusableCell(withIdentifier: headerCellId) as! PurchaseHeaderCell
            let date = Date(timeIntervalSince1970: TimeInterval((item as! Purchase).date))
            purchaseCell.dateLabel.text = "\(dateMaker.string(from: date)) "
            purchaseCell.addItemButton.tag = (item as! Purchase).id
            purchaseId = (item as! Purchase).id
            purchaseCell.addItemButton.addTarget(self, action:#selector(PurchaseViewController.addItemClick(_:)), for: .touchUpInside)
            selectedPurchase = (item as! Purchase)
            cell = purchaseCell
        }else if level == 1{
            let itemsCell = treeView.dequeueReusableCell(withIdentifier: detailCellId) as! PurchaseProductCell
            itemsCell.productLabel.text = "\((item as! PurchaseProduct).getProductName())"
            itemsCell.amountLabel.text = "\((item as! PurchaseProduct).amount)"
            let curItem = item as! PurchaseProduct
            if let _ = curItem as? PurchasePesticide {
                itemsCell.backgroundColor = UIColor.orange
            }else {
                itemsCell.backgroundColor = UIColor.green
            }
            //vqCell.chkSelected.tag = (item as! VQuarter).id!
            //vqCell.chkSelected.addTarget(self, action:"chkVquarterClick:", forControlEvents: .TouchUpInside)
            
            cell = itemsCell
            
        }
        return cell
    }
    func treeView(_ treeView: RATreeView!, didSelectRowForItem item: Any!) {
        if treeView.levelForCell(forItem: item) == 1 {
            selectedProduct = (item as! PurchaseProduct)
            showAmountWindow(selectedProduct!)
            
        }
    }
    
    func treeView(_ treeView: RATreeView, commit editingStyle: UITableViewCell.EditingStyle, forRowForItem item: Any) {
        guard editingStyle == .delete else { return; }
        let level = treeView.levelForCell(forItem: item)
        var parent : AnyObject?
        if level == 0 {
            let item = item as! Purchase
            purchaseList = purchaseList.filter() {$0.id != item.id}
            purchaseProductList = purchaseProductList.filter() {$0.purchase_id != item.id}
            PurchaseDataHelper.deletePurWithRefs(item)
        }else if level == 1 {
            let item = item as! PurchaseProduct
            parent = treeView.parent(forItem: item) as AnyObject?
            if let isPurPest = item as? PurchasePesticide {
                PurchasePestDataHelper.delete(isPurPest)
                
            }else if let isFerPest = item as? PurchaseFertilizer{
                PurchaseFertDataHelper.delete(isFerPest)
            }
            purchaseProductList.removeAll()
            let curPestList = PurchasePestDataHelper.findAll()
            let curFertList = PurchaseFertDataHelper.findAll()
            fillProductList(curPestList!)
            fillProductList(curFertList!)
        }
        
       
       treeView.reloadData()
        if level == 1 {
            treeView.expandRow(forItem: parent)
        }
        
        
    }
    func treeView(_ treeView: RATreeView!, titleForDeleteConfirmationButtonForRowForItem item: Any!) -> String! {
        return "Löschen"
    }
    
    
    @objc func addItemClick(_ sender:AnyObject){
       // print("addItemButton clicked for id: \((sender as! UIButton).tag)")
        performSegue(withIdentifier: "purchaseSegue", sender: nil)
    }

    func loadData() {
        purchaseList = PurchaseDataHelper.findAll()!
        let curPestList = PurchasePestDataHelper.findAll()
        let curFertList = PurchaseFertDataHelper.findAll()
        fillProductList(curPestList!)
        fillProductList(curFertList!)
    }
    func fillProductList(_ data: [PurchaseProduct]) {
        for item in data {
            purchaseProductList.append(item)
        }
    }
    func showAmountWindow (_ curProduct: PurchaseProduct) {
        let popoverContent = self.storyboard?.instantiateViewController(withIdentifier: "inputPurchase") as! InputPurchaseAmountViewController
        let nav = UINavigationController(rootViewController: popoverContent)
        nav.modalPresentationStyle = UIModalPresentationStyle.popover
        let popover = nav.popoverPresentationController
        popoverContent.preferredContentSize = CGSize(width: 280,height: 150)
        popoverContent.title = curProduct.getProductName()
        popoverContent.amount = curProduct.amount
        popoverContent.getPurchaseAmountDelegate = self
        popover!.sourceRect = CGRect(x: 280,y: 150,width: 0,height: 0)
        popover!.delegate = self
        popover!.sourceView = self.view
        self.present(nav, animated: true, completion: nil)
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        // Return no adaptive presentation style, use default presentation behaviour
        return .none
    }
    
    // callback from InputPurchaseAmountVC
    func getPurchaseAmount(_ amount: Double) {
        selectedProduct?.amount = amount
        if let isPest = selectedProduct as? PurchasePesticide {
            PurchasePestDataHelper.update(isPest)
            
        }
        if let isFert = selectedProduct as? PurchaseFertilizer {
            PurchaseFertDataHelper.update(isFert)
        }
        
        let parent = table.parent(forItem: selectedProduct)
        table.reloadRows()
        table.expandRow(forItem: parent)
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "purchaseSegue":
                let vc = segue.destination as? PesticideFertilizerController
                vc?.callingSource = Constants.Purchase
                vc?.purchaseProducts = self.purchaseProductList
                vc?.purchaseId = self.purchaseId
                vc?.getPurchaseDelegate = self
               // vc?.pestFertDelegate = self
                               
            default: break
            }
            
        }
        
    }
    // MARK: Delegate from PesticideFertilizerController
    func getPurchaseList(_ purchaseList: [PurchaseProduct]) {
        purchaseProductList = purchaseList
        table.reloadData()
        table.expandRow(forItem: selectedPurchase)
        
    }
}
