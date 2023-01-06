//
//  InputPurchaseAmountViewController.swift
//  MoFa
//
//  Created by Arnold Schmid on 20.12.15.
//  Copyright © 2015 Arnold Schmid. All rights reserved.
//

import UIKit
protocol PurchaseAmountDelegate {
    func getPurchaseAmount( _ amount: Double)
}
class InputPurchaseAmountViewController: UIViewController {
    @IBOutlet weak var amountTxt: UITextField!
    var getPurchaseAmountDelegate : PurchaseAmountDelegate?
    
    var amount: Double = 1.00
    override func viewDidLoad() {
        super.viewDidLoad()
        amountTxt.text = amount.description
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func okButtonClicked(_ sender: AnyObject) {
        amount = Double (amountTxt.text!)!
        getPurchaseAmountDelegate?.getPurchaseAmount( amount)
        self.dismiss(animated: false, completion: nil)
    }

   
    @IBAction func cancelButtonClicked(_ sender: AnyObject) {
        self.dismiss(animated: false, completion: nil)
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
