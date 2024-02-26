//
//  TabBarCollectionViewCell.swift
//  JunTalk2
//
//  Created by 바틀 on 2022/05/09.
//

import UIKit

class TabBarCollectionViewCell: UICollectionViewCell  {

    @IBOutlet weak var titleLabel: UILabel!
    
    
    override var isSelected: Bool {
        didSet{            
            self.titleLabel.textColor = isSelected ? .black : .lightGray 
        }
    }
}



