//
//  ViewController.swift
//  MotionHub
//
//  Created by Jerry Rong on 2023/2/7.
//  Copyright © 2023 Apple. All rights reserved.
//

import Cocoa
import Network

class ViewController: NSViewController, NSWindowDelegate{
    
    @IBOutlet weak var centerLabel: NSTextField!
    @IBOutlet weak var logView: NSScrollView!
    @IBOutlet var logTextView: NSTextView!
    @IBOutlet weak var centralSwitch: NSSwitch!

    let virtualHIDDriver: BLEVirtualHIDDriver = BLEVirtualHIDDriver()
    
    var appDelegate:AppDelegate? = nil
    
    let peripheralUUID = "AC7FA82C-ACC0-4DC1-AC09-4075B336B640"
    let characRead = "5DDA8FC4-D5D6-4E10-8A39-7928251965AC"
//    let characWrite = "9B89E762-226A-4BBB-A381-A4B8CC6E1105"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        centerLabel.stringValue = "Closed"
        print(NSFullUserName())
        
        appDelegate =  NSApplication.shared.delegate as! AppDelegate?
        appDelegate!.singleton.logger.log("viewDidLoad")
        
//        sharedBrowser = PeerBrowser(delegate: self)
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        appDelegate!.singleton.logger.log("viewDidAppear")
        
        logTextView.string = "Starting..."
    
        if appDelegate!.singleton.appRestored,
        let id = appDelegate!.singleton.centralManagerToRestore {

            log("View did appear, restore peropheral connection \(id)")
            
            appDelegate!.singleton.bleController.restoreCentralManager(viewControllerDelegate: self, centralName: id )
        }
    }
    
    func log(_ object: Any?) {
        appDelegate?.singleton.logger.log(object)
    }
    
    // Add text to the UITextView
    func addText(text: String) {
        log(text)
        
        DispatchQueue.main.async {
            let txt = self.logTextView.string + "\n"
            self.logTextView.string = txt + text
        }
    }
    
    @IBAction func centralSwitchOnOff(_ sender: Any) {
        if(self.centralSwitch.state == .on){
            self.addText(text: "switch on")
            log("start central click")
            self.centerLabel.stringValue = "Starting..."
            
            DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
                
                self.addText(text: "Starting central Manager")

                self.appDelegate!.singleton.bleController.appDelegate = self.appDelegate      // TODO remove this ugly thing
                self.appDelegate!.singleton.bleController.ble.appDelegate = self.appDelegate      // TODO remove this ugly thing

                if !self.appDelegate!.singleton.bleController.startCentralManager(viewControllerDelegate: self) {
                    // Display en error
                    self.addText(text: "I believe that Bluetooth is off, because starting central manager return an error")
                    return
                }
                
                DispatchQueue.main.async {
                    self.centerLabel.stringValue = "Scanning"
                }
            
                self.addText(text: "central manager started. will search for peripheral : " + self.peripheralUUID)

                if !self.appDelegate!.singleton.bleController.searchDevice(uuidName: self.peripheralUUID) {
                    // Display en error
                    self.addText(text: "The peripheral was not found, even after a while. check its name, and if it is near, and swithed on.\n please try again later.")
                    self.centralSwitch.state = .off
                    self.centerLabel.stringValue = "Fail to scan"
                    return
                }
                
                DispatchQueue.main.async {
                    self.centerLabel.stringValue = "Connecting..."
                }
                
                self.addText(text: "peripheral : " + self.peripheralUUID + " discovered.")

                if !self.appDelegate!.singleton.bleController.connectToDevice(uuid: self.peripheralUUID) {
                    // Display en error
                    self.addText(text: "Connection failed !!!")
                    self.centralSwitch.state = .off
                    self.centerLabel.stringValue = "Fail to connect"
                    return
                }
                
                //Connected

                if !self.appDelegate!.singleton.bleController.discoverServices() {
                    self.addText(text: "discover service and characteristics failed !!!")
                    self.centralSwitch.state = .off
                    self.centerLabel.stringValue = "Fail to discover MController services"
                    return
                }
                
                self.addText(text: "services discovered")

                self.addText(text: "request notification for charac :\n" + self.characRead)
                self.appDelegate!.singleton.bleController.requestNotify(uuid: self.characRead)

//                self.addText(text: "\nRead a value from peripheral " + self.characRead)
//                self.appDelegate?.singleton.bleController.read(uuid: self.characRead)
                
//                self.appDelegate?.singleton.bleController.write(uuid: self.characWrite, message: "I am ok guy")
//                self.addText(text: "\nwrite to peripheral : I am ok guy, char :" + self.characWrite)
//
//                self.appDelegate?.singleton.bleController.writeAsync(uuid: self.characWrite, message: "hello mate")
//                self.addText(text: "\nwriteAsync to peripheral : hello mate, char :" + self.characWrite)

                // start some timer, which will read or write data from / to peripheral
                //self.timerRead = Timer.scheduledTimer(timeInterval: TimeInterval(2), target: self, selector: #selector(self.read), userInfo: nil, repeats: true)
                //self.timerWrite = Timer.scheduledTimer(timeInterval: TimeInterval(5), target: self, selector: #selector(self.write), userInfo: nil, repeats: true)
                
            }
        }else{
            self.addText(text: "switch off")
            self.appDelegate!.singleton.bleController.stopCentralManager()

            self.logTextView.string = ""
            DispatchQueue.main.async {
                self.centerLabel.stringValue = "Closed"
            }
        }
    }
}

extension ViewController:BLEProtocol{
    func disconnected(message: String) {
        self.centralSwitch.state = .off
        self.centerLabel.stringValue = "Disconnected"
        self.addText(text: "Disconnected")
        return
    }
    
    func failConnected(message: String) {
        return
    }
    
    func connected(message: String) {
        self.centerLabel.stringValue = "Connected"
        self.addText(text: "Connected")
    }
    
    func valueRead(charuuid: String, message: String) {
        self.addText(text: "Read Value: " + message + " from characteristic: " + charuuid)
        
    }
    
    func valueWrite(message: String) {
        return
    }
}
