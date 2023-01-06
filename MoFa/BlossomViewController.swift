//
//  BlossomViewController.swift
//  MoFa
//
//  Created by Arnold Schmid on 29.11.16.
//  Copyright © 2016 Arnold Schmid. All rights reserved.
//

import UIKit
import RATreeView

class BlossomViewController: UIViewController, RATreeViewDataSource, RATreeViewDelegate, BlossCellProtocol,UIPopoverPresentationControllerDelegate,VegDataInputDelegate{
    let cropAmountValues = Array(1...150)
    let numberPickerView : UIPickerView = UIPickerView()
    var table : RATreeView!
    var dicOfBlossomStart = [String:String]()
    var dicOfBlossomEnd = [String:String]()
    var dicOfHarvestStart = [String:String]()
    var dicOfCropAmount = [String:String]()
    var selectedTextField : UITextField!
    var curData : String?
    var curVqId:Int?
    var curLand: Land?
    var curMoment = Moment.blossomStart
    let anlagen = LandDataHelper.findAll()
    let sortenquartiere = VQuarterDataHelper.findAll()
    let headerCellId = "blossLandCell"
    let detailCellId = "blossVquarterCell"
    @IBOutlet weak var tableView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDataFromDb()
        table = RATreeView(frame:tableView.bounds)
        table.dataSource = self
        table.delegate = self
        table.autoresizingMask = UIView.AutoresizingMask(rawValue:UIView.AutoresizingMask.flexibleWidth.rawValue | UIView.AutoresizingMask.flexibleHeight.rawValue)
        let headerCell = UINib(nibName: "blossomLandCell", bundle:nil)
        let detailCell = UINib(nibName: "blossomVquarterCell", bundle:nil)
        table.register( headerCell, forCellReuseIdentifier: headerCellId)
        table.register(detailCell, forCellReuseIdentifier: detailCellId)
        //table.rowHeight = 43
        tableView.addSubview(table)
        table.reloadData()// Do any additional setup after loading the view.
        numberPickerView.delegate = self
        numberPickerView.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadDataFromDb(){
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
    }
    func saveDataToDb(dic:[String:String], typeInfo:String) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dic, options: JSONSerialization.WritingOptions())
            let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
            let entry = GlobalData()
            entry.typeInfo = typeInfo
            entry.data = jsonString
            GlobalDataHelper.saveBlossomData(item: entry, type: typeInfo)
            
        }catch {
            print(error.localizedDescription)
        }
    }
    func getDicFromJson (jsonString: String) -> [String:String] {
        
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
    //MARK: - Saving Data to DB
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        saveDataToDb(dic: dicOfBlossomStart, typeInfo: Constants.GlobalDataType.BlossomStart.rawValue)
        saveDataToDb(dic: dicOfBlossomEnd,typeInfo:Constants.GlobalDataType.BlossomEnd.rawValue)
        saveDataToDb(dic: dicOfHarvestStart,typeInfo:Constants.GlobalDataType.HarvestStart.rawValue)
        saveDataToDb(dic: dicOfCropAmount, typeInfo: Constants.GlobalDataType.CropAmount.rawValue)
    }
    //MARK: - DataSource, Delegate of RATreeView
    func treeView(_ treeView: RATreeView!, numberOfChildrenOfItem item: Any!) -> Int {
        var i = 0
        if item == nil {
            i = Int (anlagen!.count)
        }else if item is Land {
            let currAnlage = item as! Land
            let vqs = filterSQ(currAnlage.id!)
            i = Int (vqs.count)
            
        }
        return i
    }
    func treeView(_ treeView: RATreeView!, child index: Int, ofItem item: Any!) -> Any! {
        var childToReturn : AnyObject = NSObject()
        if item == nil{
            let b = anlagen?[Int(index)]
            childToReturn = b!
        }else if item is Land{
            let currentAnlage = item as! Land
            let vqs = filterSQ(currentAnlage.id!)
            let s = vqs[Int(index)]
            childToReturn = s
            
        }
        
        return childToReturn
    }
    func treeView(_ treeView: RATreeView!, cellForItem item: Any!) -> UITableViewCell! {
        var cell = UITableViewCell()
        //treeView.separatorStyle = RATreeViewCellSeparatorStyleSingleLine
        let level = treeView.levelForCell(forItem: item)
        
        if level == 0{
            let anlagenCell = treeView.dequeueReusableCell(withIdentifier: headerCellId) as! BlossomLandCell
            anlagenCell.landLabel.text = "\((item as! Land).name!)"
            
            
            cell = anlagenCell
        }else if level == 1{
            let vqCell = treeView.dequeueReusableCell(withIdentifier: detailCellId) as! BlossomVquarterCell
            vqCell.cellDelegate = self
            vqCell.vquarterLabel.text = "\((item as! VQuarter).name!) \((item as! VQuarter).plantYear!)"
            vqCell.blossomStartText.tag = (item as! VQuarter).id!
            vqCell.blossomStartText.text = ""
            vqCell.blossomEndText.text = ""
            vqCell.harvestStartText.text = ""
            vqCell.crospAmountText.text = ""
            if let startBlossDate = dicOfBlossomStart[String((item as! VQuarter).id!)] {
                vqCell.blossomStartText.text = formatDateValue(dateStr:startBlossDate)
            }
            if let endBlossDate = dicOfBlossomEnd[String((item as! VQuarter).id!)] {
                vqCell.blossomEndText.text = formatDateValue(dateStr:endBlossDate)
            }
            if let startHarvestDate = dicOfHarvestStart[String((item as! VQuarter).id!)]{
                vqCell.harvestStartText.text = formatDateValue(dateStr:startHarvestDate)
            }
            if let cropAmount = dicOfCropAmount[String((item as! VQuarter).id!)]{
                vqCell.crospAmountText.text = cropAmount
            }
            cell = vqCell
            
        }
        return cell
    }
    func treeView(_ treeView: RATreeView!, didSelectRowForItem item: Any!) {
        if treeView.levelForCell(forItem: item) == 1 {
            let selectedVQuarter = (item as! VQuarter)
            print("current vquarter = \(selectedVQuarter.id!)")
            }
        
    }
    func treeView(_ treeView: RATreeView!, commit editingStyle: UITableViewCell.EditingStyle, forRowForItem item: Any!) {
        
        guard editingStyle == .delete else { return; }
        let level = treeView.levelForCell(forItem: item)
        var parent : AnyObject?
        
        
            
            
        if level == 1 {
            parent = treeView.parent(forItem: item) as AnyObject?
            let item = item as! VQuarter
            dicOfBlossomStart.removeValue(forKey: String(item.id!))
            dicOfBlossomEnd.removeValue(forKey:String(item.id!))
            dicOfHarvestStart.removeValue(forKey: String(item.id!))
            dicOfCropAmount.removeValue(forKey: String(item.id!))        }
        
        
        treeView.reloadData()
        if level == 1 {
            treeView.expandRow(forItem: parent)
        }
        

    }
    func treeView(_ treeView: RATreeView!, editActionsForItem item: Any!) -> [Any]! {
        let level = treeView.levelForCell(forItem: item)
        if level == 0 {
            let def = UITableViewRowAction(style: .normal, title: "Setzen") { action, index in
                print("Setzen button tapped")
                self.curLand = item as? Land
                self.showVegDataInputViewController(landName: (self.curLand?.name!)!)
            }
            
            def.backgroundColor = UIColor.lightGray
            let del = UITableViewRowAction(style: .normal, title: "Leeren") { action, index in
                let land = item as! Land
                let filteredSq = self.filterSQ(land.id!)
                for vq in filteredSq {
                    self.dicOfBlossomStart.removeValue(forKey: String(vq.id!))
                    self.dicOfBlossomEnd.removeValue(forKey:String(vq.id!))
                    self.dicOfHarvestStart.removeValue(forKey: String(vq.id!))
                    self.dicOfCropAmount.removeValue(forKey: String(vq.id!))
                    treeView.reloadData()
                }
                treeView.expandRow(forItem: land)
                
            }
            
            del.backgroundColor = UIColor.red
            return [def,del]
        }
        return nil
    }
    func treeView(_ treeView: RATreeView!, titleForDeleteConfirmationButtonForRowForItem item: Any!) -> String! {
        return "Leeren"
    }
    func treeView(_ treeView: RATreeView!, canEditRowForItem item: Any!) -> Bool {
        return true
    }
    
    
    func filterSQ(_ anlageid: Int) -> [VQuarter]{
        return sortenquartiere!.filter {$0.landId == anlageid}
    }
    func showVegDataInputViewController(landName:String){
        let popoverContent = self.storyboard?.instantiateViewController(withIdentifier: "VegInputViewController") as! VegDataInputViewController
        let nav = UINavigationController(rootViewController: popoverContent)
        nav.modalPresentationStyle = UIModalPresentationStyle.popover
        let popover = nav.popoverPresentationController
        popoverContent.preferredContentSize = CGSize(width: 300,height: 300)
        
        popoverContent.title = landName
        popoverContent.delegate = self
        
        popover!.delegate = self
        popover!.sourceView = self.view
        popover!.sourceRect = CGRect(x: 300,y:300,width: 0,height: 0)
        
        self.present(nav, animated: true, completion: nil)
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        // Return no adaptive presentation style, use default presentation behaviour
        return .none
    }
    //callback(delegate) from VegeDataInputViewController
    func getVegData(data: String, timePoint: Moment) {
        let filteredSq = self.filterSQ((curLand?.id!)!)
        for vq in filteredSq{
            setDataForVq(data: data, timePoint: timePoint, vq: vq)
        }
        table.reloadData()
        table.expandRow(forItem: curLand)
        
    }
    func setDataForVq(data:String,timePoint:Moment, vq:VQuarter){
        switch timePoint {
        case .blossomStart:
            dicOfBlossomStart[String(vq.id!)] = data
            
        case .blossomEnd:
                dicOfBlossomEnd[String(vq.id!)] = data
            
            
        case .harvestStart:
        
                dicOfHarvestStart[String(vq.id!)] = data
        
        case .crospAmount:
        
                dicOfCropAmount[String(vq.id!)] = data
        
        }
    }

    /*
    // MARK: - locale functions
    */
    func anlageAddClick(_ sender:AnyObject){
        let button = sender as! CheckBox
        _ = filterSQ (button.tag)
        print ("TODO - Setting blossomDate for all vquarter of this land")
    }
    // MARK - delegates from tableCellView
    func didEditingCell(vqid: Int, timePoint: Moment, sender: UITextField) {
        selectedTextField = sender
        curMoment = timePoint
        curVqId = vqid
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        var date = Date() //setting the default date
        
        switch curMoment {
        case .blossomStart:
             if let currentDateStr = dicOfBlossomStart[String(curVqId!)] {
                date = dateFormatter.date(from: currentDateStr)!
             }
             showDatePicker(sender: selectedTextField, curDate: date)
        case .blossomEnd:
            if let currentDateStr = dicOfBlossomEnd[String(curVqId!)] {
                date = dateFormatter.date(from: currentDateStr)!
            }
            showDatePicker(sender: selectedTextField, curDate: date)
        case .harvestStart:
            if let currentDateStr = dicOfHarvestStart[String(curVqId!)] {
                date = dateFormatter.date(from: currentDateStr)!
            }
            showDatePicker(sender: selectedTextField, curDate: date)
        case .crospAmount :
            showNumberPicker(sender: selectedTextField)
            
        }
        
        
       

    }
    func showDatePicker(sender : UITextField, curDate: Date){
        let datePickerView  : UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePicker.Mode.date
        datePickerView.setDate(curDate, animated: false)
        datePickerView.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Fertig", style: UIBarButtonItem.Style.plain, target: self, action: #selector(doneAction))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Leeren", style: UIBarButtonItem.Style.plain, target: self, action: #selector(clearAction))
        
        
        toolBar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        toolBar.isUserInteractionEnabled = true
        sender.inputView = datePickerView
        sender.inputAccessoryView = toolBar
        datePickerWillShow(datePicker: datePickerView)
    }
    func showNumberPicker(sender : UITextField){
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        //setting a title for numberPicker
        let titleLabel = UILabel(frame:CGRect(x: 0.00, y: 0.00, width: 200.00, height: 20.00))
        titleLabel.text = "Menge in Tonnen"
        titleLabel.textAlignment = .center
        //adding buttons and spaces
        let toolBarTitle = UIBarButtonItem(customView: titleLabel)
        let doneButton = UIBarButtonItem(title: "Fertig", style: UIBarButtonItem.Style.plain, target: self, action: #selector(doneAction))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let cancelButton = UIBarButtonItem(title: "Leeren", style: UIBarButtonItem.Style.plain, target: self, action: #selector(clearAction))
        
        toolBar.setItems([doneButton,spaceButton,toolBarTitle,spaceButton,cancelButton], animated: false)
        
        toolBar.isUserInteractionEnabled = true
        sender.inputView = numberPickerView
        sender.inputAccessoryView = toolBar
        if let currentValue = dicOfCropAmount[String(curVqId!)] { //existing entry
            numberPickerView.selectRow(Int (currentValue)! - 1, inComponent: 0, animated: true)
        }else {
            numberPickerView.selectRow(50 - 1, inComponent: 0, animated: true)
        }
        pickerViewWillShow(pickerView: numberPickerView)
    }
    @objc func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        curData = dateFormatter.string(from: sender.date)
        selectedTextField.text = formatDateValue(dateStr: curData!)
        
    }
    @objc func doneAction(){
        selectedTextField.resignFirstResponder()
        
        switch curMoment {
            case .blossomStart:
                if curData != nil {
                    dicOfBlossomStart[String(curVqId!)] = curData!
                    datePickerWillHide()
                }
             case .blossomEnd:
                if curData != nil {
                    dicOfBlossomEnd[String(curVqId!)] = curData!
                    datePickerWillHide()
                }
            case .harvestStart:
                if curData != nil {
                    dicOfHarvestStart[String(curVqId!)] = curData!
                    datePickerWillHide()
                }
            case .crospAmount:
                if curData != nil {
                    dicOfCropAmount[String(curVqId!)] = curData!
                    datePickerWillHide()
            }
            
        }
        
    }
    @objc func clearAction() {
        
        switch curMoment {
        case .blossomStart:
            
                dicOfBlossomStart.removeValue(forKey: String(curVqId!))
            
        case .blossomEnd:
            
                dicOfBlossomEnd.removeValue(forKey: String(curVqId!))
        case .harvestStart:
                dicOfHarvestStart.removeValue(forKey: String(curVqId!))
        case .crospAmount:
            dicOfCropAmount.removeValue(forKey: String(curVqId!))
            
        }
        
        selectedTextField.text = ""
        selectedTextField.resignFirstResponder()
        
    
    }
    //MARK: - Helper function to format the date-String, returning only the day.month
    func formatDateValue(dateStr: String) -> String {
        let endIndex = dateStr.index(dateStr.endIndex, offsetBy: -5)
        let truncated = String(dateStr[..<endIndex])
        return truncated
    }
    
    //MARK: - Datepicker Show and Hide Methods
    func datePickerWillShow(datePicker:UIDatePicker)
    {
        let additionalSpace: CGFloat = 50 //needed for UIDatePicker height, so that the scrollPos is OK
        let kbSize = datePicker.frame.size
        
        //kbSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.size
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height + additionalSpace, right: 0)
        
        self.table.contentInset = contentInsets
        self.table.scrollIndicatorInsets = contentInsets
        
        var aRect = self.table.frame
        aRect.size.height -= kbSize.height
    }
    
    func datePickerWillHide()
    {
        let contentInsets = UIEdgeInsets.zero
        self.table.contentInset = contentInsets
        self.table.scrollIndicatorInsets = contentInsets
    }
    func pickerViewWillShow(pickerView:UIPickerView){
        let additionalSpace: CGFloat = 50 //needed for UIPickerView height, so that the scrollPos is OK
        let kbSize = pickerView.frame.size
        
        //kbSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.size
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height + additionalSpace, right: 0)
        
        self.table.contentInset = contentInsets
        self.table.scrollIndicatorInsets = contentInsets
        
        var aRect = self.table.frame
        aRect.size.height -= kbSize.height
    }
    
    @IBAction func uploadBarButtonClicked(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "MoFa", message: "Alle Jahresdaten werden gesendet. Möchten Sie fortfahren!", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "Ja", style: .default,handler: startUpload)
        let CancelAction = UIAlertAction(title: "Nein", style: .default, handler: nil)
        alertController.addAction(OKAction)
        alertController.addAction(CancelAction)
        self.present(alertController, animated: true, completion:nil)
    }
    
    func startUpload(_ alert: UIAlertAction!){
        let backend = Settings.getBackendSoftware()
        switch backend {
        case .asa:
            if Util.connectedToNetwork() == true {
                let priority = DispatchQoS.QoSClass.default
                DispatchQueue.global(qos: priority).async {
                    
                    GenerateFile.createVegDataAsaXml()
                    sleep(1)
                    DispatchQueue.main.async {
                        
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
                    
                    GenerateFile.createVegDataExcelXml()
                    sleep(1)
                    DispatchQueue.main.async {
                       
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
}
extension BlossomViewController: UIPickerViewDataSource {
   
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return cropAmountValues.count
    }
}

extension BlossomViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return cropAmountValues[row].description
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedTextField.text = cropAmountValues[row].description
        curData = selectedTextField.text
    }
    
}
