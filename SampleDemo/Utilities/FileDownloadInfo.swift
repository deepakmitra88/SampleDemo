//
//  FileDownloadInfo.swift
//  SampleDemo
//
//  Created by Deepak Mitra on 26/09/2017.
//  Copyright © 2017 Deepak Mitra. All rights reserved.
//

import UIKit

class FileDownloadInfo: NSObject {
    var fileTitle: String? = nil
    var downloadSource: String? = nil
    var downloadTask: URLSessionDownloadTask? = nil
    var taskResumeData: Data? = nil
    var downloadProgress: Double = 0.0
    var isDownloading: Bool = false
    var downloadComplete: Bool = false
    var taskIdentifier: Int? = -1
    
    func initWithFileTitle(title: String, andDownloadSource source: String)->Any {
        self.fileTitle = title
        self.downloadSource = source
        self.downloadProgress = 0.0
        self.isDownloading = false
        self.downloadComplete = false
        self.taskIdentifier = -1
        
        return self
    }
}
