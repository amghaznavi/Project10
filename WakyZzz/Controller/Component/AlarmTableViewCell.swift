//
//  AlarmTableViewCell.swift
//  WakyZzz
//
//  Created by Olga Volkova on 2018-05-30.
//  Copyright © 2018 Olga Volkova OC. All rights reserved.
//

import Foundation
import UIKit

protocol AlarmCellDelegate {
    func alarmCell(_ cell: AlarmTableViewCell, enabledChanged enabled: Bool)
}

class AlarmTableViewCell: UITableViewCell {
    
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var subcaptionLabel: UILabel!
    @IBOutlet weak var enabledSwitch: UISwitch!
    
    var delegate: AlarmCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    func configure() {
    }
    
    func populate(caption: String, subcaption: String, enabled: Bool) {
        captionLabel.text = caption
        subcaptionLabel.text = subcaption
        enabledSwitch.isOn = enabled
    }
    
    @IBAction func enabledStateChanged(_ sender: Any) {
        delegate?.alarmCell(self, enabledChanged: enabledSwitch.isOn)
    }

}


//MARK: - AlarmCell Delegate
extension AlarmsViewController : AlarmCellDelegate {
    
      func alarmCell(_ cell: AlarmTableViewCell, enabledChanged enabled: Bool) {
            if let indexPath = tableView.indexPath(for: cell) {
                if let alarm = self.alarm(at: indexPath) {
                    alarm.isEnabled = enabled
                    
                    DataManager.shared.addOrUpdateAlarm(alarm)
                    NotificationsManager.shared.updateNotification(alarm: alarm)
                }
            }
        }
    
    
}


