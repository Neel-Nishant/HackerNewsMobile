//
//  ViewController.swift
//  HackerNewsExercise
//
//  Created by Neel Nishant on 13/04/18.
//  Copyright © 2018 Neel Nishant. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn
class ViewController: UIViewController,UITextFieldDelegate, GIDSignInUIDelegate, GIDSignInDelegate{
    var feedsId = [String]()
    
    var feedDetailsDictArray = [[String: AnyObject]]()
    @IBOutlet weak var googleSignIn: UIView!
    @IBOutlet weak var otpTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    var verID: String!
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        GIDSignIn.sharedInstance().signIn()
        self.hideKeyboard()
//        let googleButton = GIDSignInButton()
//        googleButton.frame = googleSignIn.frame
//        
//        googleButton.addTarget(self, action: #selector(googleSignInPressed), for: .touchUpInside)
//        view.addSubview(googleButton)
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        subscribeToNotification()
        
        // Do any additional setup after loading the view, typically from a nib.
    }


    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        unsubscribeFromNotification()
    }
    //MARK:- Notification Methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func subscribeToNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    func unsubscribeFromNotification() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    @objc func keyboardWillShow(notification: Notification) {
        if phoneNumberTextField.isFirstResponder || otpTextField.isFirstResponder {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }

    @objc func keyboardWillHide(notification: Notification) {
        if phoneNumberTextField.isFirstResponder || otpTextField.isFirstResponder {
            view.frame.origin.y = 0
        }
    }
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {

        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            // ...
            print(error.localizedDescription)
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { (user, error) in
            if error != nil {
                print("failed to create a firebase user \(error)")
                return
            }
            let defaults = UserDefaults.standard
            defaults.set(user!.uid, forKey: "uid")
            print("uid:\(user?.uid)")
            self.getNews()
            
            
        }
    }
    
    func getNews() {
        let urlString = "https://hacker-news.firebaseio.com/v0/topstories.json?print=pretty"
        let url = URL(string: urlString)
        let urlRequest = URLRequest(url: url!)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            if error != nil {
                print(error?.localizedDescription)
                //                completionHandler(false,error?.localizedDescription)
                return
            }
            let parsedResult:[Int64]
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [Int64]
            }
            catch{
                //                completionHandler(false, "error parsing JSON data")
                return
            }
            for result in parsedResult {
                let feed = String(result)
                //                print("result:\(feed)")
                self.feedsId.append(feed)
            }
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.performSegue(withIdentifier: "loggedIn", sender: nil)
            }
            
            //            completionHandler(true, nil)
        }
        task.resume()
    }
    
    @IBAction func submitNumber(_ sender: Any) {
        var phoneNumber = phoneNumberTextField.text
    
        if phoneNumberTextField.text != ""{
            PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber!) { (verificationID, error) in
                if error != nil {
                    print(error!.localizedDescription)
                }
                else {
                    let defaults = UserDefaults.standard
                    defaults.set(verificationID, forKey: "authVID")
                }
            }
        }
        
    }
    
    @IBAction func submitOTP(_ sender: Any) {
        if otpTextField.text != "" {
            let defaults = UserDefaults.standard
            let credential: PhoneAuthCredential = PhoneAuthProvider.provider().credential(withVerificationID: defaults.string(forKey: "authVID")!, verificationCode: otpTextField.text!)
            Auth.auth().signIn(with: credential) { (user, error) in
                if error != nil {
                    print(error!.localizedDescription)
                }
                else {
                    let defaults = UserDefaults.standard
                    defaults.set(user!.uid, forKey: "uid")
                    print("loggedIn")
                    self.activityIndicator.startAnimating()
                    self.activityIndicator.center = self.view.center
                    self.view.addSubview(self.activityIndicator)
                    self.getNews()
                }
            }
        }
                
    }
    @IBAction func googleSignInPressed(_ sender: Any) {
        activityIndicator.startAnimating()
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loggedIn" {
            
            let navVC = segue.destination as! UINavigationController
            print("segue.destination.first:\(navVC.viewControllers.first)")
            if let vc = navVC.viewControllers.first as? NewsFeedViewController {
                vc.feedsId = feedsId
            }
            
        }
    }
    
}

extension UIViewController
{
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}

