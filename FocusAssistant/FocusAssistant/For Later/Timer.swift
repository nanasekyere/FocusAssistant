//
//  Timer.swift
//  FocusAssistant
//
//  Created by Nana Sekyere on 28/05/2024.
//

import SwiftUI

struct TimerViewWithoutTimer: View {
    @State private var duration: Int
    @State private var timeStarted: Date
    @State private var timeLeft: Int = 0

    private let timerPublisher = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(duration: Int, timeStarted: Date) {
        self._duration = State(initialValue: duration)
        self._timeStarted = State(initialValue: timeStarted)
        self._timeLeft = State(initialValue: duration - Int(Date().timeIntervalSince(timeStarted)))
    }

    private func updateTimeLeft() {
        let elapsed = Int(Date().timeIntervalSince(timeStarted))
        self.timeLeft = max(duration - elapsed, 0)
    }

    private func formatTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, remainingSeconds)
    }

    var body: some View {
        Text("Time left: \(formatTime(timeLeft))")
            .onReceive(timerPublisher) { _ in
                self.updateTimeLeft()
            }
    }
}

struct TimerViewWithoutTimer_Previews: PreviewProvider {
    static var previews: some View {
        TimerViewWithoutTimer(duration: 3661, timeStarted: Date())
    }
}
