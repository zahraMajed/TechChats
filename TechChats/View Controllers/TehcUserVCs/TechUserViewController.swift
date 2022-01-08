//
//  TechUserViewController.swift
//  TechChats
//
//  Created by administrator on 04/01/2022.
//

import UIKit

class TechUserViewController: UIViewController {

    @IBOutlet weak var searchTF: UISearchBar!
    @IBOutlet weak var freindsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //freindsTableView.delegate = self
        //freindsTableView.dataSource = self
    
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
