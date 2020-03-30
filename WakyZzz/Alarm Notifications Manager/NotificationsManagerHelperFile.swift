//
//  NotificationsManagerHelperFile.swift
//  WakyZzz
//
//  Created by Am GHAZNAVI on 24/03/2020.
//  Copyright © 2020 Olga Volkova OC. All rights reserved.
//

import Foundation
import UserNotifications

struct NotificationData {
    let notificationId: String
    let categoryId: String
    let title: String
    let subtitle: String
    let body: String
    let soundType: SoundType
    let volume: Float
}

enum SoundType: String {
    case basic = "General.mp3"
    case evil = "Evil.mp3"
}

class Notification {
    
    //To differentiate notification(s)
    enum NotificationType {
        case notification(alarm: Alarm, weekDay: Int?)
        case snooze(count: Int)
        case deferMore
    }
    
   //To differentiate notification(s) action
    enum NotificationActionType: String {
        case snooze
        case secondSnooze
        case textFriend
        case textFamily
        case delete
        case deferMore
        case complete
    }
    
    public func notificationSound(type: SoundType, volume: Float) -> UNNotificationSound {
        return UNNotificationSound.criticalSoundNamed(UNNotificationSoundName(type.rawValue), withAudioVolume: volume)
    }
    
    public func notificationAction(types: [NotificationActionType]) -> [UNNotificationAction] {
        var array: [UNNotificationAction] = []
        types.forEach {
            array.append(createNotificationAction(of: $0))
        }
        return array
    }
    
    //To creates an action with title
    private func createNotificationAction(of type: NotificationActionType) -> UNNotificationAction {
        
        var title = ""
        var options: UNNotificationActionOptions = []

        switch type {
        case .snooze:
            title = "Snooze"
        case .secondSnooze:
            title = "Snooze"
        case .textFriend:
            title = "Text a friend"
        case .textFamily:
            title = "Text a family"
        case .delete:
            title = "Stop Alarm"
            options = .destructive
        case .deferMore:
            title = "I'll complete it later!"
        case .complete:
            title = "Yes, I've completed it!"
            options = .destructive
        }
        return UNNotificationAction(identifier: type.rawValue, title: title, options: options)
    }
}
