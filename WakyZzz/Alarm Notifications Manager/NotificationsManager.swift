//
//  NotificationsManager.swift
//  WakyZzz
//
//  Created by Am GHAZNAVI on 24/03/2020.
//  Copyright © 2020 Olga Volkova OC. All rights reserved.
//

import Foundation
import NotificationCenter

protocol NotificationsManagerDelegate {
    func reload()
}

class NotificationsManager : NSObject {
    
    static let shared = NotificationsManager()
    
    var userNotificationCenter = UNUserNotificationCenter.current()
    private let creatorNotification : Notification = Notification()
    private var isEnabled: Bool = false
    
    var delegate: NotificationsManagerDelegate?
    
    override init() {
        super.init()
        userNotificationCenter.delegate = self
        removeMissedNotification()
    }
    
    //Notification permission
    public func requestAuthorization() {
        userNotificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if (granted) {
                print ("We'll be able to set Hot Reminders!")
            }
            else {
                print ("Notifications denied - to enable notifications go the settings")
            }
        }
    }
    
    func updateNotification(alarm: Alarm) {
        removePendingNotification(id: alarm.id) {
            if alarm.isEnabled {
                self.addNotification(alarm)
            }
        }
    }
    
    func removeNotification(id: String) {
        removePendingNotification(id: id) { }
    }
    
    func addNotification(_ alarm: Alarm) {
        var weekDay = 0
        if alarm.repeating == "One time alarm" {
            scheduleNotification(type: .notification(alarm: alarm, weekDay: nil))
        } else {
            for weekDayBool in alarm.repeatDays {
                if weekDayBool {
                    scheduleNotification(type: .notification(alarm: alarm, weekDay: nil))
                }
                weekDay += 1
            }
        }
    }
    
    private func removePendingNotification(id: String, completion: @escaping () -> Void) {
        userNotificationCenter.getPendingNotificationRequests { requests in
            let array = requests.filter { $0.identifier.contains(id) }
            array.forEach {
                self.userNotificationCenter.removePendingNotificationRequests(withIdentifiers: [$0.identifier])
                self.userNotificationCenter.removeDeliveredNotifications(withIdentifiers: [$0.identifier])
            }
            completion()
        }
    }
    
    public func disableOneTimeAlarm(id: String) {
        let context = AppDelegate.context
        if let alarm = DataManager.shared.getAlarmWith(id: id, in: context) {
            //If true not one time alarm
            if !alarm.alarms().repeatDays.contains(true) {
                alarm.isEnabled = false
                try! context.save()
            }
        }
    }
    
    private func removeMissedNotification() {
        //Notification that user did not respond to
        userNotificationCenter.getDeliveredNotifications { notifications in
            DispatchQueue.main.async {
                notifications.forEach {
                    self.disableOneTimeAlarm(id: $0.request.identifier)
                }
            }
        }
    }
    
    //Notification(s) based on type
     private func scheduleNotification(type: Notification.NotificationType, categoryIdentifier: String? = nil, contentIdentifier: String? = nil) {
         switch type {
             
         case .notification(alarm: let alarm, weekDay: let weekDay):
             
             let data = NotificationData(
                 notificationId: "\(alarm.id)\(weekDay ?? 0)",
                 categoryId: alarm.caption,
                 title: "\(Constants.notificationManager.wakyZzzAlarm)",
                 subtitle: "WAKE UP! TIME TO ACT",
                 body: alarm.caption,
                 soundType: .basic,
                 volume: 0.5)
             
             guard let date = alarm.alarmDate else { return }
             var dateComponents = DateComponents()
             dateComponents.calendar = Calendar.current
             dateComponents.weekday = weekDay ?? Calendar.current.component(.weekday, from: Date())
             dateComponents.hour = dateComponents.calendar?.component(.hour, from: date)
             dateComponents.minute = dateComponents.calendar?.component(.minute, from: date)
             
             //Repeat trigger
             let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: weekDay != nil)
             
             createNotification(data: data, trigger: trigger, actions: [.snooze, .textFriend, .textFamily, .delete])
             
         case .snooze(count: let count):
             let data = NotificationData(
                 notificationId: contentIdentifier ?? "",
                 categoryId: categoryIdentifier ?? "",
                 title: "\(Constants.notificationManager.appName)",
                subtitle: count == 1 ? "\(Constants.notificationManager.firstSnooze)" : "\(Constants.notificationManager.secondSnooze)",
                 body: count == 1 ? "Alarm set for " + (categoryIdentifier ?? "") : "COMPLETE TODAY'S ACT OF KINDNESS",
                 soundType: count == 1 ? .basic : .evil,
                 volume: count == 1 ? 0.75 : 1)
             
             //Time trigger
             let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
             
             createNotification(data: data, trigger: trigger, actions: count == 1 ? [.secondSnooze, .textFriend, .textFamily, .delete] : [.textFriend, .textFamily, .deferMore])
             
         case .deferMore:
             
             let data = NotificationData(
                 notificationId: contentIdentifier ?? "",
                 categoryId: categoryIdentifier ?? "",
                 title: "\(Constants.notificationManager.appName)",
                 subtitle: "Today's Task",
                 body: "YOU HAVE TO COMPLETE TODAY'S ACT OF KINDNESS",
                 soundType: .evil,
                 volume: 1)
             
             //Time trigger
             let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
             
             createNotification(data: data, trigger: trigger, actions: [.textFriend, .textFamily, .deferMore, .complete])
         }
     }
    
    //Create adjustable notification(s)
    private func createNotification(data: NotificationData, trigger: UNNotificationTrigger, actions: [Notification.NotificationActionType]) {
        
        let content = UNMutableNotificationContent()
        content.title = data.title
        content.subtitle = data.subtitle
        content.body = data.body
        content.sound = creatorNotification.notificationSound(type: data.soundType, volume: data.volume)
        content.categoryIdentifier = data.categoryId
        
        //Notification request
        let request = UNNotificationRequest(identifier: data.notificationId, content: content, trigger: trigger)
        
        userNotificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
        let category = UNNotificationCategory(
            identifier: data.categoryId,
            actions: creatorNotification.notificationAction(types: actions),
            intentIdentifiers: [],
            options: [])
        
        userNotificationCenter.setNotificationCategories([category])
    }
    
    
    private func sendSMS(toFriendOrFamily: Bool) {
        let positiveQuotes = Constants.notificationManager.familyQuote
        let text = toFriendOrFamily ? positiveQuotes.randomElement() ?? "" : "\(Constants.notificationManager.friendQuote)"
        let sms = "sms:?&body=\(text)"
        let strURL: String = sms.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        UIApplication.shared.open(URL.init(string: strURL)!, options: [:], completionHandler: nil)
    }
    
    public func deleteNotification(id: String) {
        userNotificationCenter.removePendingNotificationRequests(withIdentifiers: [id])
        userNotificationCenter.removeDeliveredNotifications(withIdentifiers: [id])
    }
    
}

// MARK: - Notification Center Delegate
extension NotificationsManager : UNUserNotificationCenterDelegate {
    
    //Fired when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        disableOneTimeAlarm(id: String(notification.request.identifier.dropLast()))
        //fetch updated alarm data for table
        delegate?.reload()
        completionHandler([.alert, .sound, .badge])
    }
    
    // code only runs if user interacts with notification
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let state = UIApplication.shared.applicationState

        //if app inactive disable if onetimealarm ?? BACKGROUND
        if state == .background || state == .inactive {
            disableOneTimeAlarm(id: String(response.notification.request.identifier.dropLast()))
            //fetch updated alarm data for table
            delegate?.reload()
        }
        
        if let actionIdentifierEnum = Notification.NotificationActionType(rawValue: response.actionIdentifier) {
            let categoryId = response.notification.request.content.categoryIdentifier
            
            switch actionIdentifierEnum {
            case .snooze:
                scheduleNotification(type: .snooze(count: 1), categoryIdentifier: categoryId, contentIdentifier: response.actionIdentifier)
            case .secondSnooze:
                scheduleNotification(type: .snooze(count: 2), categoryIdentifier: categoryId, contentIdentifier: response.actionIdentifier)
            case .textFriend:
                sendSMS(toFriendOrFamily: false)
            case .textFamily:
                sendSMS(toFriendOrFamily: true)
            case .delete:
                deleteNotification(id: response.notification.request.identifier)
            case .deferMore:
                scheduleNotification(type: .deferMore, categoryIdentifier: categoryId, contentIdentifier: response.actionIdentifier)
            case .complete:
                deleteNotification(id: response.notification.request.identifier)
            }
        }
        completionHandler()
    }
}

// MARK: - NotificationsManager Delegate
extension AlarmsViewController : NotificationsManagerDelegate {
    func reload() {
        populateAlarms()
    }
}
