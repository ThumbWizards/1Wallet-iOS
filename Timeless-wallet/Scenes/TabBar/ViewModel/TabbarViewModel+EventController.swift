//
//  ChatChannelListVC+EventController.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 14/03/22.
//

import UIKit
import StreamChat

extension TabBarView.ViewModel: EventsControllerDelegate {
    func eventsController(_ controller: EventsController, didReceiveEvent event: Event) {
        switch event {
        case let event as MessageNewEvent:
            handleNewMessage(event: event)
        case let event as NotificationMessageNewEvent:
            handleNewMessage(event: event)
        default:
            break
        }
    }
}

extension TabBarView.ViewModel {
    private func handleNewMessage(event: MessageNewEvent) {
        guard TabBarView.ViewModel.shared.selectedTab != 2,
              !event.channel.isMuted,
              event.message.author.id != ChatClient.shared.currentUserId else {
            return
        }
        let title = "New message from \(event.message.author.name ?? "")"
        let message = event.message.text
        LocalNotificationHelper.requestNewMessageNotification(title, message: message)
    }

    private func handleNewMessage(event: NotificationMessageNewEvent) {
        guard TabBarView.ViewModel.shared.selectedTab != 2,
              !event.channel.isMuted,
              event.message.author.id != ChatClient.shared.currentUserId else {
            return
        }
        let title = "New message from \(event.message.author.name ?? "")"
        let message = event.message.text
        LocalNotificationHelper.requestNewMessageNotification(title, message: message)
    }
}
