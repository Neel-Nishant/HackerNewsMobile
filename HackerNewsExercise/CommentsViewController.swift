//
//  CommentsViewController.swift
//  HackerNewsExercise
//
//  Created by Neel Nishant on 14/04/18.
//  Copyright © 2018 Neel Nishant. All rights reserved.
//

import UIKit

class CommentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    var kidsArray = [Int64]()
    var url = ""
    var cache: NSCache<AnyObject, AnyObject> = NSCache()
    var feedDetails = [String: AnyObject]()
//    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    var commentDetails = [[String:AnyObject]]()
    @IBOutlet weak var tView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var byLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("kids:\(kidsArray)")
        print("url:\(url)")

        commentDetails = [[String:AnyObject]](repeating: ["" : "" as AnyObject], count: kidsArray.count)
        if url != ""{
            titleLabel.text = feedDetails["title"] as? String
            timeLabel.text = "\(getDateStringFromUTC())        \(feedDetails["by"]!)"
            
            byLabel.text = feedDetails["url"] as? String
        }
        
        
        // Do any additional setup after loading the view.
    }
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(true)
//        
////        if !kidsArray.isEmpty {
////            activityIndicator.center = self.view.center
////            activityIndicator.startAnimating()
////            self.view.addSubview(activityIndicator)
////            getComments()
////        }
//        
//        print("kids:\(kidsArray)")
//        print("url:\(url)")
//        tView.reloadData()
//    }
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return kidsArray.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath)
        cell.textLabel?.text = "Loading....."
//        print("comments:\(commentDetails[indexPath.row])")
        var kidIndex = String(self.kidsArray[indexPath.row])
//        if let comment = cache.object(forKey: kidIndex as AnyObject) {
//            let c = comment as? [String: AnyObject]
//            cell.textLabel?.text = c!["text"] as? String
//        }
        if let comment = UserDefaults.standard.object(forKey: kidIndex){
            let c = comment as? [String: AnyObject]
            cell.textLabel?.text = c!["text"] as? String
        }
        else {
            getComments(kid: kidsArray[indexPath.row],index: indexPath.row) { (success, error) in
                if success{
//                    self.cache.setObject(self.commentDetails[indexPath.row] as AnyObject, forKey: kidIndex as AnyObject)
                    
                    UserDefaults.standard.set(self.commentDetails[indexPath.row], forKey: kidIndex)
                    DispatchQueue.main.async {
                        cell.textLabel?.text = self.commentDetails[indexPath.row]["text"] as? String

                    }
                    
                }
            }
        }
        
        return cell
    }
    func getDateStringFromUTC() -> String {
        let date = Date(timeIntervalSince1970: (feedDetails["time"] as? Double)!)
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateStyle = .medium
        
        return dateFormatter.string(from: date)
    }
    func getComments(kid: Int64, index: Int, completionHandler: @escaping(_ success: Bool,_ error: String?) -> Void){
        let kidString = String(kid)
        let urlString = "https://hacker-news.firebaseio.com/v0/item/"+kidString+".json"
        print("urlString:\(urlString)")
        let url = URL(string: urlString)
        let urlRequest = URLRequest(url: url!)
        let session = URLSession.shared
        DispatchQueue.global(qos: .userInitiated).async {
            let task = session.dataTask(with: urlRequest) { (data, response, error) in
                if error != nil {
                    print(error?.localizedDescription)
                    completionHandler(false,error?.localizedDescription)
                    return
                }
                let parsedResult:[String:AnyObject]
                do {
                    parsedResult = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:AnyObject]
                }
                catch{
                    //                completionHandler(false, "error parsing JSON data",nil)
                    return
                }
                //            completionHandler(true,nil,parsedResult)
                self.commentDetails.insert(parsedResult, at: index)
                
                completionHandler(true,nil)
//                DispatchQueue.main.async {
//                    self.tView.reloadData()
//                }
                
//                if kid == self.kidsArray.last {
//                    var last = String(self.kidsArray.last!)
//                    print("feed:\(kidString) feedsId:\(last)")
//                    DispatchQueue.main.async {
//                        self.activityIndicator.stopAnimating()
//                    }
                
                    
                }
            task.resume()
                
            }
        }
}
