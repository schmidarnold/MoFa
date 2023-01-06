//
//  InfoViewController.swift
//  MoFa
//
//  Created by Arnold Schmid on 10.01.16.
//  Copyright © 2016 Arnold Schmid. All rights reserved.
//

import UIKit

class ProductInfoViewController: UIViewController {
    var pesticide : Pesticide?
  
    @IBOutlet weak var waitingPeriodLabel: UILabel!
    @IBOutlet weak var wezLabel: UILabel!
    @IBOutlet weak var maxAmountLabel: UILabel!
    
    @IBOutlet weak var maxUsageLabel: UILabel!
    @IBOutlet weak var maxDoseLabel: UILabel!
    
    @IBOutlet weak var beeImage: UIImageView!
    @IBOutlet weak var otherRestrictLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        showData()

        // Do any additional setup after loading the view.
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
    func showData() {
        let constraints = pesticide!.constraints
        let data = constraints!.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: AnyObject]
            if let wez = json["wez"] as? Int {
                wezLabel.text = String (wez)
            }
            if let maxAmount = json["maxAmount"] as? Double {
                maxAmountLabel.text = String (maxAmount)
            }
            if let waitingPeriod = json["waitingPeriod"] as? Int {
                waitingPeriodLabel.text = String (waitingPeriod)
            }
            if let maxUsage = json["maxUsage"] as? Int {
                maxUsageLabel.text = String (maxUsage)
            }
            if let beeRestriction = json["beeRestriction"] as? Int {
                if beeRestriction == 1 {
                    beeImage.isHidden = false
                }else{
                    beeImage.isHidden = true
                }
                print(beeRestriction)
            }
            if let restriction = json["restriction"] as? String {
                otherRestrictLabel.text = restriction
            }
            if let maxDose = json["maxDose"] as? Double {
                maxDoseLabel.text = String (maxDose)
            }
        } catch let error as NSError {
            print("Failed to load: \(error.localizedDescription)")
        }
        // print (pesticide?.constraints!)
    }
}
