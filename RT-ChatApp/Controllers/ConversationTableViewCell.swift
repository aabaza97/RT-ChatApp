//
//  ConversationTableViewCell.swift
//  RT-ChatApp
//
//  Created by Ahmed Abaza on 8/18/20.
//  Copyright © 2020 eyecorps. All rights reserved.
//

import UIKit
import SDWebImage

class ConversationTableViewCell: UITableViewCell {
    
    //MARK: -Interface Elements
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 21, weight: .bold)
        return lbl
    }()
    
    private let messageLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 19, weight: .regular)
        lbl.numberOfLines = 0
        return lbl
    }()
    
    //MARK: -Properties
    public var conversation: Conversation!
    public var otherUser: User!
    static let cellId: String = "ConversationTableViewCell"

    //MARK: -Inits & overrides
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureSubviews()
        configureCell(with: conversation, for: otherUser)
    }
    
    //MARK: -Functions
    public func configureCell(with conversation: Conversation, for otherUser: User) {
        usernameLabel.text = otherUser.username
        messageLabel.text = conversation.latestMessageContent
        let path = "images/\(DbManager.shared.getProfilePictureFileName(from: otherUser.email))"
        StorageManager.shared.downloadURL(for: path) { [weak self] (result) in
            switch result {
            case .success(let imageUrl):
                DispatchQueue.main.async {
                    self?.userImageView.sd_setImage(with: imageUrl, completed: nil)
                }
                break
            case .failure(_):
                break
            }
        }
    }
    
    public func addSubviews(){
        contentView.addSubview(userImageView)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(messageLabel)
    }
    
    public func configureSubviews(){
        userImageView.frame = CGRect(x: 16, y: 16, width: 100, height: 100)
        usernameLabel.frame = CGRect(x: (userImageView.right + 16), y: 16,
                                     width: (contentView.width - userImageView.width - 32),
                                     height: (contentView.height - 32) / 2)
        messageLabel.frame = CGRect(x: (userImageView.right + 16), y: (usernameLabel.bottom + 10),
                                    width: (contentView.width - userImageView.width - 32),
                                    height: (contentView.height - 20) / 2)
    }
}
