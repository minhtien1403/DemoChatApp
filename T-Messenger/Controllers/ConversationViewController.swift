//
//  ViewController.swift
//  T-Messenger
//
//  Created by Tiến on 6/13/20.
//  Copyright © 2020 Tiến. All rights reserved.
//

import UIKit
import FirebaseAuth
import JGProgressHUD



class ConversationViewController: UIViewController {
    
    private var conversations = [Conversations]()

    private let tableview: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(ConversationTableViewCell.self, forCellReuseIdentifier: ConversationTableViewCell.identifier)
        return table
    }()
    
    private let noConversationLabel: UILabel = {
        let label = UILabel()
        label.text = "No Conversation yet"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search,
                                                            target: self,
                                                            action: #selector(didTapComposeBtn))
        tableview.delegate = self
        tableview.dataSource = self
        
        view.addSubview(tableview)
        
        
        fetchConversation()
    }
    
    private func startListeningForConversations(){
        guard let email = UserDefaults.standard.value(forKey: "user_email") as? String else{
            return
        }
        print("starting fetch conversations...")
        let safeEmail = DatabaseManager.safemail(email: email)
        DatabaseManager.shared.getAllConversation(for: safeEmail, completion: { [weak self] Result in
            switch(Result){
            case.success(let conversations):
               
                guard !conversations.isEmpty else {
                    print("conversations is empty")
                    return
                }
                print("successfully get conversations")
                self?.conversations = conversations
                DispatchQueue.main.async {
                    self?.tableview.reloadData()
                }
            case.failure(let error):
                print("failed to get converstions because: \(error.localizedDescription)")
            }
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableview.frame = view.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
        startListeningForConversations()
    }
    
    private func validateAuth(){
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
        }
    }
    
    private func fetchConversation(){
        tableview.isHidden = false
    }
    
    @objc private func didTapComposeBtn(){
        let vc = NewConverstionViewController()
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
        vc.completion = { [weak self] result in
            self?.createNewConversation(result: result)
        }
    }
    
    private func createNewConversation(result: [String:String]){
        guard let name = result["name"], let receiverEmail = result["email"] else {
            print("Cant create new conversation")
            return
        }
        // new conversation doesn't have id yet, we will create it later when first message sended
        let vc = ChatViewController(with: receiverEmail, id: nil)
        vc.isNewConversation = true
        vc.title = name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension ConversationViewController: UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = conversations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier, for: indexPath) as! ConversationTableViewCell
        cell.configure(with: model)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = conversations[indexPath.row]

        
        let vc = ChatViewController(with: model.receiverEmail, id: model.id)
        vc.title = model.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
        
}

struct Conversations {
    let id: String
    let name: String
    let receiverEmail: String
    let latestMessage: LatestMessage
}

struct LatestMessage {
    let date: String
    let message: String
    let isRead: Bool
}
