//
//  ContentView.swift
//  MojZET2
//
//  Created by Domagoj Boroš on 14.05.2022..
//  Copyright © 2022 Domagoj Boros. All rights reserved.
//

import SwiftUI

struct MainView: View {

    @StateObject
    var viewModel = MainViewModel()

    var body: some View {

        ZStack {

            VStack(alignment: .leading, spacing: 20) {

                HeaderView(title: "Prepaid status")

                prepaidStateSection

                HeaderView(title: "Ride information")
                    .padding(.top)

                Text(viewModel.rideStatus)
                    .foregroundColor(.white)

                HeaderView(title: "Options")
                    .padding(.top)

                Toggle("Reminders", isOn: $viewModel.isRemindersOn)
                        .foregroundColor(.white)

                HStack {
                    Text("Cancel current ride reminder")
                        .foregroundColor(.white)

                    Spacer()
                    Button("Cancel") {
                        viewModel.cancelReminders()
                    }
                    .foregroundColor(.white)
                }

                Spacer()

                HeaderView(title: "Rides")

                ridesSections
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.horizontal)
        .background(Color.black)
    }

    @State
    var topupAlertPresented = false

    @State
    var text: String = "100"

    var prepaidStateSection: some View {

        HStack {

            PrepaidStateView(state: viewModel.prepaidState)

            Spacer()

            Button("Top up"){
                topupAlertPresented.toggle()
            }
            .foregroundColor(.black)
            .padding(.horizontal, 24)
            .padding(.vertical, 10)
            .background(.white)
            .clipShape(Capsule())
            .alert("Top Up", isPresented: $topupAlertPresented, actions: {

                TextField("Amount", text: $text)
                .keyboardType(.numberPad)

                Button("Done") {
                    viewModel.topUp(for: UInt(text)!)
                }
                
                Button("Cancel", role: .cancel) {}

            }, message: {
                
                Text("Please enter the amount to top up.")
            })
        }
    }

    var ridesSections: some View {

        VStack(spacing: 12) {

            ForEach(viewModel.rideLevels, id: \.level.time) { ride in
                Button(ride.displayableText) {
                    viewModel.applyRide(ride.level)
                }.buttonStyle(CapsuleButtonStyle(color: ride.colour))
            }
        }
    }
}

struct CapsuleButtonStyle: ButtonStyle {

    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .font(.title3)
            .foregroundColor(.white)
            .padding(.vertical)
            .frame(maxWidth: .infinity)
            .background(color)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

struct HeaderView: View {

    let title: String

    var body: some View {

        VStack(alignment: .leading, spacing: 4) {

            Text(title)
                .font(.subheadline)
                .fontWeight(.regular)

            Rectangle()
                .frame(height: 1)

        }
        .foregroundColor(Color.gray)
    }
}

struct PrepaidStateView: View {

    let state: UInt

    var body: some View {

        HStack(spacing: 2) {

            Text("\(state)")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("kn")
                .font(.largeTitle)
                .fontWeight(.ultraLight)
                .foregroundColor(.white)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MainView()
        }
    }
}
