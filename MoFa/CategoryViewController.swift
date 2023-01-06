//
//  CategoryViewController.swift
//  MoFa
//
//  Created by Arnold Schmid on 11.11.15.
//  Copyright © 2015 Arnold Schmid. All rights reserved.
//

import UIKit
protocol getQualityDelegate {
    func getQuality(_ quality: String, qualityId : Int)
}
class CategoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var qualityDelegate:getQualityDelegate?
    let catList = CategoryDataHelper.findAll()
    @IBOutlet weak var catTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        catTableView.dataSource = self
        catTableView.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
 //MARK: Tableview DataSource and Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return catList!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
        
        let row = indexPath.row
        cell.textLabel?.text = catList![row].quality
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let row = indexPath.row
        qualityDelegate?.getQuality(catList![row].quality, qualityId: catList![row].id)
        print(catList![row].quality)
    }
}
