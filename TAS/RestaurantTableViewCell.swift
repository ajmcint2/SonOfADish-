//
//  RestaurantTableViewCell.swift
//  TAS Group Project
//
//  Created by Alex McIntosh on 3/24/16.
//  Copyright © 2016 Alex McIntosh. All rights reserved.
//

import UIKit
import CoreData

class RestaurantTableViewCell: UITableViewCell {

    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var img: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
