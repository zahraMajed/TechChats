//
//  RecentChatTableViewCell.swift
//  TechChats
//
//  Created by administrator on 06/01/2022.
//

import UIKit

class RecentChatTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblUserChat: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
