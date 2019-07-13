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
import ZETCalc_Framework

class ViewController: UIViewController {
    
    private let PersistanceRemindersKey = "PersistanceRemindersKey"
    
    @IBOutlet weak var statusField: UITextField!
    @IBOutlet weak var notificationsWarningLabel: UILabel!
    @IBOutlet weak var rideStatusLabel: UILabel!
    @IBOutlet weak var cancelReminderButton: UIButton!
    @IBOutlet weak var remindersSwitch: UISwitch!
    @IBOutlet weak var rideLevelOneControl: RideControl!
    @IBOutlet weak var rideLevelTwoControl: RideControl!
    @IBOutlet weak var rideLevelThreeControl: RideControl!
    
    private var remindersEnabled: Bool {
        get {
            return !UserDefaults.standard.bool(forKey: PersistanceRemindersKey)
        }
        
        set {
            UserDefaults.standard.set(!newValue, forKey: PersistanceRemindersKey)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        RideManager.shared.delegate = self
        
        self.refreshStateLabel()
        self.updateRideStatus(with: RideManager.shared.ride)
        
        self.remindersSwitch.isOn = self.remindersEnabled
        self.updateNotificationsWarning()
        
        let fontSize: CGFloat = 27
        
        self.rideLevelOneControl.setup(price: RideManager.RideLevelOne.price, duration: RideManager.RideLevelOne.time, fontSize: fontSize)
        self.rideLevelTwoControl.setup(price: RideManager.RideLevelTwo.price, duration: RideManager.RideLevelTwo.time, fontSize: fontSize)
        self.rideLevelThreeControl.setup(price: RideManager.RideLevelThree.price, duration: RideManager.RideLevelThree.time, fontSize: fontSize)
        
        self.rideLevelOneControl.addTarget(self, action: #selector(didTapLevelOne(_:)), for: .touchUpInside)
        self.rideLevelTwoControl.addTarget(self, action: #selector(didTapLevelTwo(_:)), for: .touchUpInside)
        self.rideLevelThreeControl.addTarget(self, action: #selector(didTapLevelThree(_:)), for: .touchUpInside)
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(didTapBackground(_:)))
        recognizer.delegate = self
        self.view.addGestureRecognizer(recognizer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name:UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
    private func refreshStateLabel() {
        self.statusField.text = RideManager.shared.state.description;
    }
    
    private func playRideSound(success: Bool) {
        //        AudioServicesPlaySystemSound(1016);
        UINotificationFeedbackGenerator().notificationOccurred(success ? .success : .error)
    }
    
    private func updateRideStatus(with ride: Ride?) {
        if let ride = ride {
            let format = DateFormatter()
            format.dateFormat = "HH:mm"
            self.rideStatusLabel.text = "\(ride.level.price)kn ride ends at " + format.string(from: ride.date)
        } else {
            self.rideStatusLabel.text = "No rides in progress"
        }
    }
    
    private func updateNotificationsWarning() {
        
        if !self.remindersEnabled {
            self.notificationsWarningLabel.isHidden = true
            return
        }
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            DispatchQueue.main.async {
                self.notificationsWarningLabel.isHidden = granted
            }
        }
    }
    
    @objc private func appWillEnterForeground() {
        self.refreshStateLabel()
        self.updateRideStatus(with: RideManager.shared.ride)
        self.updateNotificationsWarning()
    }
}

// MARK: - Actions

extension ViewController {
    
    @IBAction func didTapTopUp(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Top Up", message: "Enter how much to top up", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "100 kn"
            textField.keyboardType = .numberPad
        }
        
        alertController.addAction(UIAlertAction(title: "Top Up", style: .default, handler: { (action) in
            if let toppedUp = alertController.textFields?.first!.text {
                RideManager.shared.topUp(for: UInt(toppedUp)!)
                self.refreshStateLabel()
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func didTapBackground(_ sender: Any) {
        self.statusField.resignFirstResponder()
    }
    
    @objc private func didTapLevelOne(_ sender: Any) {
        let result = RideManager.shared.applyRide(RideManager.RideLevelOne, notify: self.remindersEnabled)
        self.playRideSound(success: result)
    }
    
    @objc private func didTapLevelTwo(_ sender: Any) {
        let result = RideManager.shared.applyRide(RideManager.RideLevelTwo, notify: self.remindersEnabled)
        self.playRideSound(success: result)
    }
    
    @objc private func didTapLevelThree(_ sender: Any) {
        let result = RideManager.shared.applyRide(RideManager.RideLevelThree, notify: self.remindersEnabled)
        self.playRideSound(success: result)
    }
    
    @IBAction func didUpdateRemindersSwitch(_ sender: UISwitch) {
        self.remindersEnabled = sender.isOn
        self.updateNotificationsWarning()
    }
    
    @IBAction func didTapCancelReminder(_ sender: Any) {
        RideManager.shared.cancelNotifications()
    }
    
    @IBAction func didTapHistoryButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "HistoryViewController")
        self.present(UINavigationController(rootViewController: controller), animated: true, completion: nil)
    }
}

// MARK: - UIGestureRecognizerDelegate

extension ViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == gestureRecognizer.view
    }
}

// MARK: - RideManagerDelegate

extension ViewController: RideManagerDelegate {
    
    func rideManager(_ manager: RideManager, didUpdateState state: Int) {
        self.refreshStateLabel()
    }
    
    func rideManager(_ manager: RideManager, rideInProgreess ride: Ride) {
        self.updateRideStatus(with: ride)
    }
}

