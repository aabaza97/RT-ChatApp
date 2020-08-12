//
//  SettingsViewController.swift
//  RT-ChatApp
//
//  Created by Ahmed Abaza on 8/11/20.
//  Copyright © 2020 eyecorps. All rights reserved.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController {
    
    //MARK: -Outlets
    @IBOutlet weak var tableView: UITableView!
    
    
    //MARK: -UI Elements

    
    
    //MARK: -Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureSubViews()
    }
    
    
    
    //MARK: -Functions
    
    private func configureViewController() {
        addSubViews()
    }
    
    private func configureSubViews() {
        //Table View
        configureTableView()
    }
    
    private func addSubViews() {
        
    }
    
    private func configureTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
    
    private func launchLogin(withAnimation animated: Bool = false) -> Void {
        let vc = LoginViewController()
        let navController = UINavigationController(rootViewController: vc)
        navController.navigationBar.prefersLargeTitles = false
        navController.navigationBar.backgroundColor = .white
        navController.modalPresentationStyle = .fullScreen
        
        present(navController, animated: animated)
    }
    
    //MARK: -OBJC Functions
    
    
    
}


//MARK: -Extenstions

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Log Out"
        cell.textLabel?.textColor = .red
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        do {
            try FirebaseAuth.Auth.auth().signOut()
            launchLogin(withAnimation: true)
        } catch let err {
            print("Failed to Log Out. Reason: \(err)")
        }
    }
}
