//
//  WebViewViewController.swift
//  Core Score
//
//  Created by Remya on 10/11/22.
//

import UIKit
import WebKit

class WebViewViewController: BaseViewController {
    @IBOutlet weak var webView:WKWebView!
    
    
   var urlString = ""
    var fromStart = false
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSettings()
        

        // Do any additional setup after loading the view.
    }
    
    func initialSettings(){
        if fromStart == false{
        setBackButton()
        }
        else{
            setupSpecialButtons()
        }
        loadUrl()
    }
    
    func setupSpecialButtons(){
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        btn.setImage(UIImage(named: "back"), for: .normal)
        btn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: btn)
    }
    
    @objc func backAction(){
        Utility.gotoHome()
        Utility.callURlDetailsAPI()
    }
    

    func loadUrl(){
        if let link = URL(string:urlString){
        let request = URLRequest(url: link)
        webView.load(request)
        }
    }

}
