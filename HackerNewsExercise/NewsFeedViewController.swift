//
//  NewsFeedViewController.swift
//  HackerNewsExercise
//
//  Created by Neel Nishant on 13/04/18.
//  Copyright © 2018 Neel Nishant. All rights reserved.
//

import UIKit

class NewsFeedViewController: UIViewController , UITableViewDelegate, UITableViewDataSource{
    
    static let sharedInstance = NewsFeedViewController()
    var feedsId = [String]()
    var kidsArray = [Int64]()
    var url = ""
    
    var feedDetailsDictArray = [[String: AnyObject]](repeating: ["" : "" as AnyObject], count: 500)
    
    var cache: NSCache<AnyObject, AnyObject> = NSCache()
//    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    @IBOutlet weak var tView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let appDomain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
        }
        
        
    }

    func getArticles(feed: String, index: Int, completionHandler: @escaping(_ success: Bool,_ error: String?) -> Void){
        
        
            let urlString = "https://hacker-news.firebaseio.com/v0/item/"+feed+".json"
            //        print("urlString:\(urlString)")
            let url = URL(string: urlString)
            let urlRequest = URLRequest(url: url!)
            let session = URLSession.shared
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
                self.feedDetailsDictArray.insert(parsedResult, at: index)
//                self.feedDetailsDictArray.append(parsedResult)
                
                completionHandler(true,nil)
                
//                if feed == self.feedsId.last {
//                    print("feed:\(feed) feedsId:\(self.feedsId.last)")
//                    DispatchQueue.main.async {
//                        self.activityIndicator.stopAnimating()
//                    }
//
//
//                }
                
            }
            task.resume()
        
        
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 500
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tView.dequeueReusableCell(withIdentifier: "feedCell", for: indexPath)
        cell.textLabel?.text = "Loading..."
//        cell.textLabel?.text = feedDetailsDictArray[indexPath.row]["title"] as! String
        
        if let feed = cache.object(forKey: self.feedsId[indexPath.row] as AnyObject){
            print("feed:\(feed)")
//            self.feedDetailsDictArray.append(feed as! [String : AnyObject])
            let f = feed as? [String: AnyObject]
            DispatchQueue.main.async {
                cell.textLabel?.text = f!["title"] as? String
            }
        }
        else {
            getArticles(feed: feedsId[indexPath.row], index: indexPath.row) { (success, error) in
                if success {
                    self.cache.setObject(self.feedDetailsDictArray[indexPath.row] as AnyObject, forKey: self.feedsId[indexPath.row] as AnyObject)
                    DispatchQueue.main.async {
                        cell.textLabel?.text = self.feedDetailsDictArray[indexPath.row]["title"] as? String
                        
                    }
                   
                }
            }
        }
    
        return cell
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if let kids = feedDetailsDictArray[indexPath.row]["kids"] as? [Int64]{
//            kidsArray = kids
//        }
//        if let ur = feedDetailsDictArray[indexPath.row]["url"] as? String {
//            url = ur
//        }
        performSegue(withIdentifier: "commentView", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "commentView" {
                let vc = segue.destination as? DetailTabBarController
            let url = feedDetailsDictArray[(tView.indexPathForSelectedRow?.row)!]["url"] as? String ?? ""
            if let kidsArray = feedDetailsDictArray[(tView.indexPathForSelectedRow?.row)!]["kids"]{
                let vec = vc?.viewControllers![0] as! CommentsViewController
                vec.url = url
                vec.kidsArray = kidsArray as! [Int64]
                vec.feedDetails = feedDetailsDictArray[(tView.indexPathForSelectedRow?.row)!]
                
                
            }
            let vec2 = vc?.viewControllers![1] as! ArticleWebViewController
            vec2.feedDetails = feedDetailsDictArray[(tView.indexPathForSelectedRow?.row)!]
            vec2.url = url
                print("kids:\(kidsArray)")
                print("url:\(url)")
            
            
            
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }

}
