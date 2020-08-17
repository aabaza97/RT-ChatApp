//
//  NewConversationViewController.swift
//  RT-ChatApp
//
//  Created by Ahmed Abaza on 8/12/20.
//  Copyright © 2020 eyecorps. All rights reserved.
//

import UIKit
import JGProgressHUD


class NewConversationViewController: UIViewController {
    
    
    //MARK: -Properties
    private var users = [User]()
    private var results = [User]()
    private var hasFetched = false
    
    public var conversationDelegate: ConversationDelegate!
    
    
    //MARK: -Interface Elements
    private let searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.placeholder = "Search users..."
        return bar
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private let lblNoResults: UILabel = {
        let lbl = UILabel()
        lbl.text = "No Results"
        lbl.isHidden = true
        lbl.textAlignment = .center
        lbl.font = .systemFont(ofSize: 22, weight: .bold)
        
        return lbl
    }()
    
    private let spinner: JGProgressHUD = {
        let spinner = JGProgressHUD(style: .dark)
        spinner.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        return spinner
    }()
    
    
  
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
        view.backgroundColor = .white
        
        //setting top item to search bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissSelf))
        navigationController?.navigationBar.topItem?.titleView = searchBar
        
        //focus searchBar
        searchBar.becomeFirstResponder()
        
        
        //Add Subviews
        addSubViews()
        
        //Fetch Data
        fetchUsers()
    }
    
    private func configureSubViews(){
//        navigationController?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: UIViewController.self, action: #selector(dismissSelf))
        
        //Search Bar
        searchBar.delegate = self
        
        //TableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        
        //NO results Lable
        lblNoResults.frame = CGRect(x: view.width / 4, y: (view.height - 200) / 2, width: (view.width) / 2 , height: 200)
    }
    
    private func addSubViews(){
        view.addSubview(lblNoResults)
        view.addSubview(tableView)
    }
    
    //MARK: -OBJC Functions
    @objc private func dismissSelf(){
        self.dismiss(animated: true, completion: nil)
    }
    
    
}


//MARK: -TableView Extension
extension NewConversationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = results[indexPath.row].username
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedUser = results[indexPath.row]
        self.dismiss(animated: true) {
            self.conversationDelegate.newConversation(user: selectedUser)
        }
    }
}



//MARK: -Search Extension
extension NewConversationViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchtext = searchBar.text, !searchtext.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        
        //Dismiss Keyboard
        searchBar.resignFirstResponder()
        
        //Clear Previous Results
        results.removeAll()
        
        //Show Spinner
        spinner.show(in: view)
        
        //Search the query
        searchUsers(query: searchtext)
        
    }
    
    func toggleHasFetched() {
        hasFetched = !hasFetched
    }
    
    func searchUsers(query: String) -> Void {
        if hasFetched {
            filterUsers(with: query)
        } else {
            fetchUsers(withFilter: true, query: query)
        }
    }
    
    func fetchUsers(withFilter: Bool = false, query: String? = nil) {
        DbManager.shared.fetchAllUsers { [weak self](result) in
            guard let strongSelf = self else {
                return
            }
            
            switch result{
            case .success(let usersData):
                strongSelf.users = usersData
                strongSelf.toggleHasFetched()
                if withFilter {
                    strongSelf.filterUsers(with: query!)
                }
                break
            case.failure(let err):
                print(err)
                break
            }
            
        }
    }
    
    func filterUsers(with needle: String) -> Void {
        
        
        let results: [User] = self.users.filter ({ user in
            let name = user.username.lowercased()
            
            return name.contains(needle.lowercased())
        })
        
        self.results = results
        let selfUser = self.results.firstIndex { (user) -> Bool in
            return user.email == UserDefaults.standard.value(forKey: "email") as! String
        }
        
        if selfUser != nil {
            self.results.remove(at: selfUser!)
        }
        
        updateUI()
    }
    
    
    func updateUI() {
        self.spinner.dismiss()
        if results.isEmpty {
            self.lblNoResults.isHidden = false
            self.tableView.isHidden = true
        } else {
            self.lblNoResults.isHidden = true
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
    
}
