//
//  DropboxSyncService.swift - New Class for API V2 -
//  recreated JULY 2016
//  MoFa
//
//  Created by Arnold Schmid on 27.04.15.
//  Copyright (c) 2015 Arnold Schmid. All rights reserved.
//
////MARK: Service class
import SwiftyDropbox
struct DropboxSyncService{
    
    static func fileFolderExists(_ path: String) -> Bool {
        var exists = false
        if let client = DropboxClientsManager.authorizedClient {
            client.files.getMetadata(path: path).response{response, error in
                if response != nil {
                    exists = true
                }else {
                    exists = false
                }
                
            }
        }
        return exists
    }
    static func createFolderStructure() {
        let mofaRootPath = "/MoFaBackend"
        let elements = ["/land","/vquarter","/machine", "/worker", "/category", "/task","/pesticide","/fertilizer","/soilfertilizer","/extra"]
        if let client = DropboxClientsManager.authorizedClient {
            client.files.createFolderV2(path: mofaRootPath + "/export")
            let importFolder = mofaRootPath + "/import"
            for element in elements {
                client.files.createFolderV2(path: importFolder + element)
            }
        }
    }
    
    /*
     DEPRECATED -- only for testing
    */
    static func hasUpdateFile (_ client: DropboxClient ,fileList : [String]) -> [String:String]{
        var updateList = [String:String]()
        client.files.getMetadata(path: "/MoFaBackend").response{response, error in
            if response == nil {
                print ("Creating folder structure ...")
                createFolderStructure()
            } else {
                print ("MoFaBackendFolder exists")
            }
            
            
        }
        
        for file in fileList {
            
            let path = "/MoFaBackend/import/\(file)/list.xml"
            client.files.getMetadata(path: path).response{response, error in
                if response != nil {
                    updateList[file] = path
                }
                
            }

        }
               //
        
        return updateList
        //    
    }
    /*
     NEW VERSION FOR CHECKING OF UPDATES, WE ARE WAITING UNTIL ALL ASYNCHRONOUS TASKS HAVE FINISHED
     USING DISPATCH GROUPS
     */
    static func hasUpdates(_ client: DropboxClient, fileList: [String], completionHandler: @escaping ([String:String]) -> ()){
        var updateList = [String:String]()
        let group = DispatchGroup()
        group.enter() //adding to a group
        client.files.getMetadata(path: "/MoFaBackend").response{response, error in
            if response == nil {
                print ("Creating folder structure ...")
                createFolderStructure()
            } else {
                print ("MoFaBackendFolder exists")
            }
            group.leave()
            
        }
        
        for file in fileList {
            group.enter()
            let path = "/MoFaBackend/import/\(file)/list.xml"
            client.files.getMetadata(path: path).response{response, error in
                if response != nil {
                    updateList[file] = path
                }
                group.leave()
            }
            
        }
        
        group.notify(queue: DispatchQueue.main){
            completionHandler(updateList)
        }

    }
    static func getDatav2(_ fileName:String,client: DropboxClient, completionHandler: @escaping (Data?) ->()) {
        var data: Data?
        let group = DispatchGroup()
        group.enter()
        client.files.download(path: fileName).response {response, error in
            if let (_, url) = response {
                data = url
            }else{
                data = nil
            }
            group.leave()
        }
        group.notify(queue: DispatchQueue.main){
            completionHandler(data)
        }
        
    }
    static func delFile(_ fileName: String) {
         if let client = DropboxClientsManager.authorizedClient {
            client.files.deleteV2(path: fileName)
        }
       
    }
    static func getData(_ fileName: String)-> Data?{
        var data : Data?
        if let client = DropboxClientsManager.authorizedClient {
            client.files.download(path: fileName).response {response, error in
                if let (_, url) = response {
                    data = url
                    }else{
                    data = nil
                }
                
            }

        }
        return data
    }
    
    static func saveFile(_ path: String, data: Data) -> Bool {
        var success : Bool = false
        if let client = DropboxClientsManager.authorizedClient {
            client.files.upload(path: path, input: data).response{response, error in
                if response != nil {
                    success = true
                }else{
                    success = false
                }
                
            }
        }
        return success
    }

//    
//     func setup() {
//        let accountManager = DBAccountManager(appKey: "zgo2dupm3ung3u6", secret: "22u6lbkswjitll9")
//        DBAccountManager.setSharedManager(accountManager)
//        if let account = DBAccountManager.sharedManager().linkedAccount {
//            DBFilesystem.setSharedFilesystem(DBFilesystem(account: account))
//        }
//    }
//    func clearLinkedAccount() {
//        if let _ = DBAccountManager.sharedManager().linkedAccounts?.count {
//            DBAccountManager.sharedManager().linkedAccount.unlink()
//        }
//    }
//    func initiateAuthentication(viewController: UIViewController) {
//        DBAccountManager.sharedManager().linkFromController(viewController)
//        
//    }
//    func finalizeAuthentication(url: NSURL) -> Bool {
//        let account = DBAccountManager.sharedManager().handleOpenURL(url)
//        DBFilesystem.setSharedFilesystem(DBFilesystem(account: account))
//        if folderExists(account, curFolder: "/MoFaBackend") == false{
//            createMofaFolderStruct()
//        }
//        
//        return account != .None
//    }
//    func linkedConnections() -> Bool {
//        if let _ = DBAccountManager.sharedManager().linkedAccounts?.count {
//            return true
//        }
//        return false
//    }
//    func getFiles() -> Result<[String]> {
//         let fileInfos = DBFilesystem.sharedFilesystem().listFolder(DBPath.root())
//            
//        
//            let filePaths: [DBFileInfo] -> [String] = { $0.map { $0.path.stringValue() } }
//            return filePaths <^> fileInfos
//           
//    }
//    func getFiles(account:DBAccount, curFolder:String) ->Result<[String]>{
//        let mofaPath = DBPath.root().childPath(curFolder)
//        let fileInfos = DBFilesystem.sharedFilesystem().listFolder(mofaPath)
//        let filePaths: [DBFileInfo] -> [String] = { $0.map { $0.path.stringValue() } }
//        return filePaths <^> fileInfos
//    }
//    
//    func folderExists(account:DBAccount, curFolder:String) -> Bool {
//        var results = [String]()
//        let fileInfos = DBFilesystem.sharedFilesystem().listFolder(DBPath.root())
//        let filePaths: [DBFileInfo] -> [String] = { $0.map { $0.path.stringValue() } }
//        let dicList = filePaths <^> fileInfos
//        switch dicList{
//            case let .Success(aBox): results = aBox.value
//            case .Error(_): results = []
//            }
//        let contained = results.contains(curFolder)
//        if (contained == true){
//            return true
//        }else {
//            return false
//        }
//
//        
//    }
//    func createFolder(folder: String){
//        let path = DBPath.root().childPath(folder)
//        _ = DBFilesystem.sharedFilesystem().createFolder(path)
//        
//    }
//    func createMofaFolderStruct() {
//        let startFolder = "/MoFaBackend"
//        let importFolder = "\(startFolder)/import"
//        let exportFolder = "\(startFolder)/export"
//        createFolder(startFolder)
//        createFolder(importFolder)
//        createFolder(exportFolder)
//        createFolder("\(importFolder)/category")
//        createFolder("\(importFolder)/fertilizer")
//        createFolder("\(importFolder)/land")
//        createFolder("\(importFolder)/machine")
//        createFolder("\(importFolder)/pesticide")
//        createFolder("\(importFolder)/soilfertilizer")
//        createFolder("\(importFolder)/task")
//        createFolder("\(importFolder)/vquarter")
//        createFolder("\(importFolder)/worker")
//        
//    }
//    func getFile(filename: String) -> Result<NSData> {
//        
//        let path = DBPath.root().childPath(filename)
//        return DBFilesystem.sharedFilesystem().openFile(path) >>- { $0.readData() }
//    }
//    // a wrapper function that returns an Optional of NSDATA
//    func getFileWrapper (filename: String) -> NSData? {
//        var data : NSData?
//        DBFilesystem.sharedFilesystem().maxFileCacheSize = 0
//        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
//            data = extractResult(self.getFile(filename))
//        //})
//        
//        return data
//    }
//    func saveFile(filename: String, data: NSData) -> Result<()> {
//        let path = DBPath.root().childPath(filename)
//        return DBFilesystem.sharedFilesystem().createFile(path) >>- { $0.writeData(data) }
//    }
//
//    func getUpdateFiles (account: DBAccount) -> [(String)] {
//        
//        let mofaTaskPath = "/MoFaBackend/import/task"
//        let result = extractResult(getFiles(account,curFolder: mofaTaskPath))
//        return result
//        
//    }
//    func hasUpdateFile (account: DBAccount, fileList : [String]) -> [String:String]{
//        var updateList = [String:String]()
//        var _ : Bool
//        var _: DBError?
//        var _:String
//        for file in fileList {
//            let path = "/MoFaBackend/import/\(file)/list.xml"
//            if (containsFile(path) == true) { //adding the files to the array of dictionary
//                updateList[file] = path
//            }
//            
//         }
//         
//        return updateList
//    }
//    func containsFile (filePath: String) -> Bool {
//        var error : DBError?
//        let dbDropboxPath = DBPath.root().childPath(filePath)
//        if let _ = DBFilesystem.sharedFilesystem().fileInfoForPath(dbDropboxPath, error: &error){
//            return true
//            }else{
//            return false
//            }
//    }
//    
}
