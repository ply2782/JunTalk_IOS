//
//  ChattingYouCell.swift
//  JunTalk2
//
//  Created by 바틀 on 2022/06/14.
//

import UIKit
import SwiftUI

class ChattingYouCell: UITableViewCell {
    
    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var personImageView: UIImageView!
    
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var videoThumbNailImageView: UIImageView!
    @IBOutlet weak var videoTimeLabel: UILabel!
    
    
    
    @IBOutlet weak var fileView: UIView!
    @IBOutlet weak var fileTimeLabel: UILabel!
    @IBOutlet weak var fileImageView: UIImageView!
    
    
    @IBOutlet weak var conversationView: UIView!
    @IBOutlet weak var conversationLabelView: CardView!
    @IBOutlet weak var conversationLabel: UILabel!
    @IBOutlet weak var conversationTimeLabel: UILabel!
    
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    // Inside UITableViewCell subclass
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = UIScreen.main.bounds
        let width = UIScreen.main.bounds.size.width
        
        self.conversationLabel.preferredMaxLayoutWidth = (width - 150);
        
    }
    
    
}
