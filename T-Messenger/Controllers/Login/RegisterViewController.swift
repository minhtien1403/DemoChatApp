//
//  RegisterViewController.swift
//  T-Messenger
//
//  Created by Tiến on 6/13/20.
//  Copyright © 2020 Tiến. All rights reserved.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class RegisterViewController: UIViewController {

    private let spinner = JGProgressHUD(style: .dark)
    
    private let scrollView:UIScrollView = {
            let scrollView = UIScrollView()
            scrollView.clipsToBounds = true
            return scrollView
        }()
        
        private let imageView: UIImageView = {
            let imageView = UIImageView()
            imageView.image = UIImage(systemName: "person.circle")
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 0
            imageView.tintColor = .gray
            imageView.contentMode = .scaleAspectFit
            return imageView
        }()
        
        private let FirstnameField:UITextField = {
            let emailField = UITextField()
            emailField.autocapitalizationType = .none
            emailField.autocorrectionType = .no
            emailField.returnKeyType = .continue
            emailField.layer.cornerRadius = 12
            emailField.layer.borderWidth = 1
            emailField.layer.borderColor = UIColor.black.cgColor
            emailField.placeholder = "Enter your first name"
            emailField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
            emailField.leftViewMode = .always
            return emailField
        }()
    
        private let LastnameField:UITextField = {
            let emailField = UITextField()
            emailField.autocapitalizationType = .none
            emailField.autocorrectionType = .no
            emailField.returnKeyType = .continue
            emailField.layer.cornerRadius = 12
            emailField.layer.borderWidth = 1
            emailField.layer.borderColor = UIColor.black.cgColor
            emailField.placeholder = "Enter your last name"
            emailField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
            emailField.leftViewMode = .always
            return emailField
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
        
        private let registerButton:UIButton = {
            let button = UIButton()
            button.setTitle("Register", for: .normal)
            button.backgroundColor = .systemGreen
            button.layer.cornerRadius = 12
            button.layer.masksToBounds = true
            button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
            
            return button
        }()

        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .white
            title = "Register"
            
           
            
            view.addSubview(scrollView)
            scrollView.addSubview(imageView)
            scrollView.addSubview(FirstnameField)
            scrollView.addSubview(LastnameField)
            scrollView.addSubview(emailField)
            scrollView.addSubview(passwordField)
            scrollView.addSubview(registerButton)
            
            registerButton.addTarget(self,
                                  action: #selector(registerBtnAction),
                                  for: .touchUpInside)
            
            FirstnameField.delegate = self
            LastnameField.delegate = self
            emailField.delegate = self
            passwordField.delegate = self
            
            imageView.isUserInteractionEnabled = true
            scrollView.isUserInteractionEnabled = true
            
            let gesture = UITapGestureRecognizer(target: self, action: #selector(DidTapChangeAvatar))
            imageView.addGestureRecognizer(gesture)
        }
        
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            scrollView.frame = view.bounds
            let size = scrollView.width/3
            imageView.frame = CGRect(x: (scrollView.width-size)/2,
                                     y: 50,
                                     width: size,
                                     height: size)
            imageView.layer.cornerRadius = imageView.width/2
            FirstnameField.frame = CGRect(x: 30,
                                          y: imageView.bottom+10,
                                          width: scrollView.width-60,
                                          height: 52)
            LastnameField.frame = CGRect(x: 30,
                                         y: FirstnameField.bottom+10,
                                         width: scrollView.width-60,
                                         height: 52)
            emailField.frame = CGRect(x: 30,
                                      y: LastnameField.bottom+10,
                                      width: scrollView.width-60,
                                      height: 52)
            passwordField.frame = CGRect(x: 30,
                                         y: emailField.bottom+10,
                                         width: scrollView.width-60,
                                         height: 52)
            registerButton.frame = CGRect(x: 30,
                                       y: passwordField.bottom+10,
                                       width: scrollView.width-60,
                                       height: 52)

        }
        
        @objc private func DidTapChangeAvatar(){
            print("change avatar")
            presentPhotoActionSheet()
        }
        
        
        @objc private func registerBtnAction(){
            print("Register Button tapped")
            registerButton.zoomInWithEasing()
            //dissmiss keyboard when register button clicked
            FirstnameField.resignFirstResponder()
            LastnameField.resignFirstResponder()
            emailField.resignFirstResponder()
            passwordField.resignFirstResponder()
            //Validation Information
            guard let firstname = FirstnameField.text, let lastname = LastnameField.text,
                let email = emailField.text, let password = passwordField.text,
                !email.isEmpty,
                !password.isEmpty,
                !firstname.isEmpty,
                !lastname.isEmpty,
                password.count >= 6 else {
                    alertUserLoginError(mess: "Please Enter your information to register a account")
                    return
            }
            
            //FIrebase Login
            spinner.show(in: view)
            
            DatabaseManager.shared.isNewUser(with: email, completion: { [weak self] isNew in
                guard let strongself = self else{
                    return
                }
                
                DispatchQueue.main.async {
                    strongself.spinner.dismiss()
                }
                
                guard isNew == true else{
                    strongself.alertUserLoginError(mess: "This email is already exist, chosse another email")
                    return
                }
                UserDefaults.standard.set(email, forKey: "user_email")
                
                print("\(isNew)")
                FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { (AuthDataResult, Error) in
                    guard AuthDataResult != nil, Error == nil else{
                        print("Failed to create new user")
                        return
                    }
                    let appUser = AppUser(email: email, firstname: firstname, lastname: lastname)
                    DatabaseManager.shared.insertUser(user: appUser) { (success) in
                        if success{
                            // upload image
                            guard let image = strongself.imageView.image, let data = image.pngData() else{
                                return
                            }
                            let filename = appUser.avatarFileName
                            StorageManager.shared.uploadAvatar(with: data, filename: filename, completion: { result in
                                switch result {
                                case.success(let downloadUrl):
                                    UserDefaults.standard.set(downloadUrl, forKey: "avatar_picture_url")
                                    break
                                case.failure(let error):
                                    print("Storage error: \(error.localizedDescription)")
                                    break
                                }
                            })
                        }
                    }
                    strongself.navigationController?.dismiss(animated: true, completion: nil)
                }
                
            })
            
        }
        
    func alertUserLoginError(mess:String){
            let alert = UIAlertController(title: "Woops",
                                          message: mess,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel,
                                          handler: nil))
            present(alert, animated: true)
        }
        
    }
    extension RegisterViewController: UITextFieldDelegate{
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            if textField == FirstnameField{
                LastnameField.becomeFirstResponder()
            }
            else if textField == LastnameField{
                emailField.becomeFirstResponder()
            }
            else if textField == emailField{
                passwordField.becomeFirstResponder()
            }
            else{
                registerBtnAction()
            }
            return true
        }
}


extension RegisterViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func presentPhotoActionSheet(){
        let actionSheet = UIAlertController(title: "Avatar",
                                            message: "How would you like to chosse your avatar",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        
        actionSheet.addAction(UIAlertAction(title: "Take Photo",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                self?.presentCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Chosse Photo",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                self?.presentPhotoLibrary()
        }))
        present(actionSheet, animated: true)
    }
    
    func presentCamera(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    func presentPhotoLibrary(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        imageView.image = img
        picker.dismiss(animated: true, completion: nil)
    }
}
