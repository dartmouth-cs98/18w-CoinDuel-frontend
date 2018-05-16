//
//  SlideViewController.swift
//  CoinDuel
//
//  Created by Anish Chadalavada on 5/13/18.
//  Copyright © 2018 Capitalize. All rights reserved.
//

import UIKit

// Below code from tutorial at
// https://www.youtube.com/watch?v=X2Wr4TtMG6Q

class SlideViewController: UIViewController, UIScrollViewDelegate {
    
    // Code from https://stackoverflow.com/questions/29074454/how-to-create-a-scroll-view-with-a-page-control-using-swift
    
    
    @IBOutlet weak var imgScrollView: UIScrollView!
    @IBOutlet weak var imgPageController: UIPageControl!
    var sliderImagesArray = NSMutableArray()
    
    let imagelist = ["1", "2", "3", "4", "5"]
    var scrollView = UIScrollView()
    
    var pageControl : UIPageControl = UIPageControl(frame:CGRect(x: 50, y: 300, width: 200, height: 50))
    
    var yPosition:CGFloat = 0
    var scrollViewContentSize:CGFloat=0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
   

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
