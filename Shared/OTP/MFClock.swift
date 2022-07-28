//
//  MFClock.swift
//  MultiFactor
//
//  Created by g.lofrumento on 28/07/22.
//

import Foundation

class MFClock: ObservableObject {
    static let shared = MFClock()

    private let period = 30.0
    private var timer: Timer!

    private(set) var state: State = .paused
    @Published var time: Date = Date()

    private init() {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        self.start()
//        }
    }

    func start() {
        if state == .paused {
            state = .working
            syncTimerToMinute()
        }
    }

    func stop() {
        if state == .working {
            state = .paused
            timer?.invalidate()
        }
    }

    private func update() {
        self.time = Date()
    }

    // Thanks: https://stackoverflow.com/a/45683502
    private func syncTimerToMinute() {
        update()

        let wait = period - (Date().timeIntervalSince1970).truncatingRemainder(dividingBy: period) + 0.5
        timer = Timer.scheduledTimer(withTimeInterval: wait, repeats: false) { [weak self] _ in
            self?.startTimer()
        }
    }

    private func startTimer() {
        update()

        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.update()
        }
    }

    enum State {
        case working
        case paused
    }
}
