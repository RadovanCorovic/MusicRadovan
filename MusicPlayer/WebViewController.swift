//
//  WebViewController.swift
//  MusicPlayer
//
//  Created by Radovan Corovic on 5/21/18.
//  Copyright © 2018 Radovan Corovic. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    
    var webAdress = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(webAdress)
        let url = URL(string: "\(webAdress)")
        let request = URLRequest(url: url!)
        
        webView.load(request)
    }

}
