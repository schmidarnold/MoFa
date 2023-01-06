//
//  HoursWorkerViewController.swift
//  MoFa
//
//  Created by Arnold Schmid on 10.02.16.
//  Copyright © 2016 Arnold Schmid. All rights reserved.
//

import UIKit

class HoursWorkerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var personLabel: UILabel!
    @IBOutlet weak var workerTableView: UITableView!
    @IBOutlet weak var fromDateTextView: UITextField!
    @IBOutlet weak var toDateTextView: UITextField!
    let workerList = WorkerDataHelper.findAll()
    override func viewDidLoad() {
        super.viewDidLoad()
        workerTableView.delegate = self
        workerTableView.dataSource = self
        fromDateTextView.text = returnStringDate(diffFromCurrentDate(-7))
        toDateTextView.text = returnStringDate(Date())
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func fromDateStartEditing(_ sender: UITextField) {
        sender.resignFirstResponder()
        let  curDate = returnDateFromString(sender.text!)
        DatePickerDialog().show("Startdatum", doneButtonTitle: "OK", cancelButtonTitle: "Abbrechen", defaultDate: curDate, datePickerMode: UIDatePicker.Mode.date){
         (date) -> Void in
            sender.text = self.returnStringDate(date)
        }

    }

    
    @IBAction func toDateStartEditing(_ sender: UITextField) {
        sender.resignFirstResponder()
        let  curDate = returnDateFromString(sender.text!)
        DatePickerDialog().show("Enddatum", doneButtonTitle: "OK", cancelButtonTitle: "Abbrechen", defaultDate: curDate, datePickerMode: UIDatePicker.Mode.date){
            (date) -> Void in
            sender.text = self.returnStringDate(date)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func returnStringDate(_ dateToConvert:Date) -> String {
        let dateMaker = DateFormatter()
        dateMaker.dateFormat = "dd.MM.yyyy"
        return dateMaker.string(from: dateToConvert)
        
    }
    func diffFromCurrentDate(_ daysToAdd:Int) -> Date {
        let calculatedDate = (Calendar.current as NSCalendar).date(byAdding: NSCalendar.Unit.day, value: daysToAdd, to: Date(), options: NSCalendar.Options.init(rawValue: 0))
        return calculatedDate!
    }
    func returnDateFromString(_ dateToConvert:String) -> Date {
        let dateMaker = DateFormatter()
        dateMaker.dateFormat = "dd.MM.yyyy"
        return dateMaker.date(from: dateToConvert)!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return workerList!.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",for: indexPath)
        let worker = workerList![indexPath.row]
        let outputString = "\(worker.lastName), \(worker.firstName!)"
        cell.textLabel?.text = outputString
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let person = workerList![indexPath.row]
        let outputString = "\(person.lastName), \(person.firstName!)"
        personLabel.text = outputString
        
        let date1 = returnDateFromString(fromDateTextView.text!)
        let date2 = returnDateFromString(toDateTextView.text!)
        let sumHours = MultQueries.sumOfHours(person.id, fromDate: date1, toDate: date2)
        hoursLabel.text = sumHours.description
    }
    

}
