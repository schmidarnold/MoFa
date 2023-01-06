//
//  WorkResourcesViewController.swift
//  MoFa
//
//  Created by Arnold Schmid on 28.07.15.
//  Copyright (c) 2015 Arnold Schmid. All rights reserved.
//

import UIKit

class WorkResourcesViewController: UIViewController, getResourceDataDelegate, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate, returnDataSlider {
    
    @IBOutlet weak var tableViewWorker: UITableView!
    
    @IBOutlet weak var tableViewMachine: UITableView!
    var currentWorkersForWorkIDs = [Int]()
    var currentMachinesForWorkIDs = [Int]()
    var currentTableView = UITableView()
    var tbvc = WorkTabBarController()
    var currentHourValue : Float = 8.0
    override func viewDidLoad() {
        tbvc = self.tabBarController  as! WorkTabBarController
        tableViewWorker.delegate = self
        tableViewWorker.dataSource = self
        tableViewMachine.delegate = self
        tableViewMachine.dataSource = self
        if tbvc.newEntry == false {
            
            currentWorkersForWorkIDs = [Int](tbvc.selectedWorkers.keys).sorted(by: <)
            currentMachinesForWorkIDs = [Int](tbvc.selectedMachines.keys).sorted(by: <)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "workerSegue":
                let vc = segue.destination as? WorkWorkerViewController
                vc!.workWorkerDic = tbvc.selectedWorkers
                vc!.defaultValue = currentHourValue
                vc!.delegate = self
            case "machineSegue":
                let vc = segue.destination as? WorkMachineViewController
                vc!.workMachineDic = tbvc.selectedMachines
                vc!.defaultValue = currentHourValue
                vc!.delegate = self
                
            
                
                
            default: break
            }
            
        }

    }
    //MARK: Delegate, CallBack from WorkWorker
    func getResDictionary(_ workerDic: [Int : Double], source : dataType, lastUsedHour : Float) {
        switch source{
            case .worker:
                currentHourValue = lastUsedHour
                tbvc.selectedWorkers = workerDic
                currentWorkersForWorkIDs = [Int](tbvc.selectedWorkers.keys).sorted(by: <)
                tableViewWorker.reloadData()
            case .machine:
                currentHourValue = lastUsedHour
                print("MachinesList returned: \(workerDic)")
                tbvc.selectedMachines = workerDic
                currentMachinesForWorkIDs = [Int](tbvc.selectedMachines.keys).sorted(by: <)
                tableViewMachine.reloadData()
            
        }
        
        
    }
    //MARK: Delegate, DataSource for tableViewWorker
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableViewWorker {
          return tbvc.selectedWorkers.count
        } else {
          return tbvc.selectedMachines.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",for: indexPath)
        if tableView == tableViewWorker {
            
            let curWorkerId = currentWorkersForWorkIDs[indexPath.row]
            
            //let workWorker = currentWorkersForWork[indexPath.row]
            let worker = WorkerDataHelper.find(curWorkerId)
            let outputString = "\(worker!.lastName), \(worker!.firstName!) - \(tbvc.selectedWorkers[curWorkerId]!)h"
            cell.textLabel!.text = outputString
        }
        if tableView == tableViewMachine {
            
            let curMachineId = currentMachinesForWorkIDs[indexPath.row]
            
            let machine = MachineDataHelper.find(curMachineId)
            let outputString = "\(machine!.name) - \(tbvc.selectedMachines[curMachineId]!)h"
            cell.textLabel!.text = outputString
        }
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tableViewWorker {
            print("Row \(indexPath.row) selected")
            let curWorkerId = currentWorkersForWorkIDs[indexPath.row]
            currentTableView = tableViewWorker
            showSlider(curWorkerId, source: dataType.worker)
        }
        if tableView == tableViewMachine {
            print("Row \(indexPath.row) selected")
            let curMachineId = currentMachinesForWorkIDs[indexPath.row]
            currentTableView = tableViewMachine
            showSlider(curMachineId, source: dataType.machine)
        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if tableView == tableViewWorker {
            if (editingStyle == UITableViewCell.EditingStyle.delete) {
                let workerid = currentWorkersForWorkIDs[indexPath.row]
                currentWorkersForWorkIDs.remove(at: indexPath.row)
                tbvc.selectedWorkers.removeValue(forKey: workerid)
                tableViewWorker.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
                
                
            }
        }
        if tableView == tableViewMachine {
            if (editingStyle == UITableViewCell.EditingStyle.delete) {
                let machineid = currentMachinesForWorkIDs[indexPath.row]
                currentMachinesForWorkIDs.remove(at: indexPath.row)
                tbvc.selectedMachines.removeValue(forKey: machineid)
                tableViewMachine.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
                
                
            }
        }
        
    }
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Löschen"
    }
    //MARK: Slider functions
    func showSlider(_ resId: Int, source: dataType) {
        let popoverContent = self.storyboard?.instantiateViewController(withIdentifier: "sliderBox") as! SliderViewController
        let nav = UINavigationController(rootViewController: popoverContent)
        nav.modalPresentationStyle = UIModalPresentationStyle.popover
        let popover = nav.popoverPresentationController
        popoverContent.preferredContentSize = CGSize(width: 280,height: 150)
        switch source {
            case .worker:
                let worker = WorkerDataHelper.find(resId)
                popoverContent.title = worker?.lastName
                if let _ = tbvc.selectedWorkers[resId] {
                    popoverContent.defaultValue = Float (tbvc.selectedWorkers[resId]!)
                }
            case .machine:
                let machine = MachineDataHelper.find(resId)
                popoverContent.title = machine?.name
                if let _ = tbvc.selectedMachines[resId] {
                    popoverContent.defaultValue = Float (tbvc.selectedMachines[resId]!)
                }
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
    //CallBack using a delegate to get the hours
    func getHours(_ value: Float) {
        if currentTableView == tableViewWorker {
            let cellIndexPath = tableViewWorker.indexPathForSelectedRow!
            let curWorkerId = currentWorkersForWorkIDs[cellIndexPath.row]
            tbvc.selectedWorkers[curWorkerId] = Double(value)
            currentWorkersForWorkIDs = [Int](tbvc.selectedWorkers.keys).sorted(by: <)
            tableViewWorker.reloadData()
            
        }
        if currentTableView == tableViewMachine {
            let cellIndexPath = tableViewMachine.indexPathForSelectedRow!
            let curMachineId = currentMachinesForWorkIDs[cellIndexPath.row]
            tbvc.selectedMachines[curMachineId] = Double(value)
            currentMachinesForWorkIDs = [Int](tbvc.selectedMachines.keys).sorted(by: <)
            tableViewMachine.reloadData()
            
        }

        
    }


}
