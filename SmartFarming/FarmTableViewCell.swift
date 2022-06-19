//
//  FarmTableViewCell.swift
//  SmartFarming
//
//  Created by Eren Bağcı on 16.06.2022.
//

import UIKit

class FarmTableViewCell: UITableViewCell {

    @IBOutlet weak var farmNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configUI(farmName: String) {
        farmNameLabel.text = farmName
    }
}
