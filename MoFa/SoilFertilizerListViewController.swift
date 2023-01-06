//
//  SoilFertilizerListViewController.swift
//  MoFa
//
//  Created by Arnold Schmid on 20.11.15.
//  Copyright © 2015 Arnold Schmid. All rights reserved.
//

import UIKit
protocol SoilFertListDelegate{
    func getSoilFertList(_ soilFertList: [WorkFertilizer]?)
}
class SoilFertilizerListViewController: UITableViewController, UIPopoverPresentationControllerDelegate,SoilFertAmountDelegate {
    var soilFertilizers : [SoilFertilizer]?
    var selectedFertilizer : SoilFertilizer?
    var sumSize : Int?
    var soilFertilizersForCurrentWork: [WorkFertilizer]?
    let cellIdentifier = "cell"
    var getSoilFertListDelegate : SoilFertListDelegate?
    override func viewDidLoad() {
        loadFertilizers()
        
        
    }
    func loadFertilizers() {
        self.soilFertilizers = SoilFertilizerDataHelper.findAll()
    }
    
    
    func showInputAmountWindow() {
        let popoverContent = self.storyboard?.instantiateViewController(withIdentifier: "inputSoilFertilizer") as! InputSoilFertilizerAmountViewController
        let nav = UINavigationController(rootViewController: popoverContent)
        nav.modalPresentationStyle = UIModalPresentationStyle.popover
        let popover = nav.popoverPresentationController
        popoverContent.preferredContentSize = CGSize(width: 280,height: 190)
        popoverContent.title = selectedFertilizer!.productName
        popover!.delegate = self
        popover!.sourceView = self.view
        popover!.sourceRect = CGRect(x: 280,y: 190,width: 0,height: 0)
        popoverContent.getSoilAmountDelegate = self
        if sumSize != nil {
            popoverContent.sumSize = sumSize
        }
        if let index = findFertilizerInArray(selectedFertilizer!.id)  { //existing entry
            popoverContent.arrayIndex = index
            popoverContent.amount = soilFertilizersForCurrentWork![index].amount
        }
        self.present(nav, animated: true, completion: nil)
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        // Return no adaptive presentation style, use default presentation behaviour
        return .none
    }
    func findFertilizerInArray(_ fertId: Int)->Int? {
        let index = soilFertilizersForCurrentWork?.firstIndex(where: {$0.soilFertId == fertId })
        return index
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        getSoilFertListDelegate?.getSoilFertList(soilFertilizersForCurrentWork)
    }
    
    //MARK: - callBack from InputSoilFertilizerAmountVC
    
    func getSoilAmount(_ arrayIndex: Int?, amount: Double) {
        if (arrayIndex) != nil { //existing one
            soilFertilizersForCurrentWork![arrayIndex!].amount = amount
        }else { //choosing new soilfert
            let newItem = WorkFertilizer()
            newItem.soilFertId = (selectedFertilizer?.id)!
            newItem.amount = amount
            if soilFertilizersForCurrentWork != nil { //we have already  some other fert in curr work
                soilFertilizersForCurrentWork!.append(newItem)
            }else{ //we have no fert in curr work
                soilFertilizersForCurrentWork = [WorkFertilizer]()
                soilFertilizersForCurrentWork!.append(newItem)
            }
        }
    }
    
    //MARK: - tableView DataSource and Delegate
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (soilFertilizers?.count)!
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        // Fetches the appropriate meal for the data source layout.
        let soilFertilizer = soilFertilizers![indexPath.row]
        cell.textLabel?.text = soilFertilizer.productName
        
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedFertilizer = soilFertilizers![indexPath.row]
        showInputAmountWindow()
    }
}
