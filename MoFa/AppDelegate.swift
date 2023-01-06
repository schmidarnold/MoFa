//
//  AppDelegate.swift
//  MoFa
//
//  Created by Arnold Schmid on 18.04.15.
//  Copyright (c) 2015 Arnold Schmid. All rights reserved.
//

import UIKit
import SQLite
import SwiftyDropbox
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let dbName : String = "mofadbios.sqlite3"
    var window: UIWindow?
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //createDBStructure()
        //copyFile(dbName)
        copyFileNew()
        DropboxClientsManager.setupWithAppKey("kr7pjmpdjth06g0")
       // let accountManager = DBAccountManager(appKey: "zgo2dupm3ung3u6", secret: "22u6lbkswjitll9")
       // DBAccountManager.setSharedManager(accountManager)
        //  dropboxSyncService!.setup()
        // Override point for customization after application launch.
        if (MultQueries.getDbVersion()<12){
            MultQueries.createGlobalTable()
        }
        if (MultQueries.getDbVersion()<14){
            MultQueries.convertConToDouble()
        }
        if (MultQueries.getDbVersion()<17){
            MultQueries.updateToVer17()
        }
        return true
    }
    //for Dropbox IOS version < 9
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if let authResult = DropboxClientsManager.handleRedirectURL(url) {
            switch authResult {
            case .success(let token):
                print("Success! User is logged into Dropbox with token: \(token)")
            case .error(let error, let description):
                print("Error \(error): \(description)")
            case .cancel:
                print("Authorization flow was manually canceled by user!")
            }
        }
        
        return false
    }
    //for Dropbox IOS version >9
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        if let authResult = DropboxClientsManager.handleRedirectURL(url) {
            switch authResult {
            case .success(let token):
                print("Success! User is logged into Dropbox with token: \(token)")
            case .error(let error, let description):
                print("Error \(error): \(description)")
            case .cancel:
                print("Authorization flow was manually canceled by user!")
            }
        }
        
        return false
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    func applicationDidFinishLaunching(_ application: UIApplication) {
        createDBStructure()
    }
    
    func copyFile(_ fileName: String) {
        let dbPath: String = getPath(fileName)
        let fileManager = FileManager.default
        let fromPath: String? = (Bundle.main.resourcePath! as NSString).appendingPathComponent(fileName)
        if !fileManager.fileExists(atPath: dbPath) {
            print("dB not found in document directory filemanager will copy this file from this path=\(String(describing: fromPath)) :::TO::: path=\(dbPath)")
            do {
                try fileManager.copyItem(atPath: fromPath!, toPath: dbPath)
            }catch let error as NSError {
                print ("\(error.localizedDescription)")
            }
            
        } else {
            print("DID-NOT copy dB file, file allready exists at path:\(dbPath), check versions")
            if (MultQueries.getDbVersion()<12){
                MultQueries.createGlobalTable()
            }
            if (MultQueries.getDbVersion()<14){
                MultQueries.convertConToDouble()
            }
            if (MultQueries.getDbVersion()<17){
                MultQueries.updateToVer17()
            }
        }
        Settings.setDatabase(dbPath)
    }
    func copyFileNew() {
        //let bundlePath = (Bundle.main.resourcePath! as NSString).appendingPathComponent(fileName)
        let bundlePath = Bundle.main.path(forResource: "mofadbios", ofType: ".sqlite3")
        
        let destPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let fileManager = FileManager.default
        let fullDestPath = URL(fileURLWithPath: destPath).appendingPathComponent(dbName)
        
        if fileManager.fileExists(atPath: fullDestPath.path){
            print("Database file is exist")
           // print(fileManager.fileExists(atPath: bundlePath!))
            print("DID-NOT copy dB file, file allready exists at path:\(fullDestPath.path)")
            
        }else{
            do{
                print("dB not found in document directory filemanager will copy this file from this path=\(String(describing: bundlePath)) :::TO::: path=\(destPath)")
                try fileManager.copyItem(atPath: bundlePath!, toPath: fullDestPath.path)
            }catch{
                print("\n",error)
            }
        }
        Settings.setDatabase(fullDestPath.path)
    }
    
    func getPath(_ fileName: String) -> String {
        return (NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] as NSString).appendingPathComponent(fileName)
    }
    
    func createDBStructure() {
        print("Check if db exists")
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first
        let getDBPath = (path! as NSString).appendingPathComponent(dbName)
        let checkValidation = FileManager.default
        if !(checkValidation.fileExists(atPath: getDBPath))
        {
            print("no db, creating new one")
            _ = try! Connection(getDBPath)
        }
        
    }
    
}

