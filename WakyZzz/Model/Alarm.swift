//
//  Alarm.swift
//  WakyZzz
//
//  Created by Olga Volkova on 2018-05-30.
//  Copyright © 2018 Olga Volkova OC. All rights reserved.
//

import Foundation 

class Alarm {
    
    //Alarm unique ID
    var id = UUID().uuidString
    
    static let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    var time = 8 * 3600
    var repeatDays = [false, false, false, false, false, false, false]
    var isEnabled = true
    
    var alarmDate: Date? {
        let date = Date()
        let calendar = Calendar.current
        let h = time/3600
        let m = time/60 - h * 60
        
        var components = calendar.dateComponents([.hour, .minute, .second, .day, .weekOfMonth, .month, .year], from: date as Date)
        
        components.hour = h
        components.minute = m
        
        return calendar.date(from: components)
    }
    
    var caption: String {        
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: self.alarmDate!)
    }
    
    var repeating: String {
        var captions = [String]()
        for i in 0 ..< repeatDays.count {
            if repeatDays[i] {
                captions.append(Alarm.daysOfWeek[i])
            }
        }
        return captions.count > 0 ? captions.joined(separator: ", ") : "One time alarm"
    }
    
    func setTime(date: Date) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second, .day, .weekOfMonth, .month, .year], from: date as Date)
        
        time = components.hour! * 3600 + components.minute! * 60        
    }
    
    
    
    
}
