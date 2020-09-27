//
//  NewConverstionViewController.swift
//  T-Messenger
//
//  Created by Tiến on 6/13/20.
//  Copyright © 2020 Tiến. All rights reserved.
//

import UIKit
import JGProgressHUD

class NewConverstionViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private var users = [[String:String]]()
    
    private var searchResult = [[String:String]]()
    
    private var hasFetch = false

    private let searchBar: UISearchBar = {
        let searchbar = UISearchBar()
        searchbar.placeholder = "Search for user ..."
        return searchbar
    }()
    
    private let tableview: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.isHidden = true
        return table
    }()
    
    private let noResultLable: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "No user founded"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        searchBar.delegate = self
        view.backgroundColor = .white
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(dissmissSelf))
        view.addSubview(tableview)
        view.addSubview(noResultLable)
        
        tableview.dataSource = self
        tableview.delegate = self
    }
    override func viewDidAppear(_ animated: Bool) {
        searchBar.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableview.frame = view.bounds
        noResultLable.frame = CGRect(x: 0, y: 0, width: view.width/2, height: 20)
    }
    
    @objc private func dissmissSelf(){
        dismiss(animated: true, completion: nil)
    }

}

extension NewConverstionViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        guard  let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
//            return
//        }
//        searchBar.resignFirstResponder()
//
//        searchResult.removeAll()
//        spinner.show(in: view)
//        self.searchUser(query: text)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text!.isEmpty{
            tableview.reloadData()
        }
        else{
            let text = searchBar.text
            searchBar.resignFirstResponder()
            searchResult.removeAll()
            spinner.show(in: view)
            self.searchUser(query: text!)
        }
        searchBar.becomeFirstResponder()
    }
    
    func searchUser(query:String){
        if hasFetch{
            self.filterUser(with: query)
        }
        else{
            //let fetch then filtering
            DatabaseManager.shared.getAllUser(completion: { [weak self] result in
                switch result {
                case .success(let userCollection):
                    print("Fetch User data success")
                    self?.hasFetch = true
                    self?.users = userCollection
                    self?.filterUser(with: query)
                    break
                case .failure(let error):
                    print("Failed to fetch users list because: \(error.localizedDescription)")
                    break
                }
            })
        }
    }
    
    func filterUser(with query:String){
        guard hasFetch else {
            return
        }
        spinner.dismiss()
        //update UI : Show search result
        let result : [[String:String]] = self.users.filter({
            guard let name = $0["name"]?.lowercased() else{
                return false
            }
            
            return name.contains(query.lowercased())
        })
        self.searchResult = result
        print(searchResult.count)
        updateUI()
    }
    
    func updateUI(){
        if searchResult.isEmpty{
            noResultLable.isHidden = false
            tableview.isHidden = true
        }
        else{
            noResultLable.isHidden = true
            tableview.isHidden = false
            tableview.reloadData()
        }
    }
}

extension NewConverstionViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = searchResult[indexPath.row]["name"]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //start conversation
    }
}
