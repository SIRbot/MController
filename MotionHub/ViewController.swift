//
//  ViewController.swift
//  MotionHub
//
//  Created by Jerry Rong on 2023/2/7.
//  Copyright © 2023 Apple. All rights reserved.
//

import Cocoa
import Network

class ViewController: NSViewController, NSWindowDelegate {
    
    @IBOutlet weak var centerLabel: NSTextField!
    
    var results: [NWBrowser.Result] = [NWBrowser.Result]()
    var name: String = "Default"
    var passcode: String = ""
    var connectionStatus = "Scanning..."
    let virtualHIDDriver: BLEVirtualHIDDriver = BLEVirtualHIDDriver()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        centerLabel.stringValue = connectionStatus
        print(passcode)
        print(NSFullUserName())
        
        
//        sharedBrowser = PeerBrowser(delegate: self)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}
