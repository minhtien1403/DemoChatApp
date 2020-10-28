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
    
    override func viewDidAppear(_ animated: Bool) {
         tableview.tableHeaderView = createTableHeader()
    }
    
    func createTableHeader() -> UIView? {
        guard let email = UserDefaults.standard.value(forKey: "user_email") as? String else {
            return nil
        }
        let safeEmail = DatabaseManager.safemail(email: email)
        print(safeEmail)
        let path = "images/"+safeEmail+"_avatar_picture.png"
        
        let headerView = UIView(frame: CGRect(x: 0,
                                              y: 0,
                                              width: self.view.width,
                                              height: 300))
        headerView.backgroundColor = .white
        let imageview = UIImageView(frame: CGRect(x: (headerView.width-150)/2,
                                                  y: (headerView.height-150)/2,
                                                  width: 150, height: 150))
        imageview.contentMode = .scaleAspectFill
        imageview.layer.borderWidth = 1
        imageview.layer.borderColor = UIColor.black.cgColor
        imageview.layer.cornerRadius = imageview.width/2
        imageview.layer.masksToBounds = true
        imageview.image = UIImage(systemName: "person.circle")
        imageview.tintColor = .gray
        
        
        StorageManager.shared.getDownloadUrl(for: path, completion: { [weak self] Result in
            switch Result{
            case .success(let url):
                self?.downloadAndSetAvatar(imageview: imageview, url: url)
                break
            case .failure(let error):
                print("failed to get download url because: \(error.localizedDescription)")
            }
        })
        headerView.addSubview(imageview)
        return headerView
    }
    
    func downloadAndSetAvatar(imageview: UIImageView, url: URL){
        DispatchQueue.main.async {
            let data = try? Data(contentsOf: url)
            if let imgData = data {
                imageview.image = UIImage(data: imgData)
            }
        }
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
