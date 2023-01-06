//
//  WorkEditViewController.swift
//  MoFa
//
//  Created by Arnold Schmid on 16.07.15.
//  Copyright (c) 2015 Arnold Schmid. All rights reserved.
//

import UIKit

class WorkEditViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDelegate, UITableViewDataSource, returnDataDelegate,UITextFieldDelegate,TaskPickerViewDelegate {
    var changed: Bool = false
    var work = Work()
    var curTask = Task()
    //var vqIds = Set<Int>()
    var curVQuarters = Array<VQuarter>()
    let taskList = TaskDataHelper.findAllSorted()
    //let taskList = TaskDataHelper.findAll()
    var tbvc = WorkTabBarController()
    fileprivate let pickerView = TaskPickerView()
    @IBOutlet weak var dateTextField: UITextField!
    
    @IBOutlet weak var workTextField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var noteTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        dateTextField.delegate = self
        noteTextField.delegate = self
        tbvc = self.tabBarController  as! WorkTabBarController
       
        tbvc.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Abbrechen", style: .done, target: self, action: #selector(WorkEditViewController.cancelData))
        let myBackButton = UIButton(type: UIButton.ButtonType.custom)
        myBackButton.addTarget(self, action: #selector(WorkEditViewController.saveData), for: UIControl.Event.touchUpInside)
        myBackButton.setTitle("Speichern", for: UIControl.State())
        myBackButton.setTitleColor(UIColor.blue, for: UIControl.State())
        myBackButton.sizeToFit()
        let myCustomBackButtonItem:UIBarButtonItem = UIBarButtonItem(customView: myBackButton)
        tbvc.navigationItem.leftBarButtonItem  = myCustomBackButtonItem
        if let _ = work.workId {
            tbvc.loadExistingData(work)
            // vqIds = WorkVQuarterDataHelper.getWorkVQuarter(workId)
            
            loadVQuarters(tbvc.curVQuarters)
            let x = Date(timeIntervalSince1970: TimeInterval(work.workDate!))
            formatLabelDate(x)
            curTask = TaskDataHelper.find(work.taskId!)!
            workTextField.text = curTask.work
            if let workTyp = (curTask.type) {
                if workTyp == "S" {
                    showSprayTabbar()
                }
                if workTyp == "H" {
                    showSprayTabbar()
                }
                if workTyp == "E" {
                    showHarvestTabbar()
                }
                if workTyp == "D" {
                    showSoilFertilizerTabbar()
                }
                if workTyp == "B" {
                    showWaterTabbar()
                }
            
            }
            noteTextField.text = work.note
        } else {
            
            let date = Date()
            if UserDefaults.standard.object(forKey: "lastTaskId") != nil {
                let taskId = UserDefaults.standard.integer(forKey: "lastTaskId")
                curTask = TaskDataHelper.find(taskId)!
            }else {
               curTask = (taskList?.first)!
            }
            
            if let workTyp = (curTask.type) {
                switch workTyp {
                    case "S", "H" :
                        showSprayTabbar()
                    case "E" :
                        showHarvestTabbar()
                    case "D" :
                        showSoilFertilizerTabbar()
                    case "B" :
                        showWaterTabbar()
                    default :
                        removeAdditionalTabbar()
                    
                }
                
            }
            tbvc.curWork.workDate = (Int(date.timeIntervalSince1970))
            tbvc.curWork.taskId = curTask.id
            self.workTextField.inputView = self.pickerView
            self.workTextField.inputAccessoryView = self.pickerView.toolbar

            self.pickerView.dataSource = self
            self.pickerView.delegate = self
            self.pickerView.toolbarDelegate = self

            self.pickerView.reloadAllComponents()
            workTextField.text = curTask.work
            formatLabelDate(date)
            
        }
    }
    
    @IBAction func noteTextDidChange(_ sender: UITextField) {
        saveNote()
    }
    func saveNote(){
        tbvc.curWork.note = noteTextField.text
    }
    @IBAction func dateFieldEditing(_ sender: UITextField) {
       // let datePickerView:UIDatePicker = UIDatePicker()
       // datePickerView.datePickerMode = UIDatePickerMode.Date
       // sender.inputView = datePickerView
       // datePickerView.addTarget(self, action: Selector("datePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        sender.resignFirstResponder()
        let curDate = returnDateFromString(sender.text!)
        DatePickerDialog().show("Datum", doneButtonTitle: "OK", cancelButtonTitle: "Abbrechen", defaultDate: curDate, datePickerMode: UIDatePicker.Mode.date){
            (date) -> Void in
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = DateFormatter.Style.medium
            dateFormatter.timeStyle = DateFormatter.Style.none
            self.formatLabelDate (date)
            self.tbvc.curWork.workDate = Int(date.timeIntervalSince1970)
        }
//        DatePickerDialog().show("Datum", doneButtonTitle: "OK", cancelButtonTitle: "Abbrechecn", datePickerMode: UIDatePickerMode.Date) {
//            (date) -> Void in
//            let dateFormatter = NSDateFormatter()
//            dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
//            dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
//            self.formatLabelDate (date)
//            self.tbvc.curWork.workDate = Int(date.timeIntervalSince1970)
//            
//        }
    }
    
    func datePickerValueChanged(_ sender:UIDatePicker) {
//        let dateFormatter = NSDateFormatter()
//        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
//        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
//        formatLabelDate (sender.date)
//        tbvc.curWork.workDate = Int(sender.date.timeIntervalSince1970)
       
        
        
    }
    
    @IBAction func workTaskFieldEditing(_ sender: UITextField) {

//        let toolBar = UIToolbar()
//        toolBar.barStyle = UIBarStyle.default
//        toolBar.isTranslucent = true
//        toolBar.tintColor = UIColor.green
//        toolBar.sizeToFit()
//
//        let workPickerView:UIPickerView  = UIPickerView(frame: CGRect(x: 0, y: toolBar.frame.size.height, width: view.frame.width, height: 180))
//        workPickerView.tintColor = UIColor.green
//        workPickerView.showsSelectionIndicator = true
//        workPickerView.delegate = self
//        workPickerView.dataSource = self
//
//        let bgView = UIView(frame: CGRect(x: 0, y: 180, width: view.frame.width, height: 180 + toolBar.frame.size.height))
//
//        let doneButton = UIBarButtonItem(title: "Fertig", style: UIBarButtonItemStyle.plain, target: self, action: #selector(WorkEditViewController.donePicker))
//        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
//
//        toolBar.setItems([ spaceButton, doneButton], animated: false)
//        toolBar.isUserInteractionEnabled = true
//        bgView.addSubview(toolBar)
//        bgView.addSubview(workPickerView)
//
        
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.toolbarDelegate = self
        sender.inputAccessoryView = self.pickerView.toolbar
        sender.inputView = self.pickerView
        
    }
    @objc func didTapDone() {
        let row = self.pickerView.selectedRow(inComponent: 0)
        self.pickerView.selectRow(row, inComponent: 0, animated: false)
        self.workTextField.text = self.taskList![row].work
        self.workTextField.resignFirstResponder()
        print ("done")
        //workTextField.resignFirstResponder()
    }
    @objc func didTapCancel() {
           print ("cancel")
           self.workTextField.text = nil
           self.workTextField.resignFirstResponder()
        
    }
    //MARK: Save Data using the worktabcontroller
    @objc func saveData() {
        
        
        tbvc.saveData()
    }
    @objc func cancelData() {
        tbvc.cancelData()
    }
    //MARK: - Delegates and data sources
    //MARK: Data Sources
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return taskList!.count
    }
    //MARK: Delegates
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
               return taskList![row].work
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
      //  println("value of global workid before cahange local object = \(tbvc.curWork.taskId)")
        tbvc.curWork.taskId = (taskList![row].id)
      //  println("value of global workid after change local object= \(tbvc.curWork.taskId)")
        workTextField.text = (taskList![row].work)
        if let workTyp = (taskList![row].type) {
            switch workTyp {
            case "S", "H" :
                showSprayTabbar()
            case "E" :
                showHarvestTabbar()
            case "D" :
                showSoilFertilizerTabbar()
            case "B":
                showWaterTabbar()
            default :
                removeAdditionalTabbar()
                
            }
        }
        //pickerView.hidden=true
        //workTextField.resignFirstResponder()
    }
    
    func formatLabelDate(_ currentDate : Date){
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "de_DE")
        dateFormatter.dateFormat = "dd.MM.yy"
       // dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        //dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
    
        let strDate = dateFormatter.string(from: currentDate)
        dateTextField.text = strDate
    
    
        }
    func returnDateFromString(_ dateToConvert:String) -> Date {
        let dateMaker = DateFormatter()
        dateMaker.dateFormat = "dd.MM.yy"
        return dateMaker.date(from: dateToConvert)!
    }
    
    func loadVQuarters(_ vqIds: Set<Int>) {
        
            curVQuarters = VQuarterDataHelper.findSelectedVquarters(vqIds)!
            tbvc.curVQuarters = vqIds
            tableView.reloadData()
        
        
    }
    //MARK: Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "VQuarterSegue":
                if let vc = segue.destination as? VQuarterViewController {
                    vc.checkedVQuarters = tbvc.curVQuarters
                    vc.delegate = self
                    print("prepare for segue: VQuarterSegue")
                    
                }
            default: break
            }
            
        }
    }
    //MARK: TableViews DataSource and Delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return curVQuarters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",for: indexPath)
        let vquarter = curVQuarters[indexPath.row]
        let landvquarter = LandDataHelper.find(vquarter.landId!)
        let outputString = "\(landvquarter!.name!), \(vquarter.name!), \(vquarter.plantYear!)"
        cell.textLabel!.text = outputString
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Row \(indexPath.row) selected")
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if (editingStyle == UITableViewCell.EditingStyle.delete) {
            let vqid = curVQuarters[indexPath.row].id
            tbvc.curVQuarters.remove(vqid!)
            curVQuarters.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            
        }
    }
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Löschen"
    }
    func showSprayTabbar(){
        tbvc.addTabBar()
    
    }
    func showHarvestTabbar(){
        tbvc.addHarvestTabBar()
    }
    func showSoilFertilizerTabbar() {
        tbvc.addSoilFertilizerTabBar()
    }
    func showWaterTabbar() {
        tbvc.addWaterTabBar()
    }
    func removeAdditionalTabbar() {
        tbvc.remprevTabBar()
    }
    //delegate for not show textField
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
}
//WorkTaskPickerView
protocol TaskPickerViewDelegate: class {
    func didTapDone()
    func didTapCancel()
}

class TaskPickerView: UIPickerView {

    public private(set) var toolbar: UIToolbar?
    public weak var toolbarDelegate: TaskPickerViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    private func commonInit() {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = .black
        toolBar.sizeToFit()

        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.doneTapped))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancelTapped))

        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true

        self.toolbar = toolBar
    }

    @objc func doneTapped() {
        self.toolbarDelegate?.didTapDone()
    }

    @objc func cancelTapped() {
        self.toolbarDelegate?.didTapCancel()
    }
}
