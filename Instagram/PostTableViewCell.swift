//
//  PostTableViewCell.swift
//  Instagram
//
//  Created by 長谷川勇斗 on 2017/11/26.
//  Copyright © 2017年 長谷川勇斗. All rights reserved.
//

import UIKit

protocol PostTableViewCellDelegate: class {
    func textFieldDidBeginEditing(cell: PostTableViewCell, value: NSString) -> ()
    func textFieldShouldReturn(cell: PostTableViewCell, value: NSString)->()
}

class PostTableViewCell: UITableViewCell, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate{
    weak var delegate: PostTableViewCellDelegate?
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var commentConstraintHeight: NSLayoutConstraint!
    @IBOutlet weak var commentTable: UITableView!
    
    var loadCommentDatas : [[String]] = []

    internal func textFieldDidBeginEditing(_ textField: UITextField) {
        print("DEBUG_PRINT:textFieldDidBeginEditing called")
        self.delegate!.textFieldDidBeginEditing(cell: self, value: textField.text! as NSString)
    }
    
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //captionLabel.text = "textEdited"
        print("DEBUG_PRINT:textFieldShouldReturn in PostTableViewCell called")
        self.delegate!.textFieldShouldReturn(cell: self, value: textField.text! as NSString)
        textField.resignFirstResponder()
        return true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }


    @IBAction func handleCommentButton(_ sender: Any) {
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setPostData(postData: PostData) {
        print("DEBUG_PRINT:setPostData call")
        let nib = UINib(nibName: "CommentTableViewCell", bundle: nil)
        self.commentTable.register(nib, forCellReuseIdentifier: "NestCell")
        self.commentTable.rowHeight = UITableViewAutomaticDimension
        self.commentTable.delegate = self
        self.commentTable.dataSource = self
        print("DEBUG_PRINT:set nib")
        
        self.commentField.delegate = self
        
        self.postImageView.image = postData.image
        self.loadCommentDatas = postData.comments
        print("DEBUG_PRINT:set loadCommentDatas")
        self.commentTable.reloadData()
        
        self.captionLabel.text = "\(postData.name!) : \(postData.caption!)"
        let likeNumber = postData.likes.count
        likeLabel.text = "\(likeNumber)"
        
        let formatter = DateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "ja_JP") as Locale!
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.string(from: postData.date! as Date)
        self.dateLabel.text = dateString
        
        commentConstraintHeight.constant = 0
        
        let commentImage = UIImage(named:"comment")
        self.commentButton.setImage(commentImage, for: UIControlState.normal)
        
        if postData.isLiked {
            let buttonImage = UIImage(named: "like_exist")
            self.likeButton.setImage(buttonImage, for: UIControlState.normal)
        } else {
            let buttonImage = UIImage(named: "like_none")
            self.likeButton.setImage(buttonImage, for: UIControlState.normal)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("DEBUG_PRINT:Row of commentTable:\(loadCommentDatas.count)")
        return loadCommentDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得してデータを設定する
        //print("DEBUG_PRINT:cellForRowAt call")
        let cell = tableView.dequeueReusableCell(withIdentifier: "NestCell", for: indexPath as IndexPath) as! CommentTableViewCell
        let commentData = loadCommentDatas[indexPath.row]
        print("DEBUG_PRINT:set commentData:\(indexPath.row+1)in\(loadCommentDatas.count)")
        cell.setComment(commentData:commentData)
        //cell.commentUserName.text = "kazu:\(loadCommentDatas.count)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        // Auto Layoutを使ってセルの高さを動的に変更する
        return UITableViewAutomaticDimension
    }
    /*
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // セルをタップされたら何もせずに選択状態を解除する
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    */
}
