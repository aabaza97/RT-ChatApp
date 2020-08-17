//
//  ViewController.swift
//  RT-ChatApp
//
//  Created by Ahmed Abaza on 8/8/20.
//  Copyright © 2020 eyecorps. All rights reserved.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class LoginViewController: UIViewController {

    //MARK: -Interface Elements
    
    private let spinner: JGProgressHUD = {
        let spinner = JGProgressHUD(style: .dark)
        spinner.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        return spinner
    }()
    
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "RT_CHAT"
        label.textAlignment = .center
        label.textColor = .black
        label.font.withSize(30.0)
        label.font = .systemFont(ofSize: 30, weight: .bold)
        return label
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.returnKeyType = .continue
        field.layer.borderWidth = 1
        field.layer.cornerRadius = 2
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Email"
        field.keyboardType = .emailAddress
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.returnKeyType = .done
        field.layer.borderWidth = 1
        field.layer.cornerRadius = 2
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Password"
        field.keyboardType = .emailAddress
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.isSecureTextEntry = true
        return field
    }()
    
    private let btnLogin: UIButton = {
        let btn = UIButton()
        btn.setTitle("Log In", for: .normal)
        btn.backgroundColor = .black
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        btn.isUserInteractionEnabled = true
        return btn
    }()
    
    
    private let btnRegister: UIButton = {
        let btn = UIButton()
        btn.setTitle("Do not have an Account?", for: .normal)
        btn.backgroundColor = .white
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        btn.isUserInteractionEnabled = true
        return btn
    }()
    
    
    //MARK: -overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLoginViewController()
        addSubViews()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureSubViews()
    }
    
    
    
    //MARK: -Functions
    func configureLoginViewController() -> Void {
        self.title = "Log In"
        view.backgroundColor = .white
        
//        let registerButton = UIBarButtonItem(title: "Register", style: .plain, target: self, action: #selector(launchRegistration))
//        registerButton.tintColor = .black
//        navigationItem.rightBarButtonItem = registerButton
        
    }
    
    func addSubViews(){
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(headerLabel)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(btnLogin)
        scrollView.addSubview(btnRegister)
    }
    
    func configureSubViews(){
        //ScrollView Config
        scrollView.frame = view.bounds
        
        //ImageView Config
        let imageSize = scrollView.width / 4
        imageView.frame = CGRect(x: (scrollView.width - imageSize) / 2, y: 20, width: imageSize, height: imageSize)
        
        //Textfields Config
        headerLabel.frame = CGRect(x: 30 , y: imageView.bottom + 16, width: scrollView.width - 60, height: 50)
        emailField.frame = CGRect(x: 30, y: headerLabel.bottom + 16, width: scrollView.width - 60, height: 50)
        passwordField.frame = CGRect(x: 30, y: emailField.bottom + 16, width: scrollView.width - 60, height: 50)
        emailField.delegate = self
        passwordField.delegate = self
        
        //Buttons Config
        btnLogin.frame = CGRect(x: 30, y: passwordField.bottom + 16, width: scrollView.width - 60, height: 50)
        btnRegister.frame = CGRect(x: 30, y: btnLogin.bottom + 16, width: scrollView.width - 60, height: 50)
        btnLogin.addTarget(self, action: #selector(loginPressed), for: .touchUpInside)
        btnRegister.addTarget(self, action: #selector(launchRegistration), for: .touchUpInside)
        
        
    }
    
    
    func alertUser() -> Void {
        let alert = UIAlertController(title: "Woops!", message: "All fields are required", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    
    func showSpinner(indicator: String, loadingText: String = "Loading...") -> Void {
        switch indicator {
        case "Success":
            spinner.indicatorView = JGProgressHUDSuccessIndicatorView()
            spinner.textLabel.text = "Done"
            break
        case "Failed":
            spinner.indicatorView = JGProgressHUDErrorIndicatorView()
            spinner.textLabel.text = "Failed!"
            break
        case "Loading":
            spinner.indicatorView = JGProgressHUDIndeterminateIndicatorView()
            spinner.textLabel.text = loadingText
            break
        default:
            break
        }
        
        spinner.show(in: view, animated: true)
    }
    
    //MARK: -OBJC functions
    @objc func launchRegistration() -> Void {
        let vc = RegisterViewController()
        vc.title = "Create New Account"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func loginPressed(){
        
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text, let password = passwordField.text, !email.isEmpty, !password.isEmpty else {
            alertUser()
            return
        }
        
        
        //Firebase Auth
        showSpinner(indicator: "Loading", loadingText: "Logging In...")
        
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self] (res, error) in
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss(afterDelay: 0.5, animated: true)
            }

            
            if let result = res {
                UserDefaults.standard.set(email, forKey: "email")
                UserDefaults.standard.set(result.user.uid, forKey: "userId")
                strongSelf.spinner.indicatorView = JGProgressHUDSuccessIndicatorView()
                strongSelf.spinner.textLabel.text = "Success"
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (t) in
                    strongSelf.navigationController?.dismiss(animated: true, completion: nil)
                }
                
            } else {
                strongSelf.spinner.indicatorView = JGProgressHUDErrorIndicatorView()
                strongSelf.spinner.textLabel.text = "Failed!"
                return
            }
            
            
        }
    }
    
}




//MARK: -Extensions

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            loginPressed()
        }
        return true
    }
}

