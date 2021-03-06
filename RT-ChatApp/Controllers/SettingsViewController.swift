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
        tableView.tableHeaderView = configureHeader()
    }
    
    
    private func configureHeader() -> UIView? {
        guard let email = UserDefaults.standard.string(forKey: "email") else {
            return nil
        }
        let filename = DbManager.shared.getProfilePictureFileName(from: email)
        let path = N.Dirs.imageDir + filename
        
        //View
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 300))
        headerView.backgroundColor = .lightGray
        
        //ImageView
        let imageView = UIImageView(frame: CGRect(x: (headerView.width - 150) / 2, y: 75, width: 150, height: 150))
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 2
        imageView.layer.cornerRadius = imageView.width / 2
        imageView.layer.masksToBounds = true
        
        headerView.addSubview(imageView)
        
        StorageManager.shared.downloadURL(for: path) { (result) in
            switch result{
            case .failure(let err):
                print(err)
                break
            case .success(let url):
                self.downloadImage(imageView: imageView, url: url)
            }
        }
        
        return headerView
    }
    
    private func downloadImage(imageView: UIImageView, url: URL) -> Void {
        URLSession.shared.dataTask(with: url) { (data, _, err) in
            guard let data = data, err == nil else {
                return
            }
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                imageView.image = image
            }
        }.resume()
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
