//
//  TodayViewController.swift
//  ZETCalc Widget
//
//  Created by Domagoj Boros on 12/04/2019.
//  Copyright © 2019 Domagoj Boros. All rights reserved.
//

import UIKit
import NotificationCenter
import ZETCalc_Framework

class TodayViewController: UIViewController, NCWidgetProviding {
        
    @IBOutlet weak var rideLevelOneControl: RideControl!
    @IBOutlet weak var rideLevelTwoControl: RideControl!
    @IBOutlet weak var rideLevelThreeControl: RideControl!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var rideLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshStateLabel()
        self.updateRideStatus(rideEndDate: RideManager.shared.ride)
        
        let fontSize: CGFloat = 17
        
        self.rideLevelOneControl.setup(price: RideManager.RideLevelOne.price, duration: RideManager.RideLevelOne.time, fontSize: fontSize)
        self.rideLevelTwoControl.setup(price: RideManager.RideLevelTwo.price, duration: RideManager.RideLevelTwo.time, fontSize: fontSize)
        self.rideLevelThreeControl.setup(price: RideManager.RideLevelThree.price, duration: RideManager.RideLevelThree.time, fontSize: fontSize)
        
        self.rideLevelOneControl.addTarget(self, action: #selector(didTapLevelOne(_:)), for: .touchUpInside)
        self.rideLevelTwoControl.addTarget(self, action: #selector(didTapLevelTwo(_:)), for: .touchUpInside)
        self.rideLevelThreeControl.addTarget(self, action: #selector(didTapLevelThree(_:)), for: .touchUpInside)
        
        RideManager.shared.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshStateLabel()
        self.updateRideStatus(rideEndDate: RideManager.shared.ride)
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        
        self.refreshStateLabel()
        self.updateRideStatus(rideEndDate: RideManager.shared.ride)
        
        completionHandler(NCUpdateResult.newData)
    }
    
    private func refreshStateLabel() {
        self.statusLabel.text = RideManager.shared.state.description + "kn";
    }
    
    private func updateRideStatus(rideEndDate: Date?) {
        if let date = rideEndDate {
            let format = DateFormatter()
            format.dateFormat = "HH:mm"
            self.rideLabel.text = "Ride ends at " + format.string(from: date)
        } else {
            self.rideLabel.text = "No rides in progress"
        }
    }
    
    private func playRideSound(success: Bool) {
        UINotificationFeedbackGenerator().notificationOccurred(success ? .success : .error)
    }
    
    @objc private func didTapLevelOne(_ sender: Any) {
        let result = RideManager.shared.applyRide(RideManager.RideLevelOne, notify: true)
        self.playRideSound(success: result)
    }
    
    @objc private func didTapLevelTwo(_ sender: Any) {
        let result = RideManager.shared.applyRide(RideManager.RideLevelTwo, notify: true)
        self.playRideSound(success: result)
    }
    
    @objc private func didTapLevelThree(_ sender: Any) {
        let result = RideManager.shared.applyRide(RideManager.RideLevelThree, notify: true)
        self.playRideSound(success: result)
    }
    
}

// MARK: - RideManagerDelegate

extension TodayViewController: RideManagerDelegate {
    
    func rideManager(_ manager: RideManager, didUpdateState state: Int) {
        self.refreshStateLabel()
    }
    
    func rideManager(_ manager: RideManager, rideInProgreess until: Date) {
        self.updateRideStatus(rideEndDate: until)
    }
}
