//
//  ViewController.swift
//  MusicPlayer
//
//  Created by Radovan Corovic on 5/18/18.
//  Copyright © 2018 Radovan Corovic. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableview: UITableView!
    let list = ["pop", "rock", "metal", "house", "narodna", "opera", "rege"]
    var recordsArray:[Int] = Array()
    var limit = 20
    let totalEntries = 100

    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableview.delegate = self
        tableview.dataSource = self
        tableview.tableFooterView = UIView(frame: .zero)
//        self.tableview.contentInset = UIEdgeInsets(top: 44,left: 0,bottom: 0,right: 0)
        
        
        var index = 0
        while index < limit {
            recordsArray.append(index)
            index = index + 1
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! GenreTableViewCell
        //        let cell1 = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        
//        cell.genreName.text = list[indexPath.row]
        cell.genreName.text = ("Row\(recordsArray[indexPath.row])")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == recordsArray.count - 1 {
            // checks if we are at last cell, load more content
            
            if recordsArray.count < totalEntries {
                // we need to bring more records as there are are some pending records available
                var index = recordsArray.count
                limit = index + 20
                while index < limit {
                    recordsArray.append(index)
                    index = index + 1
                }
                self.perform(#selector(loadTable), with: nil, afterDelay: 1.0)
            }
        }
    }
    
    @objc func loadTable() {
        self.tableview.reloadData()
    }
    
  
    


}

