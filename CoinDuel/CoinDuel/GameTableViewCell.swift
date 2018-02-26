//
//  UserTableViewCell.swift
//  CoinDuel
//
//  Created by Mitchell Revers on 2/11/18.
//  Copyright © 2018 Capitalize. All rights reserved.
//

import UIKit

class GameTableViewCell: UITableViewCell {
    @IBOutlet weak var coinNameLabel: UILabel!
    @IBOutlet weak var coinAmountLabel: UILabel!
    @IBOutlet weak var coinAmountStepper: UIStepper!
    @IBOutlet weak var coinReturnLabel: UILabel!
    @IBOutlet weak var coinPriceLabel: UILabel!
    @IBOutlet weak var coinPricePreviewLabel: UILabel!
    
    var indexPath = 0
    var game: Game = Game()
    var gameVC: GameViewController = GameViewController()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    @IBAction func coinAmountChanged(_ sender: UIStepper) {
        self.game.coins[self.indexPath].allocation = sender.value
        self.gameVC.submitButton.isHidden = false
        self.gameVC.gameTableView.reloadData()
    }
    
}

