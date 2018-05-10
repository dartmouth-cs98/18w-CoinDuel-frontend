//
//  SlideViewController.swift
//  CoinDuel
//
//  Created by Anish Chadalavada on 5/10/18.
//  Copyright © 2018 Capitalize. All rights reserved.
//

import UIKit

// This code is also based on this tutorial

// https://www.youtube.com/watch?v=Vq71SPkJIus

class SlideViewController: UIViewController {
    
    
    @IBOutlet weak var slideScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
 
    }
    
    // 2 functions below based on tutorial at https://www.youtube.com/watch?v=Vq71SPkJIus
    
    func createSlides() -> [Slide] {
        
        let slide1:Slide = Bundle.main.loadNibNamed("Slide", owner: Slide, options: nil)
        
        return []
    }
    
    func setupSlideScrollView(slides:[Slide]) {
        
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
