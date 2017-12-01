//
//  HomeViewController.swift
//  Instagram
//
//  Created by 長谷川勇斗 on 2017/11/22.
//  Copyright © 2017年 長谷川勇斗. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, PostTableViewCellDelegate{

    @IBOutlet weak var tableView: UITableView!
    var postArray: [PostData] = []
    
    var observing = false
    
    var onCommentRow = -1
    var editingPath: IndexPath!
    var lastKeyboardFrame: CGRect = CGRect.zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // テーブルセルのタップを無効にする
        tableView.allowsSelection = false
        
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidBeginEditing(cell: PostTableViewCell, value: NSString)->() {
        print("DEBUG_PRINT:extFieldDidBeginEditing called")
        let path = tableView.indexPathForRow(at: cell.convert(cell.bounds.origin, to: tableView))!
        editingPath = path
    }
    
    func textFieldShouldReturn(cell: PostTableViewCell, value: NSString)->() {
        print("DEBUG_PRINT:textFieldShouldReturn in HomeViewController called")
        let cell: PostTableViewCell = tableView.cellForRow(at: editingPath) as! PostTableViewCell
        let postData = postArray[editingPath!.row]
        let name = Auth.auth().currentUser?.displayName
        let commentText = cell.commentField.text
        let arrComment = [ name! , commentText! ]
        postData.comments.append(arrComment)
        let postRef = Database.database().reference().child(Const.PostPath).child(postData.id!)
        let comments = ["comments": postData.comments]
        postRef.updateChildValues(comments)
        print("DEBUG_PRINT:comment save")
        cell.commentField.text = ""
    }
    
    func scrollTableCell(notification: NSNotification, showKeyboard: Bool) -> () {
        if showKeyboard {
            //print("DEBUG_PRINT:test1")
            // keyboardのサイズを取得
            var keyboardFrame: CGRect = CGRect.zero
            if let userInfo = notification.userInfo {
                if let keyboard = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                    keyboardFrame = keyboard.cgRectValue
                    //print("DEBUG_PRINT:test2")
                }
                //print("DEBUG_PRINT:test3")
            }
            
            // keyboardのサイズが変化した分ContentSizeを大きくする
            let diff: CGFloat = keyboardFrame.size.height - lastKeyboardFrame.size.height
            let newSize: CGSize = CGSize(width: tableView.contentSize.width, height: tableView.contentSize.height + diff)
            tableView.contentSize = newSize
            lastKeyboardFrame = keyboardFrame
            //print("DEBUG_PRINT:test4")
            
            // keyboardのtopを取得
            let keyboardTop: CGFloat = UIScreen.main.bounds.size.height - keyboardFrame.size.height;
            //print("DEBUG_PRINT:test5")
            
            // 編集中セルのbottomを取得
            //print("DEBUG_PRINT: editingPath: \(editingPath)")
            let cell: PostTableViewCell = tableView.cellForRow(at: editingPath) as! PostTableViewCell
            //let cell: PostTableViewCell = tableView.cellForRow(at: IndexPath(row: editingPath!.row, section: editingPath!.section)) as! PostTableViewCell
            //print("DEBUG_PRINT:test6")
            let cellBottom: CGFloat
            //cellBottom = cell.commentField.frame.origin.y - tableView.contentOffset.y + cell.commentField.frame.size.height
            let cellFrameOriginY = cell.frame.origin.y
            let cellFrameSizeHeight = cell.frame.size.height
            let cellCommentFieldFrameSizeHeight = cell.commentField.frame.size.height
            let cellCommentFieldFrameOriginY = cell.commentField.frame.origin.y
            let tableScroll = tableView.contentOffset.y
            let temp = cellFrameSizeHeight - (cellCommentFieldFrameOriginY - cellFrameOriginY) - (1.5 * cellCommentFieldFrameSizeHeight)
            cellBottom = cellFrameOriginY - tableScroll + cellFrameSizeHeight - temp
            /*
            print("DEBUG_PRINT:cellFrameOriginY:\(cellFrameOriginY)")
            print("DEBUG_PRINT:cellFrameSizeHeight:\(cellFrameSizeHeight)")
            print("DEBUG_PRINT:cellCommentFieldFrameSizeHeight:\(cellCommentFieldFrameSizeHeight)")
            print("DEBUG_PRINT:cellCommentFieldFrameOriginY:\(cellCommentFieldFrameOriginY)")
            print("DEBUG_PRINT:tableScroll:\(tableScroll)")
            print("DEBUG_PRINT:cellBottom:\(cellBottom)")
            print("DEBUG_PRINT:keyboardTop:\(keyboardTop)")
            print("DEBUG_PRINT:temp:\(temp)")
            */
            //print("DEBUG_PRINT:test7")
            
            // 編集中セルのbottomがkeyboardのtopより下にある場合
            if keyboardTop < cellBottom {
                // 編集中セルをKeyboardの上へ移動させる
                let newOffset: CGPoint = CGPoint(x: tableView.contentOffset.x, y: tableView.contentOffset.y + cellBottom - keyboardTop)
                tableView.setContentOffset(newOffset, animated: true)
            }
        } else {
            // 画面を下に戻す
            let newSize: CGSize = CGSize(width: tableView.contentSize.width, height: tableView.contentSize.height - lastKeyboardFrame.size.height)
            tableView.contentSize = newSize
            if editingPath != nil {
                tableView.scrollToRow(at: editingPath, at: UITableViewScrollPosition.none, animated: true)
            }
            lastKeyboardFrame = CGRect.zero;
        }
    }
    
    
    func registerNotification() -> () {
        let center: NotificationCenter = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unregisterNotification() -> () {
        let center: NotificationCenter = NotificationCenter.default
        center.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        center.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) -> () {
        scrollTableCell(notification: notification, showKeyboard: true)
    }
    func keyboardWillHide(notification: NSNotification) -> () {
        scrollTableCell(notification: notification, showKeyboard: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerNotification()
        print("DEBUG_PRINT: viewWillAppear")
        
        if Auth.auth().currentUser != nil {
            if self.observing == false {
                // 要素が追加されたらpostArrayに追加してTableViewを再表示する
                let postsRef = Database.database().reference().child(Const.PostPath)
                postsRef.observe(.childAdded, with: { snapshot in
                    print("DEBUG_PRINT: .childAddedイベントが発生しました。")
                    
                    // PostDataクラスを生成して受け取ったデータを設定する
                    if let uid = Auth.auth().currentUser?.uid {
                        let postData = PostData(snapshot: snapshot, myId: uid)
                        self.postArray.insert(postData, at: 0)
                        
                        // TableViewを再表示する
                        self.tableView.reloadData()
                    }
                })
                // 要素が変更されたら該当のデータをpostArrayから一度削除した後に新しいデータを追加してTableViewを再表示する
                postsRef.observe(.childChanged, with: { snapshot in
                    print("DEBUG_PRINT: .childChangedイベントが発生しました。")
                    
                    if let uid = Auth.auth().currentUser?.uid {
                        // PostDataクラスを生成して受け取ったデータを設定する
                        let postData = PostData(snapshot: snapshot, myId: uid)
                        
                        // 保持している配列からidが同じものを探す
                        var index: Int = 0
                        for post in self.postArray {
                            if post.id == postData.id {
                                index = self.postArray.index(of: post)!
                                break
                            }
                        }
                        
                        // 差し替えるため一度削除する
                        self.postArray.remove(at: index)
                        
                        // 削除したところに更新済みのでデータを追加する
                        self.postArray.insert(postData, at: index)
                        
                        // TableViewの現在表示されているセルを更新する
                        self.tableView.reloadData()
                    }
                })
                
                // DatabaseのobserveEventが上記コードにより登録されたため
                // trueとする
                observing = true
            }
        } else {
            if observing == true {
                // ログアウトを検出したら、一旦テーブルをクリアしてオブザーバーを削除する。
                // テーブルをクリアする
                postArray = []
                tableView.reloadData()
                // オブザーバーを削除する
                Database.database().reference().removeAllObservers()
                
                // DatabaseのobserveEventが上記コードにより解除されたため
                // falseとする
                observing = false
            }
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        // Auto Layoutを使ってセルの高さを動的に変更する
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // セルをタップされたら何もせずに選択状態を解除する
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath) as! PostTableViewCell
        cell.delegate = self
        cell.commentField.delegate = self as? UITextFieldDelegate
        cell.setPostData(postData: postArray[indexPath.row])
        
        // セル内のボタンのアクションをソースコードで設定する
        cell.likeButton.addTarget(self, action:#selector(handleButton(sender:event:)), for:  UIControlEvents.touchUpInside)
        
        //コメントボタンが押された時の動作
        cell.commentButton.addTarget(self,action:#selector(handleCommentButton(sender:event:)), for : UIControlEvents.touchUpInside)
        
        // 現在コメント中の行はテキストフィールドの高さを40にする
        if indexPath.row == onCommentRow  {
            cell.commentConstraintHeight.constant = 40
        } else {
            cell.commentConstraintHeight.constant = 0
        }
        return cell
    }
    
    func handleCommentButton(sender: UIButton , event:UIEvent){
        print("DEBUG_PRINT: commentボタンがタップされました。")
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        //let cell = tableView.cellForRow(at: indexPath!) as! PostTableViewCell
        //cell.commentConstraintHeight.constant = 60
        if onCommentRow == indexPath!.row {
            // コメント用のテキストフィールドを閉じる
            onCommentRow = -1
        } else {
            // コメント用のテキストフィールドを開く
            onCommentRow = indexPath!.row
        }
        tableView.reloadData()
    }
    
    // セル内のボタンがタップされた時に呼ばれるメソッド
    func handleButton(sender: UIButton, event:UIEvent) {
        print("DEBUG_PRINT: likeボタンがタップされました。")
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]
        
        // Firebaseに保存するデータの準備
        if let uid = Auth.auth().currentUser?.uid {
            if postData.isLiked {
                // すでにいいねをしていた場合はいいねを解除するためIDを取り除く
                var index = -1
                for likeId in postData.likes {
                    if likeId == uid {
                        // 削除するためにインデックスを保持しておく
                        index = postData.likes.index(of: likeId)!
                        break
                    }
                }
                postData.likes.remove(at: index)
            } else {
                postData.likes.append(uid)
            }
            
            // 増えたlikesをFirebaseに保存する
            let postRef = Database.database().reference().child(Const.PostPath).child(postData.id!)
            let likes = ["likes": postData.likes]
            postRef.updateChildValues(likes)
        }
    }
}
