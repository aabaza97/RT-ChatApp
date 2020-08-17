//
//  ConversationsViewController.swift
//  RT-ChatApp
//
//  Created by Ahmed Abaza on 8/8/20.
//  Copyright © 2020 eyecorps. All rights reserved.
//

import UIKit
import FirebaseAuth
import JGProgressHUD
//import MessageKit

class ConversationsViewController: UIViewController {

    //MARK: -Properties
    var appUser: User!
    
    
    //MARK: -Interface Elements
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let noConversationLabel: UILabel = {
        let label = UILabel()
        label.text = "No Conversations! Tap + to start a new one."
        label.textAlignment = .center
        label.textColor = .black
        label.font = .systemFont(ofSize: 30, weight: .bold)
        label.isHidden = true
        return label
    }()
    
    
    
    //MARK: -Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !isLoggedIn() {
            launchLogin()
        } else {
            // get user
            // load conversations
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureSubViews()
    }
    
    
    
    //MARK: -Actions
    
    @IBAction func composeMessageTapped(_ sender: UIBarButtonItem) {
        let vc = NewConversationViewController()
        vc.conversationDelegate = self
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC,animated: true)
    }
    
    //MARK: -Functions
    private func isLoggedIn() -> Bool {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            return false
        }
        
        let appUserId = UserDefaults.standard.value(forKey: "userId") as? String
        if let appUserId = appUserId {
            DbManager.shared.getUser(from: appUserId) { [weak self] (result) in
                switch result {
                case .success(let user):
                    self?.appUser = user
                    break
                case .failure(_):
                    self?.launchLogin()
                    break
                }
            }
        } else {
            return false
        }
        return true
    }
    
    private func configureViewController() {
        self.title = "Chats"
        addSubViews()
    }
    
    private func addSubViews(){
        view.addSubview(tableView)
        view.addSubview(noConversationLabel)
    }
    
    private func configureSubViews() {
        // TableView
        setupTableView()
        tableView.frame = view.bounds
        tableView.isHidden = false
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func launchLogin() {
        let vc = LoginViewController()
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .fullScreen
        navController.navigationBar.prefersLargeTitles = false
        navController.navigationBar.backItem?.title = " "
        navController.navigationBar.backgroundColor = .white
        
        present(navController, animated: false)
    }
    
    
    private func openChat(user: User? = nil, stateOf newConversation: Bool = false) {
        guard let user = user else {
            return
        }
        
        let vc = ChatViewController()
        vc.title = user.username
        vc.otherUser = user
        vc.appUser = appUser
        vc.isNewConversation = newConversation
        vc.view.backgroundColor = .white
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    //MARK: -Objc Functions
    
    
}



// MARK: -Extensions
extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Hello World"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let dummyUser = User(userId: "id", username: "username", email: "email@mail.com")
        openChat(user: dummyUser)
    }
}


extension ConversationsViewController: ConversationDelegate {
    func newConversation(user: User) {
        /*
         check if conversation exists?
         - if true --- pass isNewConversation = true
         - if false --- pass false
         */
        
        var conversationMembers = [User]()
        conversationMembers.append(user)
        conversationMembers.append(appUser)
        DbManager.shared.doesConversationExist(between: conversationMembers) { [weak self] (exists) in
                self?.openChat(user: user, stateOf: !exists)
        }
    }
    
    
}
