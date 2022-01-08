//
//  FriendsTableViewCell.swift
//  TechChats
//
//  Created by administrator on 08/01/2022.
//

import UIKit

class FriendsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userImg: UIView!
    
    @IBOutlet weak var lblUserName: UILabel!
    
    @IBOutlet weak var lblJobTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
