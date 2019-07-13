//
//  RideManager.swift
//  ZETCalc Framework
//
//  Created by Domagoj Boros on 12/04/2019.
//  Copyright © 2019 Domagoj Boros. All rights reserved.
//

import Foundation
import UserNotifications

public protocol RideManagerDelegate: AnyObject {
    func rideManager(_ manager: RideManager, didUpdateState state: Int)
    func rideManager(_ manager: RideManager, rideInProgreess until: Date)
}

public class RideManager {
    
    private let storage: UserDefaults! = UserDefaults(suiteName: "group.data.com.domagoj.personal.MojZET")
    
    private let StatePersistanceKey = "StatePersistanceKey"
    private let RidePersistanceKey = "RidePersistanceKey"
    
    public static let shared = RideManager()
    
    public weak var delegate: RideManagerDelegate?
    
    public struct RideLevel {
        public private(set) var price: UInt
        public private(set) var time: UInt // minutes
    }
    
    public static let RideLevelOne = RideLevel(price: 4, time: 30)
    public static let RideLevelTwo = RideLevel(price: 7, time: 60)
    public static let RideLevelThree = RideLevel(price: 10, time: 90)
    
    public var state: UInt {
        get { return UInt(storage.integer(forKey: StatePersistanceKey)) }
        set {
            storage.set(newValue, forKey: StatePersistanceKey)
            self.delegate?.rideManager(self, didUpdateState: Int(newValue))
        }
    }
    
    public private(set) var ride: Date? {
        
        get {
            if let date = storage.object(forKey: RidePersistanceKey) as? Date {
                
                if date < Date() {
                    return nil
                }
                
                return date
                
            } else {
                return nil
            }
        }
        
        set {
            storage.set(newValue, forKey: RidePersistanceKey)
            self.delegate?.rideManager(self, rideInProgreess: newValue!)
        }
    }
    
    public func topUp(for value: UInt) {
        self.state = self.state + UInt(value)
    }

    public func applyRide(_ level: RideLevel, notify: Bool) -> Bool {
        
        let state = self.state
        
        guard state >= level.price else {
            return false
        }
        
        self.state = state - level.price
        
        self.ride = Date(timeIntervalSinceNow: Double(level.time * 60))
        
        if notify {
            self.scheduleRideEndNotifications(in: level.time)
        }
        
        return true
    }
    
    public func cancelNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

// MARK: -
// MARK: Private

private extension RideManager {
    
    func scheduleRideEndNotifications(in time: UInt) {
        self.scheduleNotification(title: "Your ride expires soon", body: "Your ride expires in 5 miuntes", in: TimeInterval((time - 5) * 60))
        self.scheduleNotification(title: "Ride ended!", body: "Your ride has expired. Check in again.", in: TimeInterval(time * 60))
    }
    
    func scheduleNotification(title: String, body: String, in time: TimeInterval) {
        
        let content = UNMutableNotificationContent()
        
        content.title = title
        content.body = body
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: time, repeats: false)
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if error != nil {
                // Handle any errors.
            }
        }
    }
}
