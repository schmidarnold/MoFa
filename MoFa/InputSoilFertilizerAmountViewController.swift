//
//  InputSoilFertilizerAmountViewController.swift
//  MoFa
//
//  Created by Arnold Schmid on 21.11.15.
//  Copyright © 2015 Arnold Schmid. All rights reserved.
//

import UIKit
protocol SoilFertAmountDelegate {
    func getSoilAmount(_ arrayIndex : Int?, amount : Double)
}

class InputSoilFertilizerAmountViewController: UIViewController {
    
    @IBOutlet weak var totalSizeLabel: UILabel!
    @IBOutlet weak var amountTextView: UITextField!
    @IBOutlet weak var amountProHaTextView: UITextField!
    var refresh: Bool = false //helper to check if update other field to not run in infinite loop
    var sumSize: Int?
    var amount: Double = 0.00 {
        didSet{
            if sumSize != nil {
                if isViewLoaded&&refresh{
                    refresh=false
                    let aProHa = Double(round(amount/Double(sumSize!) * 10000))
                    amountProHaTextView.text = aProHa.description
                }
                
            }
        }
    }
    var amountProHa : Double = 0.00{
        didSet{
            if sumSize != nil && refresh {
                refresh=false
                amount = Double(round(amountProHa/10000 * Double(sumSize!)))
                amountTextView.text = amount.description
            }
        }
    }
    var getSoilAmountDelegate : SoilFertAmountDelegate?
    var arrayIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        if sumSize != nil {
             totalSizeLabel.text! += " " + (sumSize?.description)!
             amountProHaTextView.text = (round(amount/Double(sumSize!) * 10000)).description
        }
        amountTextView.text = amount.description
       
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func mengeTxtFieldChanged(_ sender: UITextField) {
        if let _ =  Double(sender.text!) {
            refresh=true
            amount = Double(sender.text!)!
        }
        
        
    }
    
    
    @IBAction func mengeHaTxtFieldChanged(_ sender: UITextField) {
        if let _ = Double(sender.text!){
            refresh=true
            amountProHa = Double(sender.text!)!
        }
        
        
    }
    
    @IBAction func okButtonClicked(_ sender: UIButton) {
        getSoilAmountDelegate?.getSoilAmount(arrayIndex, amount: amount)
        self.dismiss(animated: false, completion: nil)
        
    }
    
    @IBAction func cancelButtonClicked(_ sender: UIButton) {
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
