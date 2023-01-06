//
//  ImportDataViewController.swift
//  MoFa
//
//  Created by Arnold Schmid on 01.01.16.
//  Copyright © 2016 Arnold Schmid. All rights reserved.
//

import UIKit
protocol ImportDataDelegate {
    func importUpdateFiles(_ reImport: Bool)
}
class ImportDataViewController: UIViewController {
    @IBOutlet weak var updateLabel: UILabel!
    var updateMessage : String?
    
    var importDataDelegate: ImportDataDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        if updateMessage != nil {
            updateLabel.text = updateMessage!
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func importButtonClicked(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
        importDataDelegate?.importUpdateFiles(false)
    }

    @IBAction func cancelButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func delAndImportButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        importDataDelegate?.importUpdateFiles(true)
    }
}
