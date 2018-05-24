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
    @IBOutlet weak var coinReturnLabel: UILabel!
    @IBOutlet weak var coinPriceLabel: UILabel!
    @IBOutlet weak var coinPricePreviewLabel: UILabel!
    @IBOutlet weak var coinLogo: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

