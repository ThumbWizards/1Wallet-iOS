//
//  HapticsGenerator.swift
//  Timeless-iOS
//
// Created by Brian Sipple on 5/29/20.
// Copyright © 2020 Timeless. All rights reserved.
//


import SwiftUI
import Combine
import CoreHaptics


final class HapticsGenerator {
    private var subscriptions = Set<AnyCancellable>()
    private let hapticEngine: CHHapticEngine?
    private var needsToRestart = false

    // MARK: - shared
    static let shared = HapticsGenerator()

    // MARK: - Init
    public init(
        supportsAudio: Bool = false
    ) {
        hapticEngine = try? CHHapticEngine()
        hapticEngine?.resetHandler = resetHandler
        hapticEngine?.stoppedHandler = restartHandler
        hapticEngine?.playsHapticsOnly = !supportsAudio

        try? start()
    }
}


// MARK: - Lifecycle Methods
extension HapticsGenerator {

    /// Stops the internal CHHapticEngine.
    ///
    /// Call this when the app enters the background.
    public func stop(completionHandler: CHHapticEngine.CompletionHandler? = nil) {
        hapticEngine?.stop(completionHandler: completionHandler)
    }


    /// Starts the internal CHHapticEngine.
    ///
    /// Call this when the app enters the foreground.
    public func start() throws {
        try hapticEngine?.start()
        needsToRestart = false
    }
}


// MARK: - Player Methods
extension HapticsGenerator {

    public func playTransientEvent(
        withIntensity intensity: Float = 1.0,
        sharpness: Float = 0.75
    ) throws {
        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
            ],
            relativeTime: 0
        )

        let pattern = try CHHapticPattern(events: [event], parameters: [])
        let player = try hapticEngine?.makePlayer(with: pattern)

        if needsToRestart {
            try? start()
        }

        try player?.start(atTime: CHHapticTimeImmediate)
    }
}



// MARK: - Private Helpers
private extension HapticsGenerator {

    /// Attempts to restart the engine.
    ///
    /// This will be called asynchronously if the Core Haptics engine has to reset
    /// itself after a server failure.
    ///
    ///  The system preserves `CHHapticPattern` objects and `CHHapticEngine`
    ///  properties across restarts.
    private func resetHandler() {
        do {
            try start()
        } catch {
            needsToRestart = true
        }
    }


    /// Attempts to restart the engine.
    ///
    /// This will be called asynchronously if the Core Haptics engine
    /// stops due to external causes such as  audio session interruption,
    /// application suspension, or system error.
    ///
    ///  The system preserves `CHHapticPattern` objects and `CHHapticEngine`
    ///  properties across restarts.
    private func restartHandler(_ reasonForStopping: CHHapticEngine.StoppedReason? = nil) {
        resetHandler()
    }
}
