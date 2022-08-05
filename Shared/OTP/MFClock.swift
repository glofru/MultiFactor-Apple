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

    private let loadedIncrement: Double
    @Published var time = Date()
    @Published var loaded = 1.0

    private init() {
        self.loadedIncrement = 1/self.period
        self.start()
    }

    func start() {
        if state == .paused {
            let delta = period - (Date().timeIntervalSince1970).truncatingRemainder(dividingBy: period)
            loaded = delta / period

            state = .working
            startTimer()
        }
    }

    func stop() {
        if state == .working {
            state = .paused
            timer.invalidate()
        }
    }

    private func increment() {
        if self.loaded < self.loadedIncrement {
            loaded = 1
            time = Date()
        }
        self.loaded -= self.loadedIncrement
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.increment()
        }
        RunLoop.main.add(timer, forMode: .common)
    }

    enum State {
        case working
        case paused
    }
}
