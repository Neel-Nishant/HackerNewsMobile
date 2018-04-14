//
//  ArticleWebViewController.swift
//  HackerNewsExercise
//
//  Created by Neel Nishant on 14/04/18.
//  Copyright © 2018 Neel Nishant. All rights reserved.
//

import UIKit
import WebKit
class ArticleWebViewController: UIViewController, UIWebViewDelegate {
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    var url = ""
    var feedDetails = [String: AnyObject]()
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var byLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        if url != ""{
            titleLabel.text = feedDetails["title"] as? String
            timeLabel.text = "\(getDateStringFromUTC())        \(feedDetails["by"]!)"
            
            byLabel.text = feedDetails["url"] as? String
            
            let request = URLRequest(url: URL(string: url)!)
            
            activityIndicator.center = self.view.center
            activityIndicator.startAnimating()
            self.view.addSubview(activityIndicator)
            webView.loadRequest(request)
        }
        
        // Do any additional setup after loading the view.
    }
    func getDateStringFromUTC() -> String {
        let date = Date(timeIntervalSince1970: (feedDetails["time"] as? Double)!)
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateStyle = .medium
        
        return dateFormatter.string(from: date)
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        if webView.isLoading == false {
            activityIndicator.stopAnimating()
        }
        
    }
}
