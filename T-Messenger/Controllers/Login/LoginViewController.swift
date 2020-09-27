//
//  LoginViewController.swift
//  T-Messenger
//
//  Created by Tiến on 6/13/20.
//  Copyright © 2020 Tiến. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import Firebase
import JGProgressHUD

class LoginViewController: UIViewController {
    
    let FBLoginBtn = FBLoginButton(frame: .zero, permissions: [.publicProfile, .email])
    let GgLoginBtn = GIDSignInButton(frame: .zero)
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let scrollView:UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let emailField:UITextField = {
        let emailField = UITextField()
        emailField.autocapitalizationType = .none
        emailField.autocorrectionType = .no
        emailField.returnKeyType = .continue
        emailField.layer.cornerRadius = 12
        emailField.layer.borderWidth = 1
        emailField.layer.borderColor = UIColor.black.cgColor
        emailField.placeholder = "Enter your email address"
        emailField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        emailField.leftViewMode = .always
        return emailField
    }()
    
    private let passwordField:UITextField = {
        let passwordField = UITextField()
        passwordField.autocapitalizationType = .none
        passwordField.autocorrectionType = .no
        passwordField.returnKeyType = .continue
        passwordField.layer.cornerRadius = 12
        passwordField.layer.borderWidth = 1
        passwordField.layer.borderColor = UIColor.black.cgColor
        passwordField.placeholder = "Enter your password"
        passwordField.isSecureTextEntry = true
        passwordField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        passwordField.leftViewMode = .always
        return passwordField
    }()
    
    private let loginButton:UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = .link
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    private let FacebookLoginBtn:UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "fb-login-btn"), for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        return button
    }()
    
    
    private let GoogleLoginBtn:UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "google-login-btn"), for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1
        return button
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Log In"
        
        //fb-login-btn
        FBLoginBtn.delegate = self
        FBLoginBtn.isHidden = true
        
        //google login button
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance()?.delegate = self
        
        //Interface setup
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register",
        style: .done,
        target: self,
        action: #selector(DidTapRegister))
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(FacebookLoginBtn)
        scrollView.addSubview(GoogleLoginBtn)
        
        loginButton.addTarget(self,
                              action: #selector(loginBtnAction),
                              for: .touchUpInside)
        
        FacebookLoginBtn.addTarget(self,
                                   action: #selector(FBLoginButtonAction),
                                   for: .touchUpInside)
        
        GoogleLoginBtn.addTarget(self,
                                 action: #selector(GgLoginButtonAction),
                                 for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width/3
        imageView.frame = CGRect(x: (scrollView.width-size)/2,
                                 y: 30,
                                 width: size,
                                 height: size)
        emailField.frame = CGRect(x: 30,
                                  y: imageView.bottom+10,
                                  width: scrollView.width-60,
                                  height: 52)
        passwordField.frame = CGRect(x: 30,
                                  y: emailField.bottom+10,
                                  width: scrollView.width-60,
                                  height: 52)
        loginButton.frame = CGRect(x: 30,
                                   y: passwordField.bottom+10,
                                   width: scrollView.width-60,
                                   height: 52)
        FacebookLoginBtn.frame = CGRect(x: 30,
                                   y: loginButton.bottom+10,
                                   width: scrollView.width-60,
                                   height: 52)
        GoogleLoginBtn.frame = CGRect(x: 30,
                                      y: FacebookLoginBtn.bottom+10,
                                      width: scrollView.width-60,
                                      height: 52)
        

    }
    
    @objc private func DidTapRegister(){
        let vc = RegisterViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @objc private func FBLoginButtonAction(){
        FBLoginBtn.sendActions(for: .touchUpInside)
        FacebookLoginBtn.zoomInWithEasing()
    }
    
    @objc private func GgLoginButtonAction(){
        GgLoginBtn.sendActions(for: .touchUpInside)
        GoogleLoginBtn.zoomInWithEasing()
    }
    
    @objc private func loginBtnAction(){
        print("Login Button tapped")
        loginButton.zoomInWithEasing()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        //Validation email and password
        guard let email = emailField.text, let password = passwordField.text, !email.isEmpty,
            !password.isEmpty, password.count >= 6 else {
                alertUserLoginError()
                return
        }
        
        spinner.show(in: view)
        
        //FIrebase Login
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self] (AuthDataResult, Error) in
            guard let strongself = self else{
                return
            }
            
            DispatchQueue.main.async {
                strongself.spinner.dismiss()
            }
            
            guard let result = AuthDataResult, Error == nil else{
                print("Failed to login")
                return
            }
            UserDefaults.standard.set(email, forKey: "user_email")
            let user = result.user
            
            print("login success as user: \(user)")
            strongself.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    func alertUserLoginError(){
        let alert = UIAlertController(title: "Woops",
                                      message: "Please Enter your account information",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel,
                                      handler: nil))
        present(alert, animated: true)
    }
    
}
extension LoginViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField{
            passwordField.becomeFirstResponder()
        }
        else{
            loginBtnAction()
        }
        return true
    }
}

//facebook login
extension LoginViewController: LoginButtonDelegate{
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("FB Logout Success")
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        print("FB Login Btn Tapped")
        guard let token = result?.token?.tokenString else{
            print("Failed to login via facebook")
            return
        }
        
        GraphRequest(graphPath: "me",
                     parameters: ["fields":"first_name, last_name, picture.type(large), email"],
                     tokenString: token,
                     version: nil,
                     httpMethod: .get).start { (GraphRequestConnection, Result, Error) in
                        guard let result = Result as? [String:Any], Error == nil else{
                            print("Failed to make graph request: \(Error?.localizedDescription ?? " ")")
                            return
                        }
                        
                      
                        // get avatar fb url
                        let picture = result["picture"] as? [String:Any]
                        let picturedata = picture!["data"] as? [String:Any]
                        let pictureUrl = picturedata!["url"] as? String
                        
                        
                        let firstname = result["first_name"] as? String
                        let lastname = result["last_name"] as? String
                        let email = result["email"] as? String
                        
                        UserDefaults.standard.set(email, forKey: "user_email")
                        
                        DatabaseManager.shared.isNewUser(with: email!) { (isNew) in
                            guard isNew == true else {
                                return
                            }
                            print("insert User success")
                            let appUser = AppUser(email: email!, firstname: firstname!, lastname: lastname!)
                            DatabaseManager.shared.insertUser(user: appUser) { (success) in
                                if success{
                                    //upload image
                                    guard let url = URL(string: pictureUrl!) else{
                                        print("no picture url")
                                        return
                                    }
                                    print("downloading data from fb")
                                    
                                    guard let data = try? Data(contentsOf: url) else{
                                        print("no data")
                                        return
                                    }
                                    
                                    let filename = appUser.avatarFileName
                                    StorageManager.shared.uploadAvatar(with: data, filename: filename, completion: { result in
                                        switch result {
                                        case.success(let downloadUrl):
                                            UserDefaults.standard.set(downloadUrl, forKey: "avatar_picture_url")
                                            break
                                        case.failure(let error):
                                            print("Storage error: \(error.localizedDescription) - from fb")
                                            break
                                        }
                                    })
                                }
                                
                            }
                            
                        }
                        
                        let credential = FacebookAuthProvider.credential(withAccessToken: token)
                        FirebaseAuth.Auth.auth().signIn(with: credential) { [weak self] (AuthDataResult, Error) in
                            guard let strongself = self else{
                                return
                            }
                            guard AuthDataResult != nil, Error == nil else{
                                print("FB credential Login Failed: \(Error!)")
                                return
                            }
                            print("Fb credentail Login Success")
                            strongself.navigationController?.dismiss(animated: true, completion: nil)
                        }
        }
    }
}

//google login
extension LoginViewController: GIDSignInDelegate{
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error{
            print("Failed to Login via Google because: \(error.localizedDescription)")
            return
        }
        
        guard let authentication = user.authentication else {
            return
        }
        
        let email = user.profile.email
        let firstname = user.profile.givenName
        let lastname = user.profile.familyName
        UserDefaults.standard.set(email, forKey: "user_email")
        
        DatabaseManager.shared.isNewUser(with: email!) { (isNew) in
            guard isNew == true else {
                return
            }
            
            // if this is new user, insert user information to database
            let appUser = AppUser(email: email!, firstname: firstname!, lastname: lastname!)
            DatabaseManager.shared.insertUser(user: appUser) { (success) in
                if success{
                    
                    if user.profile.hasImage{
                        guard let url = user.profile.imageURL(withDimension: 200) else {
                            print("No url for google")
                            return
                        }
                        guard let data = try? Data(contentsOf: url) else{
                            print("no data")
                            return
                        }
                        //upload image
                        print("uploading google avatar ...")
                        let filename = appUser.avatarFileName
                        StorageManager.shared.uploadAvatar(with: data, filename: filename, completion: { result in
                            switch result {
                            case.success(let downloadUrl):
                                UserDefaults.standard.set(downloadUrl, forKey: "avatar_picture_url")
                                break
                            case.failure(let error):
                                print("Storage error: \(error.localizedDescription) - from fb")
                                break
                            }
                        })
                    }
                }
            }
        }
        
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        FirebaseAuth.Auth.auth().signIn(with: credential) { [weak self] (AuthDataResult, Error) in
            guard let strongself = self else{
                return
            }
            guard AuthDataResult != nil, error == nil else{
                return
            }
            print("Google credential login success")
            strongself.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("Google Logout")
    }
    
    
}
