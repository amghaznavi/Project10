//
//  DataManager.swift
//  WakyZzz
//
//  Created by Am GHAZNAVI on 17/03/2020.
//  Copyright © 2020 Olga Volkova OC. All rights reserved.
//

import Foundation
import CoreData


class DataManager {
    
      static let shared = DataManager()
    
    public func loadAllAlarms() -> [WakyZzz] {
        let fetchRequest: NSFetchRequest<WakyZzz> = WakyZzz.fetchRequest()
        var matchArray: [WakyZzz] = []
        do {
            matchArray = try AppDelegate.context.fetch(fetchRequest)
        } catch {
            print("\(Constants.dataManager.error)")
        }
        return matchArray
    }
    
    public func addOrUpdateAlarm(_ alarm: Alarm) {
        let context = AppDelegate.context
        if let existingAlarm = getAlarmWith(id: alarm.id, in: context) {
            existingAlarm.update(alarm: alarm)
        } else {
            let newAlarm = WakyZzz(context: context)
            newAlarm.update(alarm: alarm)
        }
        try! context.save()
    }
    
    public func removeAlarm(id: String) {
        let context = AppDelegate.context
        if let alarm = getAlarmWith(id: id, in: context) {
            context.delete(alarm)
            try! context.save()
        }
    }
    
    public func removeAllAlarms() {
        let fetchRequest: NSFetchRequest<WakyZzz> = WakyZzz.fetchRequest()
        var matchArray: [WakyZzz] = []
        do {
            matchArray = try AppDelegate.context.fetch(fetchRequest)
            matchArray.forEach { AppDelegate.context.delete($0) }
        } catch {
            print("\(Constants.dataManager.error)")
        }
    }
    
    public func getAllAlarmWith(id: String, in context: NSManagedObjectContext) -> [WakyZzz] {
        let fetchRequest: NSFetchRequest<WakyZzz> = WakyZzz.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = %@", id)
        var match: [WakyZzz] = []
        do {
            match = try context.fetch(fetchRequest)
        } catch {
            print("\(Constants.dataManager.error)")
        }
        return match
    }
    
    public func getAlarmWith(id: String, in context: NSManagedObjectContext) -> WakyZzz? {
        let fetchRequest: NSFetchRequest<WakyZzz> = WakyZzz.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = %@", id)
        fetchRequest.fetchLimit = 1
        do {
            let match = try context.fetch(fetchRequest)
            return match.first
        } catch {
            print("\(Constants.dataManager.error)")
        }
        return nil
    }
}
