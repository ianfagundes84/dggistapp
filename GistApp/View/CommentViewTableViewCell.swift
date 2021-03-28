//
//  CommentViewTableViewCell.swift
//  GistApp
//
//  Created by Ian Fagundes on 26/03/21.
//

import UIKit
import Kingfisher

class CommentViewTableViewCell: UITableViewCell {
    
    @IBOutlet weak var ivAuthor: UIImageView!
    @IBOutlet weak var lbAuhorName: UILabel!
    @IBOutlet weak var lbAuthorCommentDate: UILabel!
    @IBOutlet weak var lbTextComment: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func prepare(with comment: CommentElement) {
        lbAuhorName.text = comment.user.login
        
        if let urlImage =  URL(string: comment.user.avatarURL) {
            let processor = RoundCornerImageProcessor(cornerRadius: 20)
            ivAuthor.kf.indicatorType = .activity
            ivAuthor.kf.setImage(with: urlImage, placeholder: UIImage(named: "placeholderImage"), options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1))
            ], completionHandler: {
                result in
                switch result {
                case .success(let value):
                    print("Task done for: \(value.source.url?.absoluteString ?? "")")
                case .failure(let error):
                    print("Job failed: \(error.localizedDescription)")
                }
            })
        }
        
        lbTextComment.text = comment.body
        lbAuthorCommentDate.text = relativeData(comment.createdAt)
    }
}

//MARK: RelativeDateTimeFormatter - iOS13
extension CommentViewTableViewCell {
    
    func relativeData(_ dateString: String) -> String {
        
        let isoDate = dateString
        let dateFormatter = ISO8601DateFormatter()
        let date = dateFormatter.date(from: isoDate)!
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
