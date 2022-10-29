//
//  LeaguePopupViewController.swift
//  Scoreo
//
//  Created by Remya on 10/29/22.
//

import UIKit

class LeaguePopupViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchbar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSettings()

        // Do any additional setup after loading the view.
    }
    
    func initialSettings(){
        tableView.register(UINib(nibName: "", bundle: nil), forCellReuseIdentifier: "cell")
    }
    

  

}
