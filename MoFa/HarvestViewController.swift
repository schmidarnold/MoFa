//
//  HarvestViewController.swift
//  MoFa
//
//  Created by Arnold Schmid on 19.10.15.
//  Copyright © 2015 Arnold Schmid. All rights reserved.
//

import UIKit

class HarvestViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, getHarvestEntryDelegate {

    
    @IBOutlet weak var harvestTableView: UITableView!
    var currentHarvestEntries :[Harvest]?
    var tbvc = WorkTabBarController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tbvc = self.tabBarController  as! WorkTabBarController
        currentHarvestEntries = tbvc.harvest
        harvestTableView.dataSource = self
        harvestTableView.delegate = self
       
        
      //  configureTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func configureTableView() {
        harvestTableView.rowHeight = UITableView.automaticDimension
        harvestTableView.estimatedRowHeight = 180.0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "harvestSegue":
                print("[prepareForSegue] edit harvest")
                let row = harvestTableView.indexPath(for: sender as! UITableViewCell)!.row
                let harvestEntry = self.currentHarvestEntries![row] as Harvest
                let harvestEditController : HarvestEditViewController = segue.destination as! HarvestEditViewController
                harvestEditController.newEntry = false
                harvestEditController.row = row
                harvestEditController.harvest = harvestEntry
                harvestEditController.harvestEntryDelegate = self
            case "newHarvestSegue":
                print("[prepareForSegue] new harvest")
                let harvestEditController : HarvestEditViewController = segue.destination as! HarvestEditViewController
                harvestEditController.newEntry = true
                harvestEditController.harvestEntryDelegate = self
            default: break

            }
        }
            
        
    }
        /*
    // MARK: - TableViewDelegate and TableViewDataSource
    
    

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentHarvestEntries != nil {
            return (currentHarvestEntries?.count)!
        }else{
            return 0
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! HarvestCell
       // let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! HarvestCell
        let harvest = currentHarvestEntries![indexPath.row]
        cell.liefernrLabel.text = harvest.id?.description
        cell.mengeLabel.text = harvest.amount?.description
        let dateMaker = DateFormatter()
        dateMaker.dateFormat = "dd.MM.YY"
        let curDate = ((harvest.date!))
        let quality = CategoryDataHelper.getQuality(harvest.categoryId!)
        let datum = Date(timeIntervalSince1970: TimeInterval(curDate))
        cell.datumLabel.text = dateMaker.string(from: datum)
        cell.kategorieLabel.text = quality
        cell.kistenLabel.text = harvest.boxes?.description
        cell.bemerkungLabel.text = harvest.note
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Löschen"
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCell.EditingStyle.delete) {
            let harvestItem = self.currentHarvestEntries?[indexPath.row]
            HarvestDataHelper.delete(harvestItem!)
            currentHarvestEntries?.remove(at: indexPath.row)
            tbvc.harvest = currentHarvestEntries //we have to update also the harvest array of the parent viewcontroller, because those one will be saved
            tableView.reloadData()
            //tableView.deleteRowsAtIndexPaths([indexPath.row], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
        
    }
    func getHarvestData(_ data: Harvest, row: Int?) {
        if row != nil { //existing entry
            currentHarvestEntries?[row!] = data
        }else { //new entry
            if currentHarvestEntries == nil {
                currentHarvestEntries = [Harvest]()
            }
           currentHarvestEntries?.append(data)
        }
        tbvc.harvest = currentHarvestEntries
        harvestTableView.reloadData()
    }
}
