//
//  Util.swift
//  MoFa
//
//  Created by Arnold Schmid on 16.10.15.
//  Copyright © 2015 Arnold Schmid. All rights reserved.
//

import Foundation
import SystemConfiguration
class Util {
    static func connectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            // SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                
                SCNetworkReachabilityCreateWithAddress(nil, $0)
                
            }
        }) else {
            return false
        }
        
        var flags : SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
    
    static func showImportError(_ titleMsg: String, errorMsg: String) {
        let alert = UIAlertController(title: titleMsg, message: errorMsg, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        var topController = UIApplication.shared.keyWindow!.rootViewController! as UIViewController
        
        while ((topController.presentedViewController) != nil) {
            topController = topController.presentedViewController!;
        }
        topController.present(alert, animated:true, completion:nil)
        //self.presentViewController(alert, animated: true, completion: nil)
    }
}
