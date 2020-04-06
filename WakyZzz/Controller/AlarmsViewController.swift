//
//  AlarmsViewController.swift
//  WakyZzz
//
//  Created by Olga Volkova on 2018-05-30.
//  Copyright © 2018 Olga Volkova OC. All rights reserved.
//

import UIKit

class AlarmsViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var alarms = [Alarm]()
    var editingIndexPath: IndexPath?
    
    @IBAction func addButtonPress(_ sender: Any) {
        presentAlarmViewController(alarm: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        config()
    }
    
    func config() {
        tableView.delegate = self
        tableView.dataSource = self
        NotificationsManager.shared.delegate = self
        populateAlarms()
    }
    
    
    func populateAlarms() {
        let allalarms = DataManager.shared.loadAllAlarms()
        alarms = allalarms.map { $0.alarms() }
        sortAlarms()
        tableView.reloadData()
    }
    
    func sortAlarms() {
        alarms.sort(by: { $0.time < $1.time })
    }
    
    
    
}


//MARK: - TableView DataSource
extension AlarmsViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alarms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmCell", for: indexPath) as! AlarmTableViewCell
        cell.delegate = self
        if let alarm = alarm(at: indexPath) {
            cell.populate(caption: alarm.caption, subcaption: alarm.repeating, enabled: alarm.isEnabled)
        }
        
        return cell
    }
    
}


//MARK: - TableView Delegate
extension AlarmsViewController :  UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, view, actionPerformed: @escaping (Bool) -> Void) in
            self.deleteAlarm(at: indexPath)
        }
        
        let edit = UIContextualAction(style: .normal, title: "Edit") { (action, view, actionPerformed: @escaping (Bool) -> Void) in
            self.editAlarm(at: indexPath)
        }
        
        return UISwipeActionsConfiguration(actions: [delete, edit])
    }
    
    func alarm(at indexPath: IndexPath) -> Alarm? {
        return indexPath.row < alarms.count ? alarms[indexPath.row] : nil
    }
    
   private func deleteAlarm(at indexPath: IndexPath) {
        let id = alarms[indexPath.row].id

        DataManager.shared.removeAlarm(id: id)
        NotificationsManager.shared.removeNotification(id: id)
        
        tableView.beginUpdates()
        alarms.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
    
   private func editAlarm(at indexPath: IndexPath) {
        editingIndexPath = indexPath
        presentAlarmViewController(alarm: alarm(at: indexPath))
    }
    
    func addAlarm(_ alarm: Alarm, at indexPath: IndexPath) {
        tableView.beginUpdates()
        alarms.insert(alarm, at: indexPath.row)
        tableView.insertRows(at: [indexPath], with: .automatic)
        sortAlarms()
        tableView.endUpdates()
    }
    
    func moveAlarm(from originalIndextPath: IndexPath, to targetIndexPath: IndexPath) {
        let alarm = alarms.remove(at: originalIndextPath.row)
        alarms.insert(alarm, at: targetIndexPath.row)
        tableView.reloadData()
    }
    
    func presentAlarmViewController(alarm: Alarm?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let popupViewController = storyboard.instantiateViewController(withIdentifier: "DetailNavigationController") as! UINavigationController
        let alarmViewController = popupViewController.viewControllers[0] as! AlarmViewController
        alarmViewController.alarm = alarm
        alarmViewController.delegate = self
        present(popupViewController, animated: true, completion: nil)
    }
    
}



