//
//  NowTimerViewModifier.swift
//  Timeless-wallet
//
//  Created by Vo Trong Nghia on 29/11/2021.
//

import Foundation
import SwiftUI
import Combine

struct NowTimerViewModifier: ViewModifier {
    typealias TimerPublisher = Publishers.Autoconnect<Timer.TimerPublisher>
    var resolution: Double

    @State @SilentState private var currentlyConfiguredResolution: Double?
    @State @SilentState private var timer: TimerPublisher?
    @Binding private var now: Date

    init(resolution: Double, now: Binding<Date>) {
        _now = now
        self.resolution = resolution
    }

    func body(content: Content) -> some View {
        if timer == nil || currentlyConfiguredResolution != resolution {
            // TODO: Align with wall clock
            timer = Timer.publish(every: resolution, on: .main, in: .common).autoconnect()
            currentlyConfiguredResolution = resolution
        }

        return Group { content }
            // On appear required because of
            //    https://stackoverflow.com/questions/61190398/swiftui-viewmodifier-doesnt-listen-to-onreceive-events
            .onAppear()
            .onReceive(timer!) { _ in
                self.now = Date()
            }
    }
}

extension View {
    func nowTimer(resolution: Double, now: Binding<Date>) -> some View {
        return self.modifier(NowTimerViewModifier(resolution: resolution, now: now))
    }
}
