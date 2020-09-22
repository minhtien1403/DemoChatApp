//
//  ProfileViewController.swift
//  T-Messenger
//
//  Created by Tiến on 6/13/20.
//  Copyright © 2020 Tiến. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn

class ProfileViewController: UIViewController {

    @IBOutlet var tableview: UITableView!
    let data = ["Log out"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableview.delegate = self
        tableview.dataSource = self
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .red
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let token = AccessToken.current, !token.isExpired{
            FBLogOut()
        }
        else{
            defaultLogOut()
        }
        
    }
    
    func defaultLogOut(){
        do {
            try FirebaseAuth.Auth.auth().signOut()
            //if log out success
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
        } catch  {
            print("Failed to Log out")
        }
        
    }
    
    func FBLogOut(){
        let loginmanager = LoginManager()
        loginmanager.logOut()
        let vc = LoginViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    func GgLogOut(){
        GIDSignIn.sharedInstance()?.signOut()
    }
}
