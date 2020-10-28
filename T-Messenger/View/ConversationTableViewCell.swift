//
//  ConversationTableViewCell.swift
//  T-Messenger
//
//  Created by Tiến on 10/20/20.
//  Copyright © 2020 Tiến. All rights reserved.
//

import UIKit
import SDWebImage

class ConversationTableViewCell: UITableViewCell {
    
    static let identifier = "ConversationTableviewCell"
    
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 40
        imageView.layer.masksToBounds = true
        return imageView
        
    }()
    
    private let userNameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.font = .systemFont(ofSize: 21, weight: .semibold)
        return nameLabel
    }()
    
    private let userMessLabel: UILabel = {
        let messLabel = UILabel()
        messLabel.font = .systemFont(ofSize: 19, weight: .regular)
        messLabel.numberOfLines = 0
        return messLabel
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(userMessLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        userImageView.frame = CGRect(x: 10, y: 10, width: 80, height: 80)
        userNameLabel.frame = CGRect(x: userImageView.right+10,
                                     y: 10,
                                     width: contentView.width-20-userImageView.width,
                                     height: (contentView.height-20)/2)
        userMessLabel.frame = CGRect(x: userImageView.right+20,
                                     y: userNameLabel.bottom+10,
                                     width: contentView.width-20-userImageView.width,
                                     height: (contentView.width-20)/20)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(with model: Conversations){
        self.userNameLabel.text = model.name
        self.userMessLabel.text = model.latestMessage.message
        
        let path = "images/\(model.receiverEmail)_avatar_picture.png"
        StorageManager.shared.getDownloadUrl(for: path) { [weak self] result in
            switch(result){
            case.success(let url):
                DispatchQueue.main.async {
                    self?.userImageView.sd_setImage(with: url, completed: nil)
                }
            case.failure(let error):
                print("failed to get avatar download url:\(error.localizedDescription)")
            }
        }
    }
    
}
