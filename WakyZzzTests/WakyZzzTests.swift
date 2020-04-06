//
//  WakyZzzTests.swift
//  WakyZzzTests
//
//  Created by Am GHAZNAVI on 28/03/2020.
//  Copyright © 2020 Am GHAZNAVI. All rights reserved.
//

import XCTest
@testable import WakyZzz

class WakyZzzTests: XCTestCase {
    
    var alarm : Alarm?
    var dataManager : DataManager!
    var notificationsManager : NotificationsManager!
    var alarmViewController : AlarmViewController!
    var alarmsViewController : AlarmsViewController!
    let userNotificationCenter = UNUserNotificationCenter.current()
    
    override func setUp() {
        super.setUp()
        alarm = Alarm()
        dataManager = DataManager()
        notificationsManager = NotificationsManager()
        alarmViewController = AlarmViewController()
        alarmsViewController = AlarmsViewController()
        removeAllAlarmsAndNotifications()
        config()
    }
    
    func config() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        self.alarmViewController = (storyboard.instantiateViewController(withIdentifier: "AlarmViewController") as! AlarmViewController)
        self.alarmViewController.loadView()
        self.alarmViewController.viewDidLoad()
        
        self.alarmsViewController = (storyboard.instantiateViewController(withIdentifier: "AlarmsViewController") as! AlarmsViewController)
        self.alarmsViewController.loadView()
        self.alarmsViewController.viewDidLoad()
    }
    
    func removeAllAlarmsAndNotifications() {
        dataManager.removeAllAlarms()
        userNotificationCenter.removeAllPendingNotificationRequests()
    }
    
    func testGivenNewAlarm_WhenSetRepeatingDay_ThenGetRepeatingDaysString() {
        let alarm = Alarm()
        XCTAssert(alarm.repeating == "One time alarm")
        alarm.repeatDays[0] = false
        alarm.repeatDays[1] = true
        alarm.repeatDays[2] = false
        alarm.repeatDays[3] = true
        alarm.repeatDays[4] = true
        alarm.repeatDays[5] = false
        alarm.repeatDays[6] = true
        XCTAssert(alarm.repeating == "Tue, Thu, Fri, Sun", "If true, day should be Tuesday, Thuirsday, Friday and Sunday")
    }
    
    func testGivenNewAlarm_WhenSetTime_ThenGetTime() {
        let alarm = Alarm()
        alarm.setTime(date: Date(timeIntervalSince1970: 10 * 3600))
        XCTAssert(alarm.time == 11 * 3600, "Time should be 11AM")
    }
    
    func testGivenNewAction_WhenSetCaption_ThenGetCaption() {
        let action = Action(caption: "Test")
        XCTAssert(action.caption == "Test", "The aciton should be 'Test'")
    }
    
    func testGivenDisableAlarm_WhenDisableOneTimeAlarm_ThenOneTimeAlarmDisabled() {
        let alarm = Alarm()
        alarm.isEnabled = true
        removeAllAlarmsAndNotifications()
        dataManager.addOrUpdateAlarm(alarm)
        XCTAssert(dataManager.loadAllAlarms().count == 1, "There should only be 1 alarm")
        notificationsManager.disableOneTimeAlarm(id: alarm.id)
        XCTAssert(dataManager.loadAllAlarms()[0].isEnabled == false, "Alarm should be set to false")
    }
    
    func testGivenAddAlarm_WhenAddOneTimeAlarm_ThenOneTimeAlarmSaved() {
        let alarm = Alarm()
        alarm.time = 8 * 3600
        alarm.isEnabled = true
        alarm.repeatDays = [false, false, false, false, false, false, false]
        dataManager.addOrUpdateAlarm(alarm)
        notificationsManager.addNotification(alarm)
        XCTAssertEqual(alarm.repeating, "One time alarm", "It should be One Time Alarm")
    }
    
    func testGivenCheckAndDeleteAlarm_WhenCheckAndDeleteSpecificAlarm_ThenSpecificAlarmDeleted() {
        
        let alarm = Alarm()
        let id = alarm.id
        
        dataManager.addOrUpdateAlarm(alarm)
        XCTAssert(dataManager.loadAllAlarms().count == 1, "One Alarm in CoreData")
        let context = AppDelegate.context
        XCTAssert(dataManager.getAlarmWith(id: id, in: context) != nil, "Alarm with same id should return")
        XCTAssert(dataManager.getAllAlarmWith(id: id, in: context).count == 1, "Alarm with same id should return")
        dataManager.removeAlarm(id: id)
        XCTAssert(dataManager.loadAllAlarms().count == 0, "No Alarm in CoreData")
        notificationsManager.removeNotification(id: id)
    }
    
    func testGivenUpdateAlam_WhenUpdateAlarm_ThenSpecificAlarmUpdated() {
        
        let alarm = Alarm()
        alarm.time = 8 * 3600
        dataManager.addOrUpdateAlarm(alarm)
        let alarmsArray = dataManager.loadAllAlarms()
        XCTAssert(alarmsArray.count == 1, "One Alarm in CoreData")
        
        let cdAlarm = alarmsArray[0]
        let newlyCreatedAlarm = cdAlarm.alarms()
        XCTAssert(newlyCreatedAlarm.time == 8 * 3600, "Alarms have same time")
        XCTAssert(newlyCreatedAlarm.id == alarm.id, "Alarms have same id")
    }
    
    // MARK: - Test AlarmViewController
    func testAlarmViewControllerTableViewCellLabelText() {
        for i in 0..<Alarm.daysOfWeek.count {
            let cell = alarmViewController.tableView(alarmViewController.tableView, cellForRowAt: IndexPath(row: i, section: 0))
            XCTAssertEqual(cell.textLabel!.text, Alarm.daysOfWeek[i])
        }
    }
    
    func testAlarmViewControllerTableView() {
        XCTAssertNotNil(alarmViewController.tableView)
    }
    
    func testAlarmViewControllerTableViewDelegate() {
        XCTAssertNotNil(alarmViewController.tableView.delegate)
    }
    
    func testAlarmViewControllerTableViewDataSource() {
        XCTAssertNotNil(alarmViewController.tableView.dataSource)
    }
    
    
    // MARK: - Test AlarmsViewController
    
    func testAlarmsViewControllerTableView() {
        XCTAssertNotNil(alarmsViewController.tableView)
    }
    
    func testAlarmsViewControllerTableViewDelegate() {
        XCTAssertNotNil(alarmsViewController.tableView.delegate)
    }
    
    func testAlarmsViewControllerTableViewDataSource() {
        XCTAssertNotNil(alarmsViewController.tableView.dataSource)
    }
    
    func testAlarmsViewControllerTitle() {
        XCTAssertEqual("WakyZzz", alarmsViewController.navigationItem.title)
    }
    
    
}
