//
//  SearchViewController.swift
//  MoFa
//
//  Created by Arnold Schmid on 12.01.16.
//  Copyright © 2016 Arnold Schmid. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, returnDataDelegate, ReturnCurrentProductDelegate {

    
    @IBOutlet weak var table: UITableView!
    var previouslySelectedHeaderIndex: Int?
    var selectedHeaderIndex: Int?
    var selectedItemIndex: Int?
    var anlagenIndex = [1,3]
    var datumIndex = [6,7]
    let selectProductRow = 4 // is the row in table for selecting pest/fert
    var curVQuarters = Set<Int>()
    var selectedProduct : Product?
    let cells = SwiftyAccordionCells()
    var searchType : Constants.SearchType!
    var fromDate : String?
    var toDate: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        table.dataSource = self
        table.delegate = self
        setup()
        // Do any additional setup after loading the view.
    }
    
    func setup() {
        let headerCell1 = SwiftyAccordionCells.HeaderItem(value: "Letzte Spritzungen")
        let headerCell2 = SwiftyAccordionCells.HeaderItem(value: "Suche Spritzmittel")
        let headerCell3 = SwiftyAccordionCells.HeaderItem(value: "Stundenauswertung")
       // let headerCell3 = SwiftyAccordionCells.HeaderItem(value: "Suche Blattdünger")
        self.cells.append(headerCell1)
        self.cells.append(SwiftyAccordionCells.Item(value: "Anlage auswählen"))
        self.cells.append(headerCell2)
        self.cells.append(SwiftyAccordionCells.Item(value: "Anlage auswählen"))
        self.cells.append(SwiftyAccordionCells.Item(value: "Spritzmittel auswählen"))
        self.cells.append(headerCell3)
        
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cells.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.cells.items[indexPath.row]
        var value = item.value as String
        let nrVqr = curVQuarters.count
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SearchCell
        //if let cell = tableView.dequeueReusableCellWithIdentifier("cell") {
        cell.startButton.tag = indexPath.row
            
            if item as? SwiftyAccordionCells.HeaderItem != nil {
                cell.backgroundColor = UIColor.lightGray
                if nrVqr > 0 && indexPath.row == 0 { //first search to activate
                    cell.startButton.isHidden = false
                    cell.startButton.addTarget(self, action: #selector(SearchViewController.startSearch(_:)), for: .touchUpInside)
                }
                if nrVqr > 0 && indexPath.row == 2 && selectedProduct != nil{ //second search to activate
                    cell.startButton.isHidden = false
                    cell.startButton.addTarget(self, action: #selector(SearchViewController.startSearch(_:)), for: .touchUpInside)
                }
                if indexPath.row == 5 {
                    cell.startButton.isHidden = false
                    cell.startButton.addTarget(self, action: #selector(SearchViewController.startSearch(_:)), for: .touchUpInside)
                }
            }
                if nrVqr > 0 { // we have already selected vquarters
                    if anlagenIndex.contains(indexPath.row) {
                        cell.backgroundColor = UIColor.green
                        cell.accessoryType = UITableViewCell.AccessoryType.checkmark
                        value = "\(value) (\(nrVqr) SQ) "
                    }
                }
                if (selectedProduct != nil && indexPath.row == selectProductRow){
                    cell.backgroundColor = UIColor.green
                    cell.accessoryType = UITableViewCell.AccessoryType.checkmark
                    value = "\(value) (\(selectedProduct!.productName) ) "
                }
                        
            cell.searchLabel.text = value
           // cell.textLabel?.text = value
            return cell
       // }
        
       // return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = self.cells.items[indexPath.row]
        
        if item is SwiftyAccordionCells.HeaderItem {
            return 60
        } else if (item.isHidden) {
            return 0
        } else {
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.cells.items[indexPath.row]
       // print (indexPath.row)
        if item is SwiftyAccordionCells.HeaderItem {
            if self.selectedHeaderIndex == nil {
                self.selectedHeaderIndex = indexPath.row
            } else {
                self.previouslySelectedHeaderIndex = self.selectedHeaderIndex
                self.selectedHeaderIndex = indexPath.row
            }
            
            if let previouslySelectedHeaderIndex = self.previouslySelectedHeaderIndex {
                self.cells.collapse(previouslySelectedHeaderIndex)
            }
            
            if self.previouslySelectedHeaderIndex != self.selectedHeaderIndex {
                self.cells.expand(self.selectedHeaderIndex!)
            } else {
                self.selectedHeaderIndex = nil
                self.previouslySelectedHeaderIndex = nil
            }
            
            self.table.beginUpdates()
            self.table.endUpdates()
            
        } else {
            
            if anlagenIndex.contains(indexPath.row) {
                performSegue(withIdentifier: "searchvquartersegue", sender: nil)
            }
            if indexPath.row == selectProductRow {
                performSegue(withIdentifier: "searchproductsegue", sender: nil)
            }
            
//            if indexPath.row != self.selectedItemIndex {
//                let cell = self.table.cellForRowAtIndexPath(indexPath)
//                cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
//                
//                if let selectedItemIndex = self.selectedItemIndex {
//                    let previousCell = self.table.cellForRowAtIndexPath(NSIndexPath(forRow: selectedItemIndex, inSection: 0))
//                    previousCell?.accessoryType = UITableViewCellAccessoryType.None
//                }
//                
//                self.selectedItemIndex = indexPath.row
//            }
        
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "searchvquartersegue":
                if let vc = segue.destination as? VQuarterViewController {
                    vc.checkedVQuarters = curVQuarters
                    vc.delegate = self
                   
                    
                }
            case "searchproductsegue":
                if let vc = segue.destination as? PesticideFertilizerController {
                    vc.callingSource = Constants.Search
                    vc.getProductDelegate = self
                    
                    
                }
            case "resultSegue":
                if let vc = segue.destination as? SearchResultViewController {
                    vc.vquarterList = VQuarterDataHelper.findSelectedVquarters(curVQuarters)
                    vc.queryType = searchType
                    if (searchType == Constants.SearchType.searchProd) {
                        vc.selectedProduct = selectedProduct
                    }
                    
                }
            case "hoursworkersegue":
                _ = segue.destination as? HoursWorkerViewController
            default: break
            }
            
        }
    }
    /**
     callback from vquarters
    **/
    func loadVQuarters(_ vqIds: Set<Int>) {
        curVQuarters = vqIds
        table.reloadData()
    }
    /**
     callback from pesticidefertilizercontroller
    **/
    func getProduct(_ product: Product) {
        self.selectedProduct = product
        
        table.reloadData()
    }
    
    // startsearch
    
    @objc func startSearch(_ sender:AnyObject) {
        let tag = ((sender as!UIButton).tag)
        switch tag {
        case 0:
           searchType = Constants.SearchType.lastSprayEntries
            performSegue(withIdentifier: "resultSegue", sender: nil)
        case 2:
            searchType = Constants.SearchType.searchProd
            performSegue(withIdentifier: "resultSegue", sender: nil)
        case 5:
            performSegue(withIdentifier: "hoursworkersegue", sender: nil)
        default:
            searchType = Constants.SearchType.searchProd
            performSegue(withIdentifier: "resultSegue", sender: nil)
        }
        
    }
        
}

