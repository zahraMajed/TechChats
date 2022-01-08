//
//  RecentChatsViewController.swift
//  TechChats
//
//  Created by administrator on 04/01/2022.
//

import UIKit

class RecentChatsViewController: UIViewController {
    
    
    @IBOutlet weak var searchTF: UISearchBar!
    @IBOutlet weak var recentChatsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //recentChatsTableView.dataSource = self
        //recentChatsTableView.delegate = self
    }

}
/*
extension RecentChatsViewController:UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
    
}
*/
