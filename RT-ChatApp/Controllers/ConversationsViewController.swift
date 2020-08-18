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
    var isLoggedIn: Bool = false
    var conversations: [Conversation] = [Conversation]()
    
    
    //MARK: -Interface Elements
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
//        table.register(ConversationTableViewCell.self, forCellReuseIdentifier: ConversationTableViewCell.cellId)
        table.register(ConversationTableViewCell.self, forCellReuseIdentifier: ConversationTableViewCell.cellId)
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
        isLoggedIn = getLoginStatus()
        configureViewController()
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !getLoginStatus() {
            launchLogin()
        } else {
            getUser { [weak self](result) in
                switch result {
                case.failure(_):
                    break
                case.success(let user):
                    self?.appUser = user
                    self?.fetchConversations()
                    break
                }
            }
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
    private func getLoginStatus() -> Bool {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            return false
        }
        return true
    }
    
    private func getUser(completion: @escaping (Result<User, Error>) -> Void) -> Void {
        let appUserId = UserDefaults.standard.string(forKey: "userId")
        guard let userId = appUserId else {
            return
        }
        
        DbManager.shared.getUser(from: userId) {(result) in
            switch result {
            case .success(let user):
                completion(.success(user))
                break
            case .failure(_):
                completion(.failure(DbManager.DBManagerErrors.NoUserWithProvidedId))
                print("found no user.....")
                break
            }
        }
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
    
    
    private func openChat(for user: User? = nil, stateOf newConversation: Bool = false) {
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
    
    
    private func fetchConversations(){
        DbManager.shared.fetchConversations(for: appUser) {[weak self] (result) in
            switch result {
            case .success(let data):
                guard !data.isEmpty else {
                    return
                }
                self?.conversations = data
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                break
            case.failure(_):
                print("no data was fetched")
                break
            }
        }
    }
    
    
    private func getOtherUser(from users: [User]) -> User{
        var otherUser: User = users[0]
        if (otherUser.userId == appUser.userId) {
            otherUser = users[1]
        }
        return otherUser
    }
    
    //MARK: -Objc Functions
    
    
}



// MARK: -Extensions
extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.cellId, for: indexPath) as! ConversationTableViewCell
        cell.conversation = conversations[indexPath.row]
        cell.otherUser = getOtherUser(from: conversations[indexPath.row].usersData)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        let dummyUser = User(userId: "id", username: "username", email: "email@mail.com")
        tableView.deselectRow(at: indexPath, animated: true)
        let otherUser = getOtherUser(from: conversations[indexPath.row].usersData)
        openChat(for: otherUser)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
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
        DbManager.shared.doesConversationExist(between: conversationMembers) { [weak self] (result) in
            switch result {
            case.success(_):
                self?.openChat(for: user, stateOf: false)
                break
            case.failure(_):
                self?.openChat(for: user, stateOf: true)
                break
            }
        }
    }
    
    
}
