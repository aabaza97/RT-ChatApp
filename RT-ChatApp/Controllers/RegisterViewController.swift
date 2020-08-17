//
//  RegisterViewController.swift
//  RT-ChatApp
//
//  Created by Ahmed Abaza on 8/8/20.
//  Copyright © 2020 eyecorps. All rights reserved.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class RegisterViewController: UIViewController {
    
    
    //MARK: -Interface Elements
    
    private let spinner = JGProgressHUD(style: .dark)
    
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
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = .black
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.borderWidth = 1
        return imageView
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let usernameField: UITextField = {
        let field = UITextField()
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.returnKeyType = .continue
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.black.cgColor
        field.placeholder = "Username"
        field.keyboardType = .default
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.returnKeyType = .continue
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.black.cgColor
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
        field.layer.borderColor = UIColor.black.cgColor
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
        btn.setTitle("Sign Up", for: .normal)
        btn.backgroundColor = .black
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        btn.isUserInteractionEnabled = true
        return btn
    }()
    
    
    
    //MARK: -overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        configureRegistrationViewController()
        addSubViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureSubViews()
    }
    
    
    
    //MARK: -Functions
    func configureRegistrationViewController() -> Void {
        self.title = "Sign Up"
        view.backgroundColor = .white
        
        //        let registerButton = UIBarButtonItem(title: "Register", style: .plain, target: self, action: #selector(launchRegistration))
        //        registerButton.tintColor = .black
        //        navigationItem.rightBarButtonItem = registerButton
        
    }
    
    func addSubViews(){
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(headerLabel)
        scrollView.addSubview(usernameField)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(btnLogin)
    }
    
    func configureSubViews(){
        //ScrollView Config
        scrollView.frame = view.bounds
        
        //ImageView Config
        let imageSize = scrollView.width / 4
        let gusture = UITapGestureRecognizer(target: self, action: #selector(pickUserImage))
        imageView.frame = CGRect(x: (scrollView.width - imageSize) / 2, y: 20, width: imageSize, height: imageSize)
        imageView.layer.cornerRadius = imageView.width / 2
        imageView.addGestureRecognizer(gusture)
        
        
        //Textfields Config
        headerLabel.frame = CGRect(x: 30 , y: imageView.bottom + 16, width: scrollView.width - 60, height: 50)
        usernameField.frame = CGRect(x: 30, y: headerLabel.bottom + 16, width: scrollView.width - 60, height: 50)
        emailField.frame = CGRect(x: 30, y: usernameField.bottom + 16, width: scrollView.width - 60, height: 50)
        passwordField.frame = CGRect(x: 30, y: emailField.bottom + 16, width: scrollView.width - 60, height: 50)
        usernameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        
        //Buttons Config
        btnLogin.frame = CGRect(x: 30, y: passwordField.bottom + 16, width: scrollView.width - 60, height: 50)
        btnLogin.addTarget(self, action: #selector(registerPressed), for: .touchUpInside)
        
       
    }
    
    
    func alertUser(message: String = "All fields are required") -> Void {
        let alert = UIAlertController(title: "Woops!", message: message, preferredStyle: .alert)
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
    @objc func registerPressed() {
        guard let email = emailField.text, let password = passwordField.text, let username = usernameField.text,
            !email.isEmpty, !password.isEmpty, !username.isEmpty else {
                alertUser()
                return
        }
        
        //Firebase Registration
        showSpinner(indicator: "Loading", loadingText: "Signing Up...")
        
        DbManager.shared.doesUserExist(with: email) { [weak self] (result) in
            guard let strongSelf = self else {
                return
            }
            
            guard result else {
                strongSelf.alertUser(message: "User is already Registered!")
                return
            }
            
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) {(result, error) in
                
                if let err = error {
                    strongSelf.spinner.indicatorView = JGProgressHUDErrorIndicatorView()
                    strongSelf.spinner.textLabel.text = "Failed!"
                    print(err)
                    return
                } else {
                    UserDefaults.standard.set(email, forKey: "email")
                    strongSelf.spinner.indicatorView = JGProgressHUDSuccessIndicatorView()
                    strongSelf.spinner.textLabel.text = "Success"
                    
                    guard let result = result else {
                        return
                    }
                    
                    
                    let user = User(userId: result.user.uid, username: username, email: email)
                    UserDefaults.standard.set(email, forKey: "email")
                    UserDefaults.standard.set(result.user.uid, forKey: "userId")
                    
                    DbManager.shared.createUser(from: user) { (result) in
                        if result {
                            guard let image = strongSelf.imageView.image,
                                let data = image.pngData() else {
                                return
                            }
                            
                            let filepath = user.profilePictureFilePath
                            
                            StorageManager.shared.uploadImage(with: data, to: N.Dirs.imageDir, fileName: filepath) { (result) in
                                
                                DispatchQueue.main.async {
                                    strongSelf.spinner.dismiss(afterDelay: 0.5, animated: true)
                                    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (t) in
                                        strongSelf.navigationController?.dismiss(animated: true, completion: nil)
                                    }
                                }
                                
                                switch result {
                                case .success(let downloadURL):
                                    UserDefaults.standard.set(downloadURL, forKey: "profile_picture_url")
                                    print(downloadURL)
                                    break
                                case .failure(let err):
                                    print("Storage Manager Error: \(err)")
                                    break
                                }
                            }
                            
                        } else {
                            
                        }
                    }
                    
                }
                
                
            }
        }
        
        
    }
    
    @objc func pickUserImage() {
        presentOptions()
    }
    
}



//MARK: -Extentions

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField {
            emailField.becomeFirstResponder()
        }
        else if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            registerPressed()
        }
        return true
    }
}



extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func presentOptions() -> Void {
        let actionSheet = UIAlertController(title: "Profile Picture", message: "Chose a way", preferredStyle: .actionSheet)
        
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default) {[weak self] _ in
            self?.presentCamera()
        }
        
        let chosePhoto = UIAlertAction(title: "Select Photo", style: .default) { [weak self] _ in
            self?.selectPhoto()
        }
        
        actionSheet.addAction(takePhoto)
        actionSheet.addAction(chosePhoto)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true)
        
    }
    
    func presentCamera() -> Void {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        self.present(vc, animated: true, completion: nil)
    }
    
    func selectPhoto() -> Void {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        self.present(vc, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: { () -> Void in
            guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
                return
            }
            self.imageView.image = selectedImage
        })
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
