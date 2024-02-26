//
//  ChattingMeCell.swift
//  JunTalk2
//
//  Created by 바틀 on 2022/06/14.
//

import UIKit

class ChattingMeCell: UITableViewCell {
    
    
    
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var videoTimeLabel: UILabel!
    @IBOutlet weak var videoThumbNailImageView: UIImageView!
    
    
    
    
    
    @IBOutlet weak var fileView: UIView!
    @IBOutlet weak var fileTimeLabel: UILabel!
    @IBOutlet weak var fileImageView: UIImageView!
    
    
    
    @IBOutlet weak var conversationView: UIView!
    @IBOutlet weak var conversationLabelView: CardView!
    @IBOutlet weak var conversationTimeLabel: UILabel!
    @IBOutlet weak var conversationLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // Inside UITableViewCell subclass
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = UIScreen.main.bounds
        let width = UIScreen.main.bounds.size.width
        
        self.conversationLabel.preferredMaxLayoutWidth = (width - 150);
        
    }
    
    
}
