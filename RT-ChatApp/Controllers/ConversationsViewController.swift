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
    private let btnLogout: UIButton = {
        let btn = UIButton()
        btn.setTitle("LogOut", for: .normal)
        btn.isUserInteractionEnabled = true
        return btn
    }()
    
    
    
    //MARK: -Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
//        view.backgroundColor = .red
//        view.addSubview(btnLogout)
//        btnLogout.frame = CGRect(x: 30, y: 20, width: 100, height: 50)
//        btnLogout.addTarget(self, action: #selector(logOut), for: .touchUpInside)
        
        configureViewController()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !isLoggedIn() {
            launchLogin()
        } else {
            //TODO: load my converstaions
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureSubViews()
    }
    
    
    
    //MARK: -Actions
    
    @IBAction func composeMessageTapped(_ sender: UIBarButtonItem) {
        let vc = NewConversationViewController()
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC,animated: true)
    }
    
    //MARK: -Functions
    private func isLoggedIn() -> Bool {
        if FirebaseAuth.Auth.auth().currentUser == nil {
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
    
    
    private func openChat(title: String) {
        let vc = ChatViewController()
        vc.title = title
        vc.view.backgroundColor = .red
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    //MARK: -Objc Functions
    @objc private func logOut(){
        do {
            try FirebaseAuth.Auth.auth().signOut()
            launchLogin()
        } catch let err {
            print(err)
        }
    }
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
        guard let title = tableView.cellForRow(at: indexPath)?.textLabel?.text else {
            return
        }
        openChat(title: title)
    }
}
