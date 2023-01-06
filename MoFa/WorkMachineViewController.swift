//
//  WorkMachineViewController.swift
//  MoFa
//
//  Created by Arnold Schmid on 05.08.15.
//  Copyright (c) 2015 Arnold Schmid. All rights reserved.
//

import UIKit
import UIKit


class WorkMachineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate, returnDataSlider{
    var currentMachine = Machine()
    var defaultValue: Float = 8.0
    var workMachineDic = [Int:Double]()
    var delegate : getResourceDataDelegate?
    let machineList = MachineDataHelper.findAll()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "workerMachineCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return machineList!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var name = ""
        let cell:WorkerMachineCell = tableView.dequeueReusableCell(withIdentifier: "cell") as! WorkerMachineCell
        let machine = machineList![indexPath.row]
        cell.chkWorkerMachine.tag = machine.id
        cell.chkWorkerMachine.cellIndexPath = indexPath
        cell.chkWorkerMachine.addTarget(self, action: #selector(WorkMachineViewController.chkMachineClicked(_:)), for: .touchUpInside)
        if let _ = workMachineDic[machine.id] {
            cell.chkWorkerMachine.isChecked = true
            cell.lblhours.text = "\(workMachineDic[machine.id]!)"
        } else {
            cell.chkWorkerMachine.isChecked = false
            cell.lblhours.text = ""
        }
        name = "\(machine.name)"
        
        cell.lblName.text = name
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        currentMachine = machineList![indexPath.row]
        
        showSlider()
        
        
    }
    
    @objc func chkMachineClicked(_ sender: AnyObject) {
        let button = sender as! CheckBox
        print("selected machine with id \(button.tag)")
        let cellIndexPath = button.cellIndexPath
        let currentMachine = machineList![cellIndexPath!.row]
        let currentCell = tableView.cellForRow(at: cellIndexPath! as IndexPath) as! WorkerMachineCell?;
        if button.isChecked == true {
            currentCell?.lblhours.text = "\(defaultValue)"
        }else {
            currentCell?.lblhours.text = ""
        }
        addRemoveMachine(currentMachine, add: button.isChecked, hours: defaultValue)
        
        
    }
    
    func showSlider() {
        let popoverContent = self.storyboard?.instantiateViewController(withIdentifier: "sliderBox") as! SliderViewController
        let nav = UINavigationController(rootViewController: popoverContent)
        nav.modalPresentationStyle = UIModalPresentationStyle.popover
        let popover = nav.popoverPresentationController
        popoverContent.preferredContentSize = CGSize(width: 280,height: 150)
        popoverContent.title = currentMachine.name
        if let _ = workMachineDic[currentMachine.id] {
            popoverContent.defaultValue = Float (workMachineDic[currentMachine.id]!)
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
        addRemoveMachine(currentMachine, add: true, hours: value)
        
    }
    func addRemoveMachine(_ machine: Machine, add: Bool, hours: Float) {
        if add == true { //add or update
            workMachineDic[machine.id] = Double(hours)
            
        } else {
            workMachineDic.removeValue(forKey: machine.id)
        }
        
        
    }
    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        print(workMachineDic)
        delegate?.getResDictionary(workMachineDic,source: dataType.machine, lastUsedHour: defaultValue)
        print("WorkMachineViewController: Go back")
    }
}
