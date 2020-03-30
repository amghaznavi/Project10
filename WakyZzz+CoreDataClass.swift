//
//  WakyZzz+CoreDataClass.swift
//  WakyZzz
//
//  Created by Am GHAZNAVI on 26/03/2020.
//  Copyright © 2020 Am GHAZNAVI. All rights reserved.
//
//

import Foundation
import CoreData


public class WakyZzz: NSManagedObject {
    
    func update(alarm: Alarm) {
    
     self.id = alarm.id
        self.isEnabled = alarm.isEnabled
        self.time = Int32(alarm.time)
        self.mon = alarm.repeatDays[0]
        self.tue = alarm.repeatDays[1]
        self.wed = alarm.repeatDays[2]
        self.thu = alarm.repeatDays[3]
        self.fri = alarm.repeatDays[4]
        self.sat = alarm.repeatDays[5]
        self.sun = alarm.repeatDays[6]
    }
    
     func alarms() -> Alarm {
        
        let alarms = Alarm()
        alarms.id = self.id ?? ""
        alarms.isEnabled = self.isEnabled
        alarms.time = Int(self.time)
        alarms.repeatDays = [
            self.mon,
            self.tue,
            self.wed,
            self.thu,
            self.fri,
            self.sat,
            self.sun,
        ]
        
        return alarms
    }
}
