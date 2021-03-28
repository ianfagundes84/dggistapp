//
//  CommentsTableViewController.swift
//  GistApp
//
//  Created by Ian Fagundes on 25/03/21.
//

import UIKit

class CommentsTableViewController: UITableViewController {
    
    var comments: Comment = []
    let shared = APIManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return comments.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CommentViewTableViewCell
        
        cell.prepare(with: comments[indexPath.row] )
        
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //Prevent using lower than iOS 13 the delete swipe action will show up as a trailing swipe action by default.
    override func tableView(_ tableView: UITableView,
                            editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let commentIndex = comments[indexPath.row].id
        
        let editComment = UIContextualAction(style: .normal, title: "Edit") { [weak self] (action, view, completionHandler)  in
            self?.handleEditComment(for: commentIndex)
            completionHandler(true)
        }
        editComment.backgroundColor = .systemIndigo
        
        let deleteComment = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completionHandler) in
            self?.handleMoveToTrash(for: commentIndex) { status in
                if status {
                    //TODO: Review
                    self?.comments.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    completionHandler(true)
                } else {
                    completionHandler(false)
                }
            }
        }
        
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteComment, editComment])
        
        return swipeActions
    }
    //TODO: AddComment
    @IBAction func addComment(_ sender: UIBarButtonItem) {
        let ac = UIAlertController(title: "Comment", message: "Leave your contribution for this gist", preferredStyle: .alert)
        ac.addTextField()
        let sendCommentAction = UIAlertAction(title: "Send", style: .default) { [unowned ac, weak self] _ in
            if let comment = ac.textFields![0].text {
                print(comment)
                self?.shared.publishComment(commentText: comment) { result in
                    switch result {
                    case .success(let commentElement):
                        self?.comments.append(commentElement)
                        self?.tableView.reloadData()
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        ac.addAction(cancelAction)
        ac.addAction(sendCommentAction)
    
        present(ac, animated: true)
    }
}

//Delegate handler region
extension CommentsTableViewController {
    
    private func handleMoveToTrash(for commentIndex: Int, completion: @escaping (Bool) -> Void) {
        print("Moved to trash - \(commentIndex)")
        shared.deleteComment(commentIndex: "\(commentIndex)") { status in
            if status {
                completion(status)
                print("Item Deleted")
            } else {
                completion(status)
                print("Problem during deletion")
            }
        }
    }
    
    private func handleEditComment(for commentIndex: Int) {
        print("Edit comment -  \(commentIndex)")
        let ac = UIAlertController(title: "Edit box", message: "Edit your comment for this gist", preferredStyle: .alert)
        ac.addTextField()
        let editCommentAction = UIAlertAction(title: "Save", style: .default) { [unowned ac, weak self] _ in
            if let commentBody = ac.textFields![0].text {
                self?.shared.updateComment(commentText: commentBody, commentID: "\(commentIndex)") { result in
                    switch result {
                    case .success(let commentElement):
                        let teste = self?.comments.enumerated().filter { $0.element.id == commentIndex }
                        self?.tableView.reloadData()
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        ac.addAction(cancelAction)
        ac.addAction(editCommentAction)
    
        present(ac, animated: true)
    }
}
