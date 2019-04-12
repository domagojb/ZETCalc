//
//  ViewController.swift
//  ZETCalc
//
//  Created by Domagoj Boros on 10/04/2019.
//  Copyright © 2019 Domagoj Boros. All rights reserved.
//

import UIKit
import UserNotifications
import AudioToolbox

class ViewController: UIViewController {
    
    private struct RideLevel {
        var price: UInt
        var time: UInt // minutes
    }
    
    private var state: Int {
        get {
            return UserDefaults.standard.integer(forKey: StatePersistanceKey)
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: StatePersistanceKey)
        }
    }

    private let RideLevelOne = RideLevel(price: 4, time: 30)
    private let RideLevelTwo = RideLevel(price: 7, time: 60)
    private let RideLevelThree = RideLevel(price: 10, time: 90)
    
    private let StatePersistanceKey = "StatePersistanceKey"
    
    @IBOutlet weak var statusField: UITextField!
    @IBOutlet weak var notificationsWarningLabel: UILabel!
    @IBOutlet weak var rideStatusLabel: UILabel!
    @IBOutlet weak var cancelReminderButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshStateLabel()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.notificationsWarningLabel.isHidden = true
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            DispatchQueue.main.async {
                self.notificationsWarningLabel.isHidden = granted
            }
        }
    }
    
    private func applyRideLevel(_ level: RideLevel) {
        self.state = self.state - Int(level.price)
        self.refreshStateLabel()
    }
    
    private func refreshStateLabel() {
        self.statusField.text = String(format: "%@", self.state.description);
    }
    
    @IBAction func didTapTopUp(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Top Up", message: "Enter how much to top up", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "100 kn"
            textField.keyboardType = .numberPad
        }
        
        alertController.addAction(UIAlertAction(title: "Top Up", style: .default, handler: { (action) in
            if let toppedUp = alertController.textFields?.first!.text {
                self.state = self.state + Int(toppedUp)!
                self.refreshStateLabel()
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func scheduleRideEndNotification(in time: UInt) {
         // 5 minutes before it expires
        self.scheduleNotification(title: "Your ride expires soon", body: "Your ride expires in 5 miuntes", in: TimeInterval((time - 5) * 60))
        self.scheduleNotification(title: "Ride ended!", body: "Your ride has expired. Check in again.", in: TimeInterval(time * 60))
    }
    
    private func scheduleNotification(title: String, body: String, in time: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: time, repeats: false)
        
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { (error) in
            if error != nil {
                // Handle any errors.
            }
        }
    }
    
    private func playRideSound() {
//        AudioServicesPlaySystemSound(1016);
    }
    
    private func updateRideStatusLabelEnding(in time: UInt) {
        let rideEndDate = Date(timeIntervalSinceNow: Double(time * 60))
        let format = DateFormatter()
        format.dateFormat = "HH:mm"
        print(format.string(from: rideEndDate))
        self.rideStatusLabel.text = "Ride ends at " + format.string(from: rideEndDate)
    }
    
    @IBAction func didTapBackground(_ sender: Any) {
        self.statusField.resignFirstResponder()
    }
    
    @IBAction func didTap30Reminder(_ sender: Any) {
        self.playRideSound()
        self.applyRideLevel(RideLevelOne)
        self.updateRideStatusLabelEnding(in: RideLevelOne.time)
        self.scheduleRideEndNotification(in: RideLevelOne.time)
    }
    
    @IBAction func didTap60Reminder(_ sender: Any) {
        self.playRideSound()
        self.applyRideLevel(RideLevelTwo)
        self.updateRideStatusLabelEnding(in: RideLevelTwo.time)
        self.scheduleRideEndNotification(in: RideLevelTwo.time)
    }
    
    @IBAction func didTap90Reminder(_ sender: Any) {
        self.playRideSound()
        self.applyRideLevel(RideLevelThree)
        self.updateRideStatusLabelEnding(in: RideLevelThree.time)
        self.scheduleRideEndNotification(in: RideLevelThree.time)
    }
    
    @IBAction func didTap30(_ sender: Any) {
        self.playRideSound()
        self.applyRideLevel(RideLevelOne)
        self.updateRideStatusLabelEnding(in: RideLevelOne.time)
    }
    
    @IBAction func didTap60(_ sender: Any) {
        self.playRideSound()
        self.applyRideLevel(RideLevelTwo)
        self.updateRideStatusLabelEnding(in: RideLevelTwo.time)
    }
    
    @IBAction func didTap90(_ sender: Any) {
        self.playRideSound()
        self.applyRideLevel(RideLevelThree)
        self.updateRideStatusLabelEnding(in: RideLevelThree.time)
    }
}

