//
//  WorkWorkerMachineViewController.swift
//  MoFa
//
//  Created by Arnold Schmid on 17.07.15.
//  Copyright (c) 2015 Arnold Schmid. All rights reserved.
//

import UIKit


class WorkWorkerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate, returnDataSlider{
    var currentWorker = Worker()
    var defaultValue: Float = 8.0
    var workWorkerDic = [Int:Double]()
    var delegate : getResourceDataDelegate?
    let workerList = WorkerDataHelper.findAll()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "workerMachineCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workerList!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var name = ""
        let cell:WorkerMachineCell = tableView.dequeueReusableCell(withIdentifier: "cell") as! WorkerMachineCell
        let worker = workerList![indexPath.row]
        cell.chkWorkerMachine.tag = worker.id
        cell.chkWorkerMachine.cellIndexPath = indexPath
        cell.chkWorkerMachine.addTarget(self, action: #selector(WorkWorkerViewController.chkWorkerClicked(_:)), for: .touchUpInside)
        if let _ = workWorkerDic[worker.id] {
            cell.chkWorkerMachine.isChecked = true
            cell.lblhours.text = "\(workWorkerDic[worker.id]!)"
        } else {
            cell.chkWorkerMachine.isChecked = false
            cell.lblhours.text = ""
        }
        name = "\(worker.firstName!) \(worker.lastName)"
        
        cell.lblName.text = name
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        currentWorker = workerList![indexPath.row]
        
        showSlider()
        
        print("\(currentWorker.lastName)")
    }
    
    @objc func chkWorkerClicked(_ sender: AnyObject) {
        let button = sender as! CheckBox
        print("selected worker with id \(button.tag)")
        let cellIndexPath = button.cellIndexPath
        let currentWorker = workerList![cellIndexPath!.row]
        let currentCell = tableView.cellForRow(at: cellIndexPath! as IndexPath) as! WorkerMachineCell?;
        if button.isChecked == true {
            currentCell?.lblhours.text = "\(defaultValue)"
        }else {
            currentCell?.lblhours.text = ""
        }
        addRemoveWorker(currentWorker, add: button.isChecked, hours: defaultValue)
        
        
    }
    
    func showSlider() {
        let popoverContent = self.storyboard?.instantiateViewController(withIdentifier: "sliderBox") as! SliderViewController
        let nav = UINavigationController(rootViewController: popoverContent)
        nav.modalPresentationStyle = UIModalPresentationStyle.popover
        let popover = nav.popoverPresentationController
        popoverContent.preferredContentSize = CGSize(width: 280,height: 150)
        popoverContent.title = currentWorker.lastName
        if let _ = workWorkerDic[currentWorker.id] {
            popoverContent.defaultValue = Float (workWorkerDic[currentWorker.id]!)
        } else {
            popoverContent.defaultValue = self.defaultValue
        }
        
        popoverContent.delegate = self
        popover!.delegate = self
        popover!.sourceView = self.view
        popover!.sourceRect = CGRect(x: 280,y: 150,width: 0,height: 0)
        
        self.present(nav, animated: true, completion: nil)
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        // Return no adaptive presentation style, use default presentation behaviour
        return .none
    }
    
    func getHours(_ value: Float) {
        let cellIndexPath = tableView.indexPathForSelectedRow;
        let currentCell = tableView.cellForRow(at: cellIndexPath!) as! WorkerMachineCell?;
        self.defaultValue = value
        currentCell?.chkWorkerMachine.isChecked = true
        currentCell?.lblhours.text = "\(value)"
        addRemoveWorker(currentWorker, add: true, hours: value)
        
    }
    func addRemoveWorker(_ worker: Worker, add: Bool, hours: Float) {
        if add == true { //add or update
            workWorkerDic[worker.id] = Double(hours)
        } else {
            workWorkerDic.removeValue(forKey: worker.id)
        }
        for (workerid, workerhours) in workWorkerDic {
            print("\(workerid): \(workerhours)")
        }
        
    }
    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        delegate?.getResDictionary(workWorkerDic,source: dataType.worker, lastUsedHour: self.defaultValue)
        print("WorkWorkerViewController: Go back")
    }
    
    
}
