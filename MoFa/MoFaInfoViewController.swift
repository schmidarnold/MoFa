//
//  MoFaInfoViewController.swift
//  MoFa
//
//  Created by Arnold Schmid on 23.01.16.
//  Copyright © 2016 Arnold Schmid. All rights reserved.
//

import UIKit

class MoFaInfoViewController: UIViewController {

    @IBOutlet weak var versionLabel: UILabel!
    
    
    @IBOutlet weak var dbVersionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setVersions()
        print("Db Version: \(MultQueries.getDbVersion())")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func setVersions() {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionLabel.text = "Version: \(version)"
            dbVersionLabel.text = "Datenbank Version: \(MultQueries.getDbVersion())"
        }
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
