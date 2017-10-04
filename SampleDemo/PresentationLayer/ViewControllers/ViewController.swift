//
//  ViewController.swift
//  SampleDemo
//
//  Created by Deepak Mitra on 26/09/2017.
//  Copyright © 2017 Deepak Mitra. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class ViewController: BaseViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,URLSessionDelegate,URLSessionDownloadDelegate {
    enum Tag: NSInteger {
        case Images
        case Videos
        case Pdfs
    }
    
    //MARK: - Outlets & Properties
    
    @IBOutlet weak var btnImages: UIButton!
    @IBOutlet weak var btnVideos: UIButton!
    @IBOutlet weak var btnPdfs: UIButton!
    @IBOutlet weak var collvw: UICollectionView!
    
    var arrPdfUrls = NSMutableArray()
    var arrVideoUrls = NSMutableArray()
    var arrImageUrls = NSMutableArray()
    var imageView = UIImageView()
    let imv = UIImage()
    var session = URLSession()
    var intSelCategoty = Int()
    
    //MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sessionConfiguration: URLSessionConfiguration =  URLSessionConfiguration.background(withIdentifier: "com.BGTransferDemo")
        sessionConfiguration.httpMaximumConnectionsPerHost = 5;
        self.session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        self.btnImages.backgroundColor = .gray
        self.btnVideos.backgroundColor = videosBgColor
        self.btnPdfs.backgroundColor = pdfBgColor

        intSelCategoty = Tag.Images.rawValue
        arrImageUrls = getImagesData()
        arrVideoUrls = getVideosData()
        arrPdfUrls = getPdfsData()
        
        self.collvw.register(UINib.init(nibName: "CustomCell", bundle: Bundle.main), forCellWithReuseIdentifier: "CustomCell")
        self.collvw.delegate = self
        self.collvw.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Methods for downloading
    
     func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        DispatchQueue.main.sync {
            let index: Int = self.getFileDownloadInfoIndexWithTaskIdentifier(taskIdentifier: downloadTask.taskIdentifier)
            let cell: CustomCell = collvw.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: IndexPath(row: index, section: 0) ) as! CustomCell
            cell.progressBar.isHidden = true
            var fdi: FileDownloadInfo = FileDownloadInfo()

            if intSelCategoty == Tag.Images.rawValue {
                fdi = arrImageUrls[index] as! FileDownloadInfo
            } else if intSelCategoty == Tag.Videos.rawValue {
                fdi = arrVideoUrls[index] as! FileDownloadInfo
            } else if intSelCategoty == Tag.Pdfs.rawValue {
                fdi = arrPdfUrls[index] as! FileDownloadInfo
            }
            fdi.downloadComplete = true
            self.saveDataToMyFilesDirectory(strUrl: fdi.downloadSource!,location: location)
            self.collvw.reloadItems(at: [IndexPath(row: index, section: 0)])
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if  totalBytesExpectedToWrite == NSURLSessionTransferSizeUnknown {
            print("Unknown transfer size")
        } else {
            let index: Int = self.getFileDownloadInfoIndexWithTaskIdentifier(taskIdentifier: downloadTask.taskIdentifier)
            var fdi: FileDownloadInfo = FileDownloadInfo()
            if intSelCategoty == Tag.Images.rawValue {
                fdi = arrImageUrls[index] as! FileDownloadInfo
            } else if intSelCategoty == Tag.Videos.rawValue {
                fdi = arrVideoUrls[index] as! FileDownloadInfo
            } else if intSelCategoty == Tag.Pdfs.rawValue {
                fdi = arrPdfUrls[index] as! FileDownloadInfo
            }
            fdi.downloadProgress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
            
            DispatchQueue.main.sync {
                let cell: CustomCell = collvw.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: IndexPath(row: index, section: 0) ) as! CustomCell
                let progress: UIProgressView = cell.progressBar
                progress.progress = Float(fdi.downloadProgress)
                self.collvw.reloadItems(at: [IndexPath(row: index, section: 0)])
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
    }
    
    func getFileDownloadInfoIndexWithTaskIdentifier(taskIdentifier: Int) -> Int {
        var index: Int = 0
        if intSelCategoty == Tag.Images.rawValue {
            for i in 0..<arrImageUrls.count {
                let fdi: FileDownloadInfo = arrImageUrls[i] as! FileDownloadInfo
                if fdi.taskIdentifier == taskIdentifier {
                    index = i
                    break
                }
            }
        } else if intSelCategoty == Tag.Videos.rawValue {
            for i in 0..<arrVideoUrls.count {
                let fdi: FileDownloadInfo = arrVideoUrls[i] as! FileDownloadInfo
                if fdi.taskIdentifier == taskIdentifier {
                    index = i
                    break
                }
            }
        }
        else if intSelCategoty == Tag.Pdfs.rawValue {
            for i in 0..<arrPdfUrls.count {
                let fdi: FileDownloadInfo = arrPdfUrls[i] as! FileDownloadInfo
                if fdi.taskIdentifier == taskIdentifier {
                    index = i
                    break
                }
            }
        }
        return index
    }
    
    //MARK: - Button Actions
    
    @IBAction func btnImageClicked(_ sender: UIButton) {
        intSelCategoty = Tag.Images.rawValue
        self.btnImages.backgroundColor = .gray
        self.btnVideos.backgroundColor = videosBgColor
        self.btnPdfs.backgroundColor = videosBgColor
        collvw.reloadData()
    }
    
    @IBAction func btnVideoClicked(_ sender: UIButton) {
        intSelCategoty = Tag.Videos.rawValue
        self.btnImages.backgroundColor = videosBgColor
        self.btnVideos.backgroundColor = .gray
        self.btnPdfs.backgroundColor = videosBgColor
        collvw.reloadData()
    }
    
    @IBAction func btnPdfClicked(_ sender: UIButton) {
        intSelCategoty = Tag.Pdfs.rawValue
        self.btnImages.backgroundColor = videosBgColor
        self.btnVideos.backgroundColor = videosBgColor
        self.btnPdfs.backgroundColor = .gray
        collvw.reloadData()
    }
    
    // MARK: - UICollectionViewDataSource protocol
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if intSelCategoty == Tag.Images.rawValue {
            return arrImageUrls.count
        } else if intSelCategoty == Tag.Videos.rawValue {
            return arrVideoUrls.count
        } else if intSelCategoty == Tag.Pdfs.rawValue {
            return arrPdfUrls.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width/3 - 1, height: UIScreen.main.bounds.width/3 - 1)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuseIdentifier = "CustomCell"
        let cell: CustomCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! CustomCell
        if intSelCategoty == Tag.Images.rawValue {
            let fdi: FileDownloadInfo = self.arrImageUrls.object(at: indexPath.item) as! FileDownloadInfo
            let k: (Bool,String) = isFileAlreadyExist(strFile: fdi.downloadSource!)
            if k.0 == true {
                fdi.downloadComplete = true
                cell.imvBrand.image = UIImage.init(contentsOfFile: k.1)
                cell.progressBar.isHidden = true
                cell.imvDownLoad.isHidden = true
            } else {
                if fdi.isDownloading == true {
                    cell.progressBar.isHidden = false
                    cell.imvDownLoad.isHidden = true
                } else {
                    cell.progressBar.isHidden = true
                    cell.imvDownLoad.isHidden = false
                }
                fdi.downloadComplete = false
                cell.imvBrand.image = UIImage.init(named: "placeholder.png")
                cell.progressBar.progress = Float(fdi.downloadProgress)
            }
        }
        else if intSelCategoty == Tag.Videos.rawValue {
            let fdi: FileDownloadInfo = self.arrVideoUrls.object(at: indexPath.item) as! FileDownloadInfo
            let k: (Bool,String) = isFileAlreadyExist(strFile: fdi.downloadSource!)
            if k.0 == true {
                fdi.downloadComplete = true
                cell.imvBrand.image = UIImage(named: "videoThumb.png")
                cell.progressBar.isHidden = true
                cell.imvDownLoad.isHidden = true
            } else {
                if fdi.isDownloading == true {
                    cell.progressBar.isHidden = false
                    cell.imvDownLoad.isHidden = true
                } else {
                    cell.progressBar.isHidden = true
                    cell.imvDownLoad.isHidden = false
                }
                fdi.downloadComplete = false
                cell.imvBrand.image = UIImage(named: "videoThumb.png")
                cell.progressBar.progress = Float(fdi.downloadProgress)
            }
        }
        else if intSelCategoty == Tag.Pdfs.rawValue {
            let fdi: FileDownloadInfo = self.arrPdfUrls.object(at: indexPath.item) as! FileDownloadInfo
            let k: (Bool,String) = isFileAlreadyExist(strFile: fdi.downloadSource!)
            if k.0 == true {
                fdi.downloadComplete = true
                cell.imvBrand.image = UIImage(named: "pdf-icon.png")
                cell.progressBar.isHidden = true
                cell.imvDownLoad.isHidden = true
            } else {
                if fdi.isDownloading == true {
                    cell.progressBar.isHidden = false
                    cell.imvDownLoad.isHidden = true
                } else {
                    cell.progressBar.isHidden = true
                    cell.imvDownLoad.isHidden = false
                }
                fdi.downloadComplete = false
                cell.imvBrand.image = UIImage(named: "pdf-icon.png")
                cell.progressBar.progress = Float(fdi.downloadProgress)
            }
        }
        cell.imvBrand.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell.imvBrand.layer.shadowRadius = 2
        cell.imvBrand.layer.shadowColor = UIColor.darkGray.cgColor
        cell.imvBrand.layer.shadowOpacity = 1.0
        cell.backgroundColor = UIColor.white
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if intSelCategoty == Tag.Images.rawValue {
            let fdi: FileDownloadInfo = self.arrImageUrls.object(at: indexPath.item) as! FileDownloadInfo
            
            let k: (Bool,String) = isFileAlreadyExist(strFile: fdi.downloadSource!)
            if k.0 == true {
            } else {
                if appDelegate.isServerReachable == true {
                    if fdi.isDownloading == false {
                        if  fdi.taskIdentifier == -1 {
                            let url = URL(string: fdi.downloadSource!)!
                            fdi.downloadTask = self.session.downloadTask(with: url)
                            fdi.taskIdentifier = fdi.downloadTask?.taskIdentifier
                            fdi.downloadTask?.resume()
                        } else {
                        }
                    } else {
                        fdi.taskIdentifier = -1
                    }
                    fdi.isDownloading = !fdi.isDownloading;
                    self.collvw.reloadItems(at: [indexPath])
                } else {
                    let alert = UIAlertController(title: alertText,
                                                  message: internetConnectionAlert,
                                                  preferredStyle: UIAlertControllerStyle.alert)
                    let cancelAction = UIAlertAction(title: okText,
                                                     style: .cancel, handler: nil)
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        } else if intSelCategoty == Tag.Videos.rawValue {
            let fdi: FileDownloadInfo = self.arrVideoUrls.object(at: indexPath.item) as! FileDownloadInfo
            let k: (Bool,String) = isFileAlreadyExist(strFile: fdi.downloadSource!)
            if k.0 == true {
                let playerViewController = AVPlayerViewController()
                let url1 = URL.init(fileURLWithPath: k.1)
                let player = AVPlayer(url: url1)
                playerViewController.player = player
                self.present(playerViewController, animated: true) {
                    playerViewController.player!.play()
                }
            } else {
                if appDelegate.isServerReachable == true {
                    if fdi.isDownloading == false {
                        if  fdi.taskIdentifier == -1 {
                            let url = URL(string: fdi.downloadSource!)!
                            fdi.downloadTask = self.session.downloadTask(with: url)
                            fdi.taskIdentifier = fdi.downloadTask?.taskIdentifier
                            fdi.downloadTask?.resume()
                        } else {
                        }
                    } else {
                       fdi.taskIdentifier = -1
                    }
                    fdi.isDownloading = !fdi.isDownloading;
                    self.collvw.reloadItems(at: [indexPath])
                } else {
                    let alert = UIAlertController(title: alertText,
                                                  message: internetConnectionAlert,
                                                  preferredStyle: UIAlertControllerStyle.alert)
                    
                    let cancelAction = UIAlertAction(title: okText,
                                                     style: .cancel, handler: nil)
                    
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        } else if intSelCategoty == Tag.Pdfs.rawValue {
            let fdi: FileDownloadInfo = self.arrPdfUrls.object(at: indexPath.item) as! FileDownloadInfo
            let k: (Bool,String) = isFileAlreadyExist(strFile: fdi.downloadSource!)
            if k.0 == true {
                let SB: UIStoryboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
                let vcWeb: WebViewController = SB.instantiateViewController(withIdentifier:
                    "WebViewController") as! WebViewController
                vcWeb.strUrl = k.1
                self.navigationController?.pushViewController(vcWeb, animated: true)
            } else {
                if appDelegate.isServerReachable == true {
                    if fdi.isDownloading == false {
                        if  fdi.taskIdentifier == -1 {
                            let url = URL(string: fdi.downloadSource!)!
                            fdi.downloadTask = self.session.downloadTask(with: url)
                            fdi.taskIdentifier = fdi.downloadTask?.taskIdentifier
                            fdi.downloadTask?.resume()
                        } else {
                        }
                    } else {
                        fdi.taskIdentifier = -1
                    }
                    fdi.isDownloading = !fdi.isDownloading;
                    self.collvw.reloadItems(at: [indexPath])
                } else {
                    let alert = UIAlertController(title: alertText,
                                                  message: internetConnectionAlert,
                                                  preferredStyle: UIAlertControllerStyle.alert)
                    let cancelAction = UIAlertAction(title: okText,
                                                     style: .cancel, handler: nil)
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    //MARK: - Other Methods
    
    func getImagesData() -> NSMutableArray {
        let arrImageUrls = NSMutableArray()
        let fdi0: FileDownloadInfo = FileDownloadInfo()
        fdi0.fileTitle = fdi0_fileTitle
        fdi0.downloadSource = fdi0_downloadSource //"http://publications.gbdirect.co.uk/c_book/thecbook.pdf"
        arrImageUrls.add(fdi0)//
        
        let fdi1: FileDownloadInfo = FileDownloadInfo()
        fdi1.fileTitle = fdi1_fileTitle
        fdi1.downloadSource = fdi1_downloadSource
        arrImageUrls.add(fdi1)
        
        let fdi2: FileDownloadInfo = FileDownloadInfo()
        fdi2.fileTitle = fdi2_fileTitle
        fdi2.downloadSource = fdi2_downloadSource
        arrImageUrls.add(fdi2)
        
        let fdi3: FileDownloadInfo = FileDownloadInfo()
        fdi3.fileTitle = fdi3_fileTitle
        fdi3.downloadSource = fdi3_downloadSource
        arrImageUrls.add(fdi3)
        
        let fdi4: FileDownloadInfo = FileDownloadInfo()
        fdi4.fileTitle = fdi4_fileTitle
        fdi4.downloadSource = fdi4_downloadSource
        arrImageUrls.add(fdi4)
        
        let fdi5: FileDownloadInfo = FileDownloadInfo()
        fdi5.fileTitle = fdi5_fileTitle
        fdi5.downloadSource = fdi5_downloadSource
        arrImageUrls.add(fdi5)
        
        let fdi6: FileDownloadInfo = FileDownloadInfo()
        fdi6.fileTitle = fdi6_fileTitle
        fdi6.downloadSource = fdi6_downloadSource
        arrImageUrls.add(fdi6)
        
        let fdi7: FileDownloadInfo = FileDownloadInfo()
        fdi7.fileTitle = fdi7_fileTitle
        fdi7.downloadSource = fdi7_downloadSource
        arrImageUrls.add(fdi7)
        
        let fdi8: FileDownloadInfo = FileDownloadInfo()
        fdi8.fileTitle = fdi8_fileTitle
        fdi8.downloadSource = fdi8_downloadSource
        arrImageUrls.add(fdi8)
        
        let fdi9: FileDownloadInfo = FileDownloadInfo()
        fdi9.fileTitle = fdi9_fileTitle
        fdi9.downloadSource = fdi9_downloadSource
        arrImageUrls.add(fdi9)
        
        let fdi10: FileDownloadInfo = FileDownloadInfo()
        fdi10.fileTitle = fdi10_fileTitle
        fdi10.downloadSource = fdi10_downloadSource
        arrImageUrls.add(fdi10)
        
        let fdi11: FileDownloadInfo = FileDownloadInfo()
        fdi11.fileTitle = fdi11_fileTitle
        fdi11.downloadSource = fdi11_downloadSource
        arrImageUrls.add(fdi11)
        return arrImageUrls
    }
    
    func getVideosData() -> NSMutableArray {
        let arrVideoUrls = NSMutableArray()
        
        let fdi20: FileDownloadInfo = FileDownloadInfo()
        fdi20.fileTitle = fdi20_fileTitle
        fdi20.downloadSource = fdi20_downloadSource
        arrVideoUrls.add(fdi20)
        
        let fdi21: FileDownloadInfo = FileDownloadInfo()
        fdi21.fileTitle = fdi21_fileTitle
        fdi21.downloadSource = fdi21_downloadSource
        arrVideoUrls.add(fdi21)
        return arrVideoUrls
        }
    
    func getPdfsData() -> NSMutableArray {
        let arrPdfUrls = NSMutableArray()

        let fdi00: FileDownloadInfo = FileDownloadInfo()
        fdi00.fileTitle = fdi00_fileTitle
        fdi00.downloadSource = fdi00_downloadSource
        arrPdfUrls.add(fdi00)
        
        let fdi01: FileDownloadInfo = FileDownloadInfo()
        fdi01.fileTitle = fdi01_fileTitle
        fdi01.downloadSource = fdi01_downloadSource
        arrPdfUrls.add(fdi01)
        
        let fdi02: FileDownloadInfo = FileDownloadInfo()
        fdi02.fileTitle = fdi02_fileTitle
        fdi02.downloadSource = fdi02_downloadSource
        arrPdfUrls.add(fdi02)
        
        let fdi03: FileDownloadInfo = FileDownloadInfo()
        fdi03.fileTitle = fdi03_fileTitle
        fdi03.downloadSource = fdi03_downloadSource
        arrPdfUrls.add(fdi03)
        
        let fdi04: FileDownloadInfo = FileDownloadInfo()
        fdi04.fileTitle = fdi04_fileTitle
        fdi04.downloadSource = fdi04_downloadSource
        arrPdfUrls.add(fdi04)
        return arrPdfUrls
    }
    
}


