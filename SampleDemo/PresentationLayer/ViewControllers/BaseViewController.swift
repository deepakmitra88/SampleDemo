//
//  BaseViewController.swift
//  SampleDemo
//
//  Created by Deepak Mitra on 26/09/2017.
//  Copyright © 2017 Deepak Mitra. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Methods
    
    func isFileAlreadyExist(strFile: String) -> (Bool,String) {
        var str_url = strFile
        str_url = str_url.replacingOccurrences(of: "/", with: "")
        let filepath = appDelegate.getDocumentPath().appending(str_url)
        
        if !FileManager.default.fileExists(atPath: filepath) {
            return (false,filepath)
        } else {
            return (true,filepath)
        }
    }
    
    func saveDataToMyFilesDirectory(strUrl: String,location: URL) {
        let directoryPath =  appDelegate.getDocumentPath()
        var str_url = strUrl
        str_url = str_url.replacingOccurrences(of: "/", with: "")
        let filepath = directoryPath.appending(str_url)
        let urlPath = NSURL.fileURL(withPath: filepath)
        
        if !FileManager.default.fileExists(atPath: filepath) {
            do {
                try FileManager.default.copyItem(at: location, to: urlPath)
            } catch {
            }
        } else {
        }
    }
    
}
