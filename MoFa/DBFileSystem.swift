//
//  DbFileSystem.swift
//  MoFa
//
//  Created by Arnold Schmid on 28.04.15.
//  Copyright (c) 2015 Arnold Schmid. All rights reserved.
//

import Foundation
//extension DBFilesystem {
//    func listFolder(path: DBPath) -> Result<[DBFileInfo]> {
//        var error: DBError?
//        let files = listFolder(path, error: &error)
//        
//        switch error {
//        case .None: return .success(files as! [DBFileInfo])
//        case let .Some(err): return .error(err)
//        }
//    }
//    func fileInfoForPath (path: DBPath) -> Result<DBFileInfo> {
//        var error: DBError?
//        
//            let file = fileInfoForPath(path, error: &error)
//            
//            
//            switch error {
//            case .None: return .success(file as DBFileInfo)
//            case let .Some(err): return .error(err)
//            }
//        
//      
//    }
//    
//    func openFile(path: DBPath) -> Result<DBFile> {
//        var error: DBError?
//        let file = openFile(path, error: &error)
//        
//        switch error {
//        case .None: return .success(file)
//        case let .Some(err): return .error(err)
//        }
//    }
//    func createFile(path: DBPath) -> Result<DBFile> {
//        var error: DBError?
//        let file = createFile(path, error: &error)
//        
//        switch error {
//        case .None: return .success(file)
//        case let .Some(err): return .error(err)
//        }
//    }
//    func createFolder(path: DBPath) -> Result<Bool> {
//        var error: DBError?
//        let folder = createFolder(path, error: &error)
//        
//        switch error {
//        case .None: return .success(folder)
//        case let .Some(err): return .error(err)
//        }
//    }
//}