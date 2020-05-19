//
//  ScoresTableViewCell.swift
//  ECF App
//
//  Created by Bhuvan Belur on 17/08/2019.
//  Copyright © 2019 Bhuvan Belur. All rights reserved.
//

import UIKit

class ScoresTableViewCell: UITableViewCell {

    // Outlets for needed Labels
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var standardCategoryLabel: UILabel!
    @IBOutlet weak var standardScoreLabel: UILabel!
    @IBOutlet weak var rapidScoreLabel: UILabel!
    @IBOutlet weak var rapidCategoryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
