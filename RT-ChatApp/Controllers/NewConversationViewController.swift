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
    
    
    //MARK: -Properties

    
    //MARK: -Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
    }

    
    
    //MARK: -Functions
    
    private func configureViewController() {
        view.backgroundColor = .white
        
        //setting top item to search bar
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationController?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: UIViewController.self, action: #selector(dismissSelf))
        
        //focus searchBar
        searchBar.becomeFirstResponder()
        
    }
    
    private func configureViews(){
        //Search Bar
        searchBar.delegate = self
    }
    
    //MARK: -OBJC Functions
    @objc private func dismissSelf(){
        self.dismiss(animated: true, completion: nil)
    }
    
    
}


extension NewConversationViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
}
