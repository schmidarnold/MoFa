//
//  SoilFertilizerViewController.swift
//  MoFa
//
//  Created by Arnold Schmid on 20.11.15.
//  Copyright © 2015 Arnold Schmid. All rights reserved.
//

import UIKit

class SoilFertilizerViewController: UIViewController, SoilFertListDelegate, UITableViewDataSource, UITableViewDelegate,UIPopoverPresentationControllerDelegate,SoilFertAmountDelegate {
    var sumSize : Int?
    
    
    @IBOutlet weak var soilFertilizerTableView: UITableView!
    var tbvc = WorkTabBarController()
    override func viewDidLoad() {
        super.viewDidLoad()
        tbvc = self.tabBarController  as! WorkTabBarController
        soilFertilizerTableView.dataSource = self
        soilFertilizerTableView.delegate = self
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "newSoilFertSegue":
                print("[prepareForSegue] new soil fertilizer")
                let selectSoilFertilizer : SoilFertilizerListViewController = segue.destination as! SoilFertilizerListViewController
                sumSize = VQuarterDataHelper.sumSize(tbvc.curVQuarters)
                selectSoilFertilizer.sumSize = self.sumSize
                if tbvc.selectedSoilFertilizers != nil {
                    selectSoilFertilizer.soilFertilizersForCurrentWork = tbvc.selectedSoilFertilizers
                }
                selectSoilFertilizer.getSoilFertListDelegate = self
            default: break
                
            }
        }

    }
    
    //MARK: callback from SoilFertilizerListVC
    func getSoilFertList(_ soilFertList: [WorkFertilizer]?) {
        tbvc.selectedSoilFertilizers = soilFertList
        print ("[getSoilFertList]\(String(describing: tbvc.selectedSoilFertilizers))")
        soilFertilizerTableView.reloadData()
    }
    
    //MARK: tableview dataSource and dataDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tbvc.selectedSoilFertilizers != nil {
            return (tbvc.selectedSoilFertilizers?.count)!
        }else{
            return 0
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SoilFertCell
        // let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! HarvestCell
        let workFert = tbvc.selectedSoilFertilizers![indexPath.row]
        let soilFert = SoilFertilizerDataHelper.find(workFert.soilFertId)
        cell.productLabel.text = soilFert!.productName
        cell.amountLabel.text = workFert.amount.description
        sumSize = VQuarterDataHelper.sumSize(tbvc.curVQuarters)
        if (sumSize != nil) {
            let amountProHa = workFert.amount/Double(sumSize!) * 10000
            cell.amountHaLabel.text = (round(amountProHa)).description
        }
        
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let soilProd = tbvc.selectedSoilFertilizers![indexPath.row]
        showInputAmountWindow(soilProd, index: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Löschen"
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCell.EditingStyle.delete) {
            let soilFertItem = tbvc.selectedSoilFertilizers?[indexPath.row]
            WorkFertilizerDataHelper.delete(soilFertItem!)
            tbvc.selectedSoilFertilizers?.remove(at: indexPath.row)
            
            tableView.reloadData()
            //tableView.deleteRowsAtIndexPaths([indexPath.row], withRowAnimation: UITableViewRowAnimation.Automatic)        }
        }
    }
    func showInputAmountWindow(_ currSoilData: WorkFertilizer, index: Int) {
        let product = SoilFertilizerDataHelper.find(currSoilData.soilFertId)
        let popoverContent = self.storyboard?.instantiateViewController(withIdentifier: "inputSoilFertilizer") as! InputSoilFertilizerAmountViewController
        let nav = UINavigationController(rootViewController: popoverContent)
        nav.modalPresentationStyle = UIModalPresentationStyle.popover
        let popover = nav.popoverPresentationController
        popoverContent.preferredContentSize = CGSize(width: 280,height: 190)
        popoverContent.title = product!.productName
        popover!.delegate = self
        popover!.sourceView = self.view
        popover!.sourceRect = CGRect(x: 280,y: 190,width: 0,height: 0)
        popoverContent.getSoilAmountDelegate = self
        if sumSize != nil {
            popoverContent.sumSize = sumSize
        }
        popoverContent.arrayIndex = index
        popoverContent.amount = currSoilData.amount
        
        self.present(nav, animated: true, completion: nil)
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        // Return no adaptive presentation style, use default presentation behaviour
        return .none
    }
    func getSoilAmount(_ arrayIndex: Int?, amount: Double) {
        tbvc.selectedSoilFertilizers![arrayIndex!].amount = amount
        soilFertilizerTableView.reloadData()
        
    }
}
