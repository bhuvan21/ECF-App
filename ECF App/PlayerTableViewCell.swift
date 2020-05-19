//
//  PlayerTableViewCell.swift
//  ECF App
//
//  Created by Bhuvan on 22/10/2019.
//  Copyright © 2019 Bhuvan Belur. All rights reserved.
//

import UIKit

class PlayerTableViewCell: UITableViewCell {

    // Outlets to needed labels
    @IBOutlet weak var playerName: UILabel!
    @IBOutlet weak var standardRating: UILabel!
    @IBOutlet weak var rapidRating: UILabel!
    @IBOutlet weak var extraInfo: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
