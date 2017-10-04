//
//  WebViewController.swift
//  SampleDemo
//
//  Created by Deepak Mitra on 26/09/2017.
//  Copyright © 2017 Deepak Mitra. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: BaseViewController,WKNavigationDelegate {
    
    //MARK: - Properties
    
    var indicator = UIActivityIndicatorView()
    var strUrl = String()
    
    //MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Confohure web view
        let theConfiguration = WKWebViewConfiguration()
        theConfiguration.processPool = WKProcessPool()
        
        let wkwebView: WKWebView = WKWebView.init(frame: CGRect(x: 0, y: 64, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height-64), configuration: theConfiguration)
        wkwebView.backgroundColor = UIColor.white
        wkwebView.isOpaque = false
        wkwebView.navigationDelegate = self
        wkwebView.alpha = 1
        wkwebView.tag = 12345
        self.view.addSubview(wkwebView)

        indicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        indicator.center = wkwebView.center
        indicator.color = UIColor.init(colorLiteralRed: 60.0/255, green: 188.0/255, blue: 215.0/255, alpha: 1.0)
        wkwebView.addSubview(indicator)
        indicator.startAnimating()
        
        let url = URL.init(fileURLWithPath: strUrl)
        let data = try! Data(contentsOf: url)
        wkwebView.load(data, mimeType: "application/pdf", characterEncodingName:"", baseURL: url.deletingLastPathComponent())
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Methods
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        indicator.stopAnimating()
    }
    
    //MARK: - Button action
    @IBAction func btnBackClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
