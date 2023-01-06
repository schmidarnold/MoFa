//
//  WorkTabBarController.swift
//  MoFa
//
//  Created by Arnold Schmid on 23.07.15.
//  Copyright (c) 2015 Arnold Schmid. All rights reserved.
//

import UIKit
protocol workSaveDelegate {
    func saveWorkData(_ curWork : Work, curVquarters : Set<Int>, selectedWorkers : [Int: Double], selectedMachines: [Int : Double], spraying: Spraying?, sprayPest : [SprayPesticide]?, sprayFert: [SprayFertilizer]?, harvestEntries: [Harvest]?, soilFert: [WorkFertilizer]?, globalDat: GlobalData?)
}
class WorkTabBarController: UITabBarController, UITabBarControllerDelegate {
    var newEntry : Bool = false
    var curWork = Work()
    var curVQuarters = Set<Int>()
    var selectedWorkers = [Int:Double]()
    var selectedMachines = [Int:Double]()
    var spraying : Spraying?
    var sprayPest : [SprayPesticide]?
    var sprayFert : [SprayFertilizer]?
    var harvest: [Harvest]?
    var selectedSoilFertilizers: [WorkFertilizer]?
    var globalData: GlobalData?
    var waterData = Water()
    struct Water{
        var amount: Double = 0.00
        var duration: Double = 0.00
        var type: Int = 1
    }
    override func viewDidLoad() {
        super.viewDidLoad()
                delegate = self
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(WorkTabBarController.handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(WorkTabBarController.handleSwipes(_:)))
        
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
        
    }
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        if (sender.direction == .left) {
            print("Swipe Left")
            self.selectedIndex = self.selectedIndex + 1
            
        }
        
        if (sender.direction == .right) {
            print("Swipe Right")
            self.selectedIndex = self.selectedIndex - 1
        }
    }
    
    func loadExistingData (_ work: Work) {
            let workId = work.workId
            curWork.workId = workId
            curWork.workDate = work.workDate
            curWork.taskId = work.taskId
            curWork.note = work.note
            curWork.sended = work.sended
            curWork.valid = work.valid
            selectedWorkers = WorkWorkerDataHelper.findWorkerForWorkDictionary(workId!)!
            selectedMachines = WorkMachineDataHelper.findMachineForWorkDictionary(workId!)!
            curVQuarters = WorkVQuarterDataHelper.getWorkVQuarter(workId!)
            let sprayingExists = SprayingDataHelper.exists(workId!)
            if sprayingExists { //spraying is stored
                spraying = SprayingDataHelper.findSprayingForWork(workId!)
                sprayPest = SprayPesticideHelper.findPestForSpray(spraying!.id)
                sprayFert = SprayFertilizerHelper.findFertForSpray(spraying!.id)
            }
            let harvestExists = HarvestDataHelper.exists(workId!)
            if harvestExists {
                harvest = HarvestDataHelper.findWorkIdOrdered(workId!)
            }
            let soilFertExists = WorkFertilizerDataHelper.exists(workId!)
            if soilFertExists {
                selectedSoilFertilizers = WorkFertilizerDataHelper.findFertilizerForWorkId(workId!)
            }
            let waterExists = GlobalDataHelper.exists(workId!,type: Constants.GlobalDataType.Irrigation.rawValue)
            if waterExists {
                globalData = GlobalDataHelper.getWaterDataForWorkId(workId!)
                
            }
        
        

    }
    // Delegate to calling viewController
    var workDelegate: workSaveDelegate?
    func saveData() {
        print("close tabbarcontroller")
        if globalData != nil {
            //print ("workSaveDelegate: creating water json")
            let jsonData = GlobalDataHelper.createJsonWater(waterData.type, irrDuration: waterData.duration, irrAmount: waterData.amount, irrTotale: (waterData.duration * waterData.amount))
            globalData?.data = jsonData
        }
        workDelegate?.saveWorkData(curWork, curVquarters: curVQuarters, selectedWorkers: selectedWorkers, selectedMachines: selectedMachines, spraying: spraying, sprayPest : sprayPest, sprayFert: sprayFert, harvestEntries: harvest, soilFert: selectedSoilFertilizers, globalDat: globalData)
        let x = self.navigationController
        _ = x?.popViewController(animated: true)
        
       
    }
    func cancelData() {
        let x = self.navigationController
        _ = x?.popViewController(animated: true)
    }
    func addTabBar() { //adding spray tab bar
        remprevTabBar() //remove first the old tabbar at pos 2
        var controllers = self.viewControllers! //array of the root view controllers displayed by the tab bar interface
        if controllers.count < 3 {
            let sprayItem = self.storyboard?.instantiateViewController(withIdentifier: "SprayingViewController") as! SprayingViewController
            //let sprayItem = SprayingViewController()
            let image = UIImage(named: "product")
            let sprayIcon = UITabBarItem(title: "Spritzung", image:image, selectedImage: image)
            sprayItem.tabBarItem = sprayIcon
            
            controllers.append(sprayItem)
            self.viewControllers = controllers
        }
        
    }
    func addHarvestTabBar() { //adding harvest tab bar
        remprevTabBar()
        var controllers = self.viewControllers! //array of the root view controllers displayed by the tab bar interface
        if controllers.count < 3 {
            let harvestItem = self.storyboard?.instantiateViewController(withIdentifier: "HarvestViewController") as! HarvestViewController
            
            let image = UIImage(named: "harvest")
            let harvestIcon = UITabBarItem(title: "Ernte", image:image, selectedImage: image)
            harvestItem.tabBarItem = harvestIcon
            
            controllers.append(harvestItem)
            self.viewControllers = controllers
        }
        
    }
    func addSoilFertilizerTabBar() { //adding soil fertilizer tab bar
        remprevTabBar()
        var controllers = self.viewControllers! //array of the root view controllers displayed by the tab bar interface
        if controllers.count<3 {
            let soilFertilizerItem = self.storyboard?.instantiateViewController(withIdentifier: "SoilFertilizerViewController") as! SoilFertilizerViewController
            
            let image = UIImage(named: "product")
            let soilFertIcon = UITabBarItem(title: "Düngung", image:image, selectedImage: image)
            soilFertilizerItem.tabBarItem = soilFertIcon
            
            controllers.append(soilFertilizerItem)
            self.viewControllers = controllers
        }
        
    }
    func addWaterTabBar(){
        remprevTabBar()
        var controllers = self.viewControllers!
        if controllers.count<3{
            let waterItem = self.storyboard?.instantiateViewController(withIdentifier: "WaterViewController") as! WaterViewController
            let image = UIImage(named: "water")
            let waterIcon = UITabBarItem(title:"Bewässerung", image:image, selectedImage: image)
            waterItem.tabBarItem = waterIcon
            controllers.append(waterItem)
            self.viewControllers = controllers
            
        }
    }
    func remprevTabBar() {
        var controllers = self.viewControllers!
        if controllers.count == 3 {
            controllers.remove(at: 2)
            self.viewControllers = controllers
        }
        
    }
    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        
        print("WorkTabBarController: Go back")
    }
}
