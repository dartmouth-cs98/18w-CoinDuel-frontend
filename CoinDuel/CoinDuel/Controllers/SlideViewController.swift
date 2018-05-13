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

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var contentWidth:CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        
        for image in 0...2 {
            let image2 = String(image)
            let imageToDisplay = UIImage(named: image2)
            print(type(of: image))
            let imageView = UIImageView(image: imageToDisplay)
            let xCoordinate = view.frame.midX + view.frame.width * CGFloat(image)
            contentWidth += view.frame.width
            scrollView.addSubview(imageView)
            imageView.frame = CGRect(x: xCoordinate - 50, y: (view.frame.height / 2) - 50, width: 100, height: 100)
        }
        
        scrollView.contentSize = CGSize(width: contentWidth, height: view.frame.height)

        // Do any additional setup after loading the view.
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset)
        //pageControl.currentPage =
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
