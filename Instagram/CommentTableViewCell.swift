//
//  CommentTableViewCell.swift
//  Instagram
//
//  Created by 長谷川勇斗 on 2017/11/30.
//  Copyright © 2017年 長谷川勇斗. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {
    @IBOutlet weak var commentUserName: UILabel!
    @IBOutlet weak var commentText: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setComment(commentData : [ String ]){
        print("DEBUG_PRINT:setComment call")
        self.commentUserName.text = commentData[0]
        self.commentText.text = commentData[1]
    }
    
}
