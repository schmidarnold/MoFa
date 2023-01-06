//
//  VegDataInputViewController.swift
//  MoFa
//
//  Created by Arnold Schmid on 22.12.16.
//  Copyright © 2016 Arnold Schmid. All rights reserved.
//

import UIKit
protocol VegDataInputDelegate{
    func getVegData(data : String, timePoint: Moment)
}
class VegDataInputViewController: UIViewController {
    let datePickerView  : UIDatePicker = UIDatePicker()
    let cropAmountValues = Array(1...150)
    let numberPickerView : UIPickerView = UIPickerView()
    var delegate: VegDataInputDelegate?
    @IBOutlet weak var pickerView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numberPickerView.delegate = self
        numberPickerView.dataSource = self
        
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        segmentedControl.selectedSegmentIndex = 0
        segIndexChanged(segmentedControl)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func okButtonClicked(_ sender: UIButton) {
        switch segmentedControl.selectedSegmentIndex{
        case 0:
           // print ("Date for \(Moment.blossomStart) = \(getSelectedDate())")
            delegate?.getVegData(data: getSelectedDate(), timePoint: Moment.blossomStart)
        case 1:
           // print ("Date for \(Moment.blossomEnd) = \(getSelectedDate())")
            delegate?.getVegData(data: getSelectedDate(), timePoint: Moment.blossomEnd)
        case 2:
           // print ("Date for \(Moment.harvestStart) = \(getSelectedDate())")
             delegate?.getVegData(data: getSelectedDate(), timePoint: Moment.harvestStart)
        case 3:
          // print ("Selected value for \(Moment.crospAmount)\(cropAmountValues[numberPickerView.selectedRow(inComponent: 0)])")
             delegate?.getVegData(data: (cropAmountValues[numberPickerView.selectedRow(inComponent: 0)].description) , timePoint: Moment.crospAmount)
        default:
            break
        }
        self.dismiss(animated: false, completion: nil)
    }

    @IBAction func cancelButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    func getSelectedDate()-> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let curData = dateFormatter.string(from: datePickerView.date)
        return curData
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    // MARK: - IBActions for Controls
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var labelSelSegment: UILabel!
    
    @IBAction func segIndexChanged(_ sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex{
        case 0:
            labelSelSegment.text = "Blühbeginn"
            showDatePicker(sender: sender)
        case 1:
            labelSelSegment.text = "Blühende"
            showDatePicker(sender: sender)
        case 2:
            labelSelSegment.text = "Erntebeginn"
            showDatePicker(sender: sender)
        case 3:
            labelSelSegment.text = "Ernteschätzung"
            showNumberPicker(sender: sender)
        default:
            break
        }
    }
    func showDatePicker(sender: UISegmentedControl){
        clearPickerView(containerView: pickerView)
        datePickerView.datePickerMode = UIDatePicker.Mode.date
        datePickerView.frame = CGRect(x: 0, y: 0, width: pickerView.frame.width, height: pickerView.frame.height)
        
        pickerView.addSubview(datePickerView)
        
        }
    func showNumberPicker(sender: UISegmentedControl){
        clearPickerView(containerView: pickerView)
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
        toolBar.setItems([toolBarTitle], animated: false)
        
        toolBar.isUserInteractionEnabled = false
        numberPickerView.frame = CGRect(x: 0, y: 0, width: pickerView.frame.width, height: pickerView.frame.height)
        numberPickerView.selectRow(50 - 1, inComponent: 0, animated: true)
        numberPickerView.addSubview(toolBar)
        pickerView.addSubview(numberPickerView)
    }
    func clearPickerView(containerView: UIView) {
        for v in containerView.subviews{
            v.removeFromSuperview()
        }
    }
    
    
}
extension VegDataInputViewController : UIPickerViewDelegate,UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return cropAmountValues.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return cropAmountValues[row].description
        
    }
    
    
}
