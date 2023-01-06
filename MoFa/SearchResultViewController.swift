//
//  SearchResultViewController.swift
//  MoFa
//
//  Created by Arnold Schmid on 16.01.16.
//  Copyright © 2016 Arnold Schmid. All rights reserved.
//

import UIKit
import RATreeView
class SearchResultViewController: UIViewController, RATreeViewDataSource, RATreeViewDelegate {
    var table : RATreeView!
    let dateMaker = DateFormatter()
    let cellId = "resultTitleCell"
    var vquarterList : [VQuarter]!
    var resultList = Dictionary<Int, [String]>()
    var selectedVQuarter : VQuarter?
    var selectedProduct : Product?
    var queryType : Constants.SearchType!
    @IBOutlet weak var tableView: UIView!
    
    @IBOutlet weak var titelLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        table = RATreeView(frame:tableView.bounds)
        
        table.dataSource = self
        table.delegate = self
        table.autoresizingMask = UIView.AutoresizingMask(rawValue:UIView.AutoresizingMask.flexibleWidth.rawValue | UIView.AutoresizingMask.flexibleHeight.rawValue)
        let resultCell = UINib(nibName: "resultTitelCell", bundle:nil)
        
        table.register( resultCell, forCellReuseIdentifier: cellId)
        
        table.rowHeight = 43
        tableView.addSubview(table)
        loadResults()
        table.reloadData()
        setTitle()
    }
    func setTitle() {
        if queryType == Constants.SearchType.lastSprayEntries {
            titelLabel.text = "Letzte Spritzungen"
        } else {
            titelLabel.text = "Suche Produkt: \(selectedProduct!.productName)"
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
 //MARK: Delegate and DataSource for RATTreeView
    func treeView(_ treeView: RATreeView!, numberOfChildrenOfItem item: Any!) -> Int {
        var i=0
        if item == nil {
           i = vquarterList.count
        }else if item is VQuarter {
           let curVQ = item as! VQuarter
           let entries = resultList[curVQ.id!]
           i = (entries?.count)!
            
        }
        
        return i
    }
    
    func treeView(_ treeView: RATreeView!, child index: Int, ofItem item: Any!) -> Any! {
        var childToReturn : AnyObject = NSObject()
        if item == nil{
            let b = vquarterList[Int(index)]
            childToReturn = b
        }else if item is VQuarter{
            let curVQ = item as! VQuarter
            let entries = resultList[curVQ.id!]
            let s = entries![Int(index)]
            childToReturn = s as AnyObject
            
        }
        return childToReturn
    }
        
    func treeView(_ treeView: RATreeView!, cellForItem item: Any!) -> UITableViewCell! {
        var cell = UITableViewCell()
       // treeView.separatorStyle = RATreeViewCellSeparatorStyleSingleLine
        let level = treeView.levelForCell(forItem: item)
        if level == 0{
            let vqCell = treeView.dequeueReusableCell(withIdentifier: cellId) as! ResultTitleCell
            selectedVQuarter = (item as! VQuarter)
            let landName = LandDataHelper.findLandNameForId(selectedVQuarter!.landId!)
            let vqStr = "\(landName), \(selectedVQuarter!.name!) \(selectedVQuarter!.plantYear!)"
            vqCell.titleLabel.text = vqStr
            vqCell.backgroundColor = UIColor.gray
            cell = vqCell
        }else if level == 1{
            let vqCell = treeView.dequeueReusableCell(withIdentifier: cellId) as! ResultTitleCell
            vqCell.titleLabel.text = (item as! String)
            vqCell.backgroundColor = UIColor.white
            cell = vqCell
        }
        return cell
    }
 
//MARK: loading and search Data
    func loadResults() {
        switch queryType! {
        case .lastSprayEntries:
            resultList = MultQueries.getLastSprayings(vquarterList)
        case .searchProd:
            resultList = MultQueries.getProdForVQ(vquarterList, product: selectedProduct!)
        }
        //resultList = MultQueries.getLastSprayings(vquarterList)
        //MultQueries.getSprayWork()
    }

    

}
