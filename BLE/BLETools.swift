//
//  BLETools.swift
//
//  Created by Olivier Robin on 06/03/2017.
//  Copyright © 2017 fr.ormaa. All rights reserved.
//

import Foundation
import CoreBluetooth

extension BLEPeripheralManager {
    
    func getState(peripheral: CBPeripheralManager) -> String {
        
        switch peripheral.state {
        case .poweredOn :
            return "poweredON"
        case .poweredOff :
            return "poweredOFF"
        case .resetting:
            return "resetting"
        case .unauthorized:
            return "unauthorized"
        case .unknown:
            return "unknown"
        case .unsupported:
            return "unsupported"
        @unknown default:
            return "unknown"
        }
    }
    
    func notifyValue(text: String) {
        
        guard let character = self.notifyCharac else { return }
        guard let centeral = self.notifyCentral else { return }
        
        // Set the data to notify
        let data: Data = text.data(using: String.Encoding.utf8)!

        delegate?.logToScreen( "Notify a value to central manager \(text)")

        // update the value, which will generate a notification event on central side
        localPeripheralManager.updateValue(data, for: character, onSubscribedCentrals: [centeral])
        
    }
    
    @objc func notifyValue() {

        // Set the data to notify
        let text = "Notification: "
        let data: Data = text.data(using: String.Encoding.utf8)!
        cpt += 1

        delegate?.logToScreen( "Notify a value to central manager \(text)")

        // update the value, which will generate a notification event on central side
        localPeripheralManager.updateValue(data, for: self.notifyCharac!, onSubscribedCentrals: [self.notifyCentral!])
        
    }
    
}
