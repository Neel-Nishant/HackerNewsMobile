//
//  DetailTabBarController.swift
//  HackerNewsExercise
//
//  Created by Neel Nishant on 14/04/18.
//  Copyright © 2018 Neel Nishant. All rights reserved.
//

import UIKit

class DetailTabBarController: UITabBarController {
    var kidsArray = [Int64]()
    var url = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(true)
//        print("kids:\(kidsArray)")
//        print("url:\(url)")
//    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
