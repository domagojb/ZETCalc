//
//  HistoryViewController.swift
//  ZETCalc
//
//  Created by Domagoj Boros on 13/06/2019.
//  Copyright © 2019 Domagoj Boros. All rights reserved.
//

import UIKit
import ZETCalc_Framework

class HistoryViewController: UITableViewController {

    private var history = RideManager.shared.loadRideHistory()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(didTapClose))
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReuseIdentifier", for: indexPath)

        let ride = history[indexPath.row]
        let level = ride.level
        
        cell.textLabel?.text = "\(level.price)kn \(level.time)min"
        
        let format = DateFormatter()
        format.dateFormat = "HH:mm dd-MM-yyyy"
        
        let mid = ride.date < Date() ? "ends" : "ended"
        cell.detailTextLabel?.text = "Ride \(mid) at " + format.string(from: ride.date)

        return cell
    }
    
    // MARK: - Actions
    
    @objc
    private func didTapClose() {
        self.dismiss(animated: true, completion: nil)
    }
}
