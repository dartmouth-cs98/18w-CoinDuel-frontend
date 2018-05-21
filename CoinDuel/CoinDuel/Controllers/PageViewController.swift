//
//  PageViewController.swift
//  CoinDuel
//
//  Created by Anish Chadalavada on 5/21/18.
//  Copyright © 2018 Capitalize. All rights reserved.
//  Code from https://www.youtube.com/watch?v=RVAtqQ8CyKM

import UIKit

class PageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        <#code#>
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        <#code#>
    }
    
    
    lazy var orderedViewControllers: [UIViewController] = {
        return [self.newVc(viewController: "sbRed"),
                self.newVc(viewController: "sbBlue")]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func newVc(viewController: String) -> UIViewController {
        return UIStoryboard(name: "login", bundle: nil).instantiateViewController(withIdentifier:viewController)
    }

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
