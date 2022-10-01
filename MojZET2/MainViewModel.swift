//
//  MainViewModel.swift
//  MojZET2
//
//  Created by Domagoj Boroš on 01.10.2022..
//  Copyright © 2022 Domagoj Boros. All rights reserved.
//

import SwiftUI
import Combine
import ZETCalc_Framework

struct DisplayableRideLevel {

    let colour: Color
    let displayableText: String
    let level: RideLevel

    init(_ level: RideLevel, colour: Color) {
        self.colour = colour
        self.displayableText = "\(level.price)kn \(level.time)min"
        self.level = level
    }
}

extension Ride? {

    fileprivate var localizedStatus: String {

        guard let self else {
            return "No rides in progress"
        }

        let format = DateFormatter()
        format.dateFormat = "HH:mm"
        return "\(self.level.price)kn ride ends at " + format.string(from: self.date)
    }
}

final class MainViewModel: ObservableObject {

    private var cancellables: [AnyCancellable] = []

    let rideLevels: [DisplayableRideLevel] = [
        .init(RideManager.RideLevelOne, colour: .blue),
        .init(RideManager.RideLevelTwo, colour: .green),
        .init(RideManager.RideLevelThree, colour: .yellow),
    ]

    @Published
    private(set) var prepaidState: UInt = RideManager.shared.state

    @Published
    var isRemindersOn = true

    @Published
    private(set) var rideStatus = RideManager.shared.ride.localizedStatus

    init() {
        RideManager.shared.statePublisher.assign(to: &$prepaidState)
        RideManager.shared.ridePublisher.map(\.localizedStatus).assign(to: &$rideStatus)
    }

    func applyRide(_ level: RideLevel) {
        let success = RideManager.shared.applyRide(level, notify: isRemindersOn)
        playRideSound(success: success)
    }

    func topUp(for amount: UInt) {
        RideManager.shared.topUp(for: amount)
    }

    func cancelReminders() {
        RideManager.shared.cancelNotifications()
    }

    private func playRideSound(success: Bool) {
        UINotificationFeedbackGenerator().notificationOccurred(success ? .success : .error)
    }
}
