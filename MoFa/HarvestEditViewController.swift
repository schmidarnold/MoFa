//
//  HarvestEditViewController.swift
//  MoFa
//
//  Created by Arnold Schmid on 09.11.15.
//  Copyright © 2015 Arnold Schmid. All rights reserved.
//

import UIKit
protocol getHarvestEntryDelegate {
    func getHarvestData(_ data: Harvest, row: Int?)
}
class HarvestEditViewController: UIViewController, UIPopoverPresentationControllerDelegate,getQualityDelegate, UITextFieldDelegate{
    
    @IBOutlet weak var datumTxt: UITextField!
    @IBOutlet weak var liefernrTxt: UITextField!
    
    @IBOutlet weak var turnSegControl: UISegmentedControl!
    @IBOutlet weak var kistenTxt: UITextField!
    @IBOutlet weak var bemerkungtxt: UITextField!
    @IBOutlet weak var kategorieTxt: UITextField!
    @IBOutlet weak var mengeTxt: UITextField!
    
    @IBOutlet weak var zuckerTxt: UITextField!
    @IBOutlet weak var saureTxt: UITextField!
    @IBOutlet weak var phenolTxt: UITextField!
    @IBOutlet weak var phTxt: UITextField!
    var row: Int?
    var harvest : Harvest = Harvest()
    var newEntry : Bool = false
    var harvestEntryDelegate : getHarvestEntryDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Übernehmen", style: UIBarButtonItem.Style.plain, target: self, action: #selector(HarvestEditViewController.save(_:)))
               let newCancelButton = UIBarButtonItem(title: "Abbrechen", style: UIBarButtonItem.Style.plain, target: self, action: #selector(HarvestEditViewController.cancel(_:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        self.navigationItem.rightBarButtonItem = newCancelButton
        if newEntry == false {
            loadData()
        }else{
            initData()
            
        }
        liefernrTxt.delegate = self
        kistenTxt.delegate = self
        bemerkungtxt.delegate = self
        mengeTxt.delegate = self
        zuckerTxt.delegate = self
        saureTxt.delegate = self
        phenolTxt.delegate = self
        phTxt.delegate = self
        // Do any additional setup after loading the view.
    }
    @objc func cancel(_ sender: UIBarButtonItem) {
        // nothing to do
        _ = self.navigationController?.popViewController(animated: true)
    }
    //saving data - click on Übernehmen
    @objc func save(_ sender: UIBarButtonItem) {
        if newEntry == false {
            readData() //reading all not already readed fields from harvest entry
            harvestEntryDelegate?.getHarvestData(harvest, row: row!)
            _ = self.navigationController?.popViewController(animated: true)
        } else {
            readData()
            if let _ = harvest.id { // check if id is set
                print("saving new entry")
                harvestEntryDelegate?.getHarvestData(harvest, row: row)
                _ = self.navigationController?.popViewController(animated: true)
            }else {
                let alertController = UIAlertController(title: "MoFa", message:
                    "Lieferscheinnr muss eingegeben werden!", preferredStyle: UIAlertController.Style.alert)
                alertController.addAction(UIAlertAction(title: "Schließen", style: UIAlertAction.Style.default,handler: nil))
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func loadData() {
        let dateMaker = DateFormatter()
        dateMaker.dateFormat = "dd.MM.YY"
        let datum = Date(timeIntervalSince1970: TimeInterval(harvest.date!))
        datumTxt.text = dateMaker.string(from: datum)
        liefernrTxt.text = harvest.id?.description
        mengeTxt.text = harvest.amount?.description
        kistenTxt.text = harvest.boxes?.description
        kategorieTxt.text = CategoryDataHelper.getQuality((harvest.categoryId)!)
        bemerkungtxt.text = harvest.note
        turnSegControl.selectedSegmentIndex = harvest.turn - 1
        zuckerTxt.text = harvest.sugar?.description
        saureTxt.text = harvest.acid?.description
        phenolTxt.text = harvest.phenol?.description
        phTxt.text = harvest.ph?.description
        
    }
    func initData() {
        let dateMaker = DateFormatter()
        dateMaker.dateFormat = "dd.MM.YYYY"
        let date = Date()
        datumTxt.text = dateMaker.string(from: date)
        harvest.date = Int(date.timeIntervalSince1970)
        if let (qualityId,qualityDesc) = CategoryDataHelper.findFirst() {
            kategorieTxt.text = qualityDesc
            harvest.categoryId = qualityId
        }
        harvest.turn = 1
    
    }
    func readData() {
        harvest.id = Int(liefernrTxt.text!)
        harvest.amount = Int(mengeTxt.text!)
        harvest.boxes = Int(kistenTxt.text!)
        harvest.note = bemerkungtxt.text!
        harvest.sugar = Double(zuckerTxt.text!)
        harvest.acid = Double(saureTxt.text!)
        harvest.phenol = Double(phenolTxt.text!)
        harvest.ph = Double(phTxt.text!)
    }
    @IBAction func datumChanged(_ sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        
        datePickerView.datePickerMode = UIDatePicker.Mode.date
        
        sender.inputView = datePickerView
        
        datePickerView.addTarget(self, action: #selector(HarvestEditViewController.datePickerValueChanged(_:)), for: UIControl.Event.valueChanged)
    }
    
    @IBAction func turnChanged(_ sender: UISegmentedControl) {
      harvest.turn = turnSegControl.selectedSegmentIndex + 1
      print("changed turn to \(turnSegControl.selectedSegmentIndex + 1)")
    }
    @IBAction func categoryChanged(_ sender: UITextField) {
        showQualityPopOver()
    }
    @objc func datePickerValueChanged(_ sender:UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.YY"
        harvest.date =  Int(sender.date.timeIntervalSince1970)
        datumTxt.text = dateFormatter.string(from: sender.date)
        
    }
    
    // MARK: - Show Quality Popover
    func showQualityPopOver() {
        let popoverContent = self.storyboard?.instantiateViewController(withIdentifier: "categoryList") as! CategoryViewController
        let nav = UINavigationController(rootViewController: popoverContent)
        nav.modalPresentationStyle = UIModalPresentationStyle.popover
        let popover = nav.popoverPresentationController
        popoverContent.preferredContentSize = CGSize(width: 280,height: 250)
        
        
        popoverContent.qualityDelegate = self
        popover!.delegate = self
        popover!.sourceView = self.view
        popover!.sourceRect = CGRect(x: 280,y: 250,width: 0,height: 0)
        
        self.present(nav, animated: true, completion: nil)
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        // Return no adaptive presentation style, use default presentation behaviour
        return .none
    }
    //callback, delegate from categoryViewController
    func getQuality(_ quality: String, qualityId: Int) {
        kategorieTxt.text = quality
        harvest.categoryId = qualityId
    }
    
    func animateTextField(_ textField: UITextField, up: Bool, withOffset offset:CGFloat)
    {
        let movementDistance : Int = -Int(offset)
        let movementDuration : Double = 0.4
        let movement : Int = (up ? movementDistance : -movementDistance)
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: CGFloat(movement))
        UIView.commitAnimations()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        self.animateTextField(textField, up: true, withOffset: textField.frame.origin.y / 3)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        self.animateTextField(textField, up: false, withOffset: textField.frame.origin.y / 3)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }


}
