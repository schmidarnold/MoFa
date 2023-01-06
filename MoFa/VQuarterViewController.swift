//
//  VQuarterViewController.swift
//  MoFa
//
//  Created by Arnold Schmid on 21.07.15.
//  Copyright (c) 2015 Arnold Schmid. All rights reserved.
//

import UIKit
import RATreeView
protocol returnDataDelegate {
    func loadVQuarters (_: Set<Int>)
}
class VQuarterViewController: UIViewController ,RATreeViewDataSource,RATreeViewDelegate {
    //var table = RATreeView()
    var table : RATreeView!
    let anlagen = LandDataHelper.findAll()
    let sortenquartiere = VQuarterDataHelper.findAll()
    var checkedVQuarters = Set<Int>()
    // Delegate to calling viewController
    var delegate:returnDataDelegate?
    
    @IBOutlet weak var tableView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table = RATreeView(frame:tableView.bounds)
        table.autoresizingMask = UIView.AutoresizingMask(rawValue:UIView.AutoresizingMask.flexibleWidth.rawValue | UIView.AutoresizingMask.flexibleHeight.rawValue)
        // let frame = tableView.frame
        //tableView.removeFromSuperview()
        
        //table.frame = frame
        table.dataSource = self
        table.delegate = self
        
        let typeCell = UINib(nibName: "vwAnlagenCell", bundle:nil)
        let vqCell = UINib(nibName: "vwVarQuarterCell", bundle:nil)
        table.register( typeCell, forCellReuseIdentifier: "cell")
        table.register(vqCell, forCellReuseIdentifier: "vquartercell")
        //table.rowHeight = 43
        tableView.addSubview(table);
        //self.view.addSubview(table)
        table.reloadData()
    
    }
    func treeView(_ treeView: RATreeView!, numberOfChildrenOfItem item: Any!) -> Int {
        var i = 0
        if item == nil {
            i = Int (anlagen!.count)
        }else if item is Land {
            let currAnlage = item as! Land
            let vqs = filterSQ(currAnlage.id!)
            i = Int (vqs.count)
            
        }
        return i
    }
    
    func treeView(_ treeView: RATreeView!, child index: Int, ofItem item: Any!) -> Any! {
        var childToReturn : AnyObject = NSObject()
        if item == nil{
            let b = anlagen?[Int(index)]
            childToReturn = b!
        }else if item is Land{
            let currentAnlage = item as! Land
            let vqs = filterSQ(currentAnlage.id!)
            let s = vqs[Int(index)]
            childToReturn = s
            
        }
        
        return childToReturn
    }
    func treeView(_ treeView: RATreeView!, cellForItem item: Any!) -> UITableViewCell! {
        var cell = UITableViewCell()
        //treeView.separatorStyle = RATreeViewCellSeparatorStyleSingleLine
        let level = treeView.levelForCell(forItem: item)
        
        if level == 0{
            let anlagenCell = treeView.dequeueReusableCell(withIdentifier: "cell") as! AnlagenCell
            anlagenCell.lblAnlagenNamen.text = "\((item as! Land).name!)"
            anlagenCell.chkAnlage.tag = (item as! Land).id!
            anlagenCell.chkAnlage.addTarget(self, action:#selector(VQuarterViewController.anlageClick(_:)), for: .touchUpInside)
            
            cell = anlagenCell
        }else if level == 1{
            let vqCell = treeView.dequeueReusableCell(withIdentifier: "vquartercell") as! VQuarterCell
            if (item as! VQuarter).plantYear != nil {
                vqCell.lblVQuarterName.text = "\((item as! VQuarter).name!) \((item as! VQuarter).plantYear! )"
            }else{
                vqCell.lblVQuarterName.text = "\((item as! VQuarter).name!) )"
                
            }
            
            vqCell.chkSelected.isChecked = vquarterIsInSelectedList((item as! VQuarter).id!)
            vqCell.chkSelected.tag = (item as! VQuarter).id!
            vqCell.chkSelected.addTarget(self, action:#selector(VQuarterViewController.chkVquarterClick(_:)), for: .touchUpInside)
            
            cell = vqCell
            
        }
        return cell
    }
    
    func treeView(_ treeView: RATreeView!, didSelectRowForItem item: Any!) {
        print(item)
        let level = treeView.levelForCell(forItem: item)
        if level == 0 {
            _ = (item as! Land).name
            print((item as! Land).id!)
            
        }else if level == 1 {
            _ = treeView.dequeueReusableCell(withIdentifier: "vquartercell") as! VQuarterCell
            _ = (item as! VQuarter).name
            print((item as! VQuarter).id!)
        }
        
    }
    @objc func chkVquarterClick (_ sender: AnyObject){
        let button = sender as! CheckBox
        
        if (button.isChecked){
            checkedVQuarters.insert(button.tag)
            print ("Adding to set \(button.tag)")
        }else {
            checkedVQuarters.remove(button.tag)
            print ("Removing from set \(button.tag)")
        }
        
    }
    
    func filterSQ(_ anlageid: Int) -> [VQuarter]{
         return sortenquartiere!.filter {$0.landId == anlageid}
    }
    
    @objc func anlageClick(_ sender:AnyObject){
        let button = sender as! CheckBox
        let vqs = filterSQ (button.tag)
        let chkStatus = button.isChecked
        for vq in vqs {
            if chkStatus {
                print("Adding \(vq.id!) to set")
                
                checkedVQuarters.insert(vq.id!)
            }else {
                print ("Removing \(vq.id!) from set")
                checkedVQuarters.remove(vq.id!)
            }
            
        }
        let filteredAnlage = anlagen!.filter() { $0.id == button.tag }
        let curAnlage = filteredAnlage[0]
       if (table.isCell(forItemExpanded: curAnlage)) {
            print ("refresh clients")
        
          //  checkParentStatus(table, curAnlage, clientCell: <#UITableViewCell#>)
           // table.reloadRows(forItems: vqs, with: RATreeViewRowAnimationNone)
            table.reloadRows()
        
        }
        //println("Current Anlage = \(curAnlage.name)")
        //table.cellForItem(<#item: AnyObject!#>)
        //table.reloadRowsForItems(vqs, withRowAnimation: RATreeViewRowAnimationNone)
        
    }
    func checkParentStatus(_ treeView: RATreeView!, item: Land, clientCell: UITableViewCell) {
        let parentCell = treeView.cell(forItem: item) as! AnlagenCell
        if parentCell.chkAnlage.isChecked {
            let vqCell = clientCell as! VQuarterCell
            vqCell.chkSelected.isChecked = true
        }
        
        
    }
    func vquarterIsInSelectedList(_ vqId:Int) -> Bool {
        return checkedVQuarters.contains (vqId)
    }
    
    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        delegate?.loadVQuarters(checkedVQuarters)
        print ("VQuarterViewController: Go back")
    }
}
