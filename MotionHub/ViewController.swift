//
//  ViewController.swift
//  MotionHub
//
//  Created by Jerry Rong on 2023/2/7.
//  Copyright © 2023 Apple. All rights reserved.
//

import Cocoa
import Network
import AppKit
import FlatBuffers

class ViewController: NSViewController, NSWindowDelegate {
    
    @IBOutlet weak var centerLabel: NSTextField!
    
    var results: [NWBrowser.Result] = [NWBrowser.Result]()
    var name: String = "Default"
    var passcode: String = ""
    
    struct AvatarState{
        var walk : Bool = false
        var run : Bool = false
        var jump : Bool = false
        var turnLeft : Bool = false
        var turnRight : Bool = false
    }
    
    var avatarState = AvatarState()
    
    var eventSrc: CGEventSource?
    let tapLoc =  CGEventTapLocation.cghidEventTap
    var upKeyD: CGEvent?
    var upKeyU: CGEvent?
    var downKeyD: CGEvent?
    var downKeyU: CGEvent?
    var rightKeyD: CGEvent?
    var rightKeyU: CGEvent?
    var leftKeyD: CGEvent?
    var leftKeyU: CGEvent?
    var spaceKeyD: CGEvent?
    var spaceKeyU: CGEvent?
    var shiftKeyD: CGEvent?
    var shiftKeyU: CGEvent?
    var qKeyD: CGEvent?
    var qKeyU: CGEvent?
    var eKeyD: CGEvent?
    var eKeyU: CGEvent?
    var fKeyD: CGEvent?
    var fKeyU: CGEvent?
    var wKeyD: CGEvent?
    var wKeyU: CGEvent?
    var sKeyD: CGEvent?
    var sKeyU: CGEvent?
    var aKeyD: CGEvent?
    var aKeyU: CGEvent?
    var dKeyD: CGEvent?
    var dKeyU: CGEvent?
    var oKeyD: CGEvent?
    var oKeyU: CGEvent?
    var uKeyD: CGEvent?
    var uKeyU: CGEvent?
    var mouseRight: CGEvent?
    
    let upKeyCode: CGKeyCode = 126
    let downKeyCode: CGKeyCode = 125
    let rightKeyCode: CGKeyCode = 124
    let leftKeyCode: CGKeyCode = 123
    let wKeyCode: CGKeyCode = 13
    let sKeyCode: CGKeyCode = 1
    let aKeyCode: CGKeyCode = 0
    let dKeyCode: CGKeyCode = 2
    let spaceKeyCode: CGKeyCode = 49
    let oKeyCode: CGKeyCode = 88
    let uKeyCode: CGKeyCode = 86 // 3
    
    // Generate a new random passcode when the app starts hosting games.
    func generatePasscode() -> String {
        return String("\(Int.random(in: 0...9))\(Int.random(in: 0...9))\(Int.random(in: 0...9))\(Int.random(in: 0...9))")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.eventSrc = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
        
        self.upKeyD = CGEvent(keyboardEventSource: self.eventSrc, virtualKey: 126, keyDown: true)
        self.upKeyU = CGEvent(keyboardEventSource: self.eventSrc, virtualKey: 126, keyDown: false)
        self.downKeyD = CGEvent(keyboardEventSource: self.eventSrc, virtualKey: 125, keyDown: true)
        self.downKeyU = CGEvent(keyboardEventSource: self.eventSrc, virtualKey: 125, keyDown: false)
        self.rightKeyD = CGEvent(keyboardEventSource: self.eventSrc, virtualKey: 124, keyDown: true)
        self.rightKeyU = CGEvent(keyboardEventSource: self.eventSrc, virtualKey: 124, keyDown: false)
        self.leftKeyD = CGEvent(keyboardEventSource: self.eventSrc, virtualKey: 123, keyDown: true)
        self.leftKeyU = CGEvent(keyboardEventSource: self.eventSrc, virtualKey: 123, keyDown: false)
        self.spaceKeyD = CGEvent(keyboardEventSource: self.eventSrc, virtualKey: 49, keyDown: true)
        self.spaceKeyU = CGEvent(keyboardEventSource: self.eventSrc, virtualKey: 49, keyDown: false)
        self.shiftKeyD = CGEvent(keyboardEventSource: self.eventSrc, virtualKey: 60, keyDown: true)
        self.shiftKeyU = CGEvent(keyboardEventSource: self.eventSrc, virtualKey: 60, keyDown: false)
        self.qKeyD = CGEvent(keyboardEventSource: self.eventSrc, virtualKey: 12, keyDown: true)
        self.qKeyU = CGEvent(keyboardEventSource: self.eventSrc, virtualKey: 12, keyDown: false)
        self.eKeyD = CGEvent(keyboardEventSource: self.eventSrc, virtualKey: 14, keyDown: true)
        self.eKeyU = CGEvent(keyboardEventSource: self.eventSrc, virtualKey: 14, keyDown: false)
        self.fKeyD = CGEvent(keyboardEventSource: self.eventSrc, virtualKey: 3, keyDown: true)
        self.fKeyU = CGEvent(keyboardEventSource: self.eventSrc, virtualKey: 3, keyDown: false)
        self.wKeyD = CGEvent(keyboardEventSource: self.eventSrc, virtualKey: 13, keyDown: true)
        self.wKeyU = CGEvent(keyboardEventSource: self.eventSrc, virtualKey: 13, keyDown: false)
        self.sKeyD = CGEvent(keyboardEventSource: self.eventSrc, virtualKey: 1, keyDown: true)
        self.sKeyU = CGEvent(keyboardEventSource: self.eventSrc, virtualKey: 1, keyDown: false)
        self.dKeyD = CGEvent(keyboardEventSource: self.eventSrc, virtualKey: 2, keyDown: true)
        self.dKeyU = CGEvent(keyboardEventSource: self.eventSrc, virtualKey: 2, keyDown: false)
        self.aKeyD = CGEvent(keyboardEventSource: self.eventSrc, virtualKey: 0, keyDown: true)
        self.aKeyU = CGEvent(keyboardEventSource: self.eventSrc, virtualKey: 0, keyDown: false)
        self.oKeyD = CGEvent(keyboardEventSource: self.eventSrc, virtualKey: self.oKeyCode, keyDown: true)
        self.oKeyU = CGEvent(keyboardEventSource: self.eventSrc, virtualKey: self.oKeyCode, keyDown: false)
        self.uKeyD = CGEvent(keyboardEventSource: self.eventSrc, virtualKey: self.uKeyCode, keyDown: true)
        self.uKeyU = CGEvent(keyboardEventSource: self.eventSrc, virtualKey: self.uKeyCode, keyDown: false)
        
        self.mouseRight = CGEvent(mouseEventSource: self.eventSrc, mouseType: .mouseMoved, mouseCursorPosition: CGPoint(x: 100, y: 0), mouseButton: .left)
        
        passcode = generatePasscode()
        centerLabel.stringValue = passcode
        print(passcode)
        print(NSFullUserName())
        if let deviceName = Host.current().localizedName{
            applicationServiceListener = PeerListener(name: deviceName, passcode: passcode, delegate: self)
        }else{
            applicationServiceListener = PeerListener(name: "MotionHub", passcode: passcode, delegate: self)
        }
        
//        sharedBrowser = PeerBrowser(delegate: self)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

extension ViewController: PeerConnectionDelegate {
    // When a connection becomes ready, move into game mode.
    func connectionReady() {
        print("connection ready")
        //        navigationController?.performSegue(withIdentifier: "showGameSegue", sender: nil)
    }
    
    // When the you can't advertise a game, show an error.
    func displayAdvertiseError(_ error: NWError) {
        //        var message = "Error \(error)"
        if error == NWError.dns(DNSServiceErrorType(kDNSServiceErr_NoAuth)) {
            print("Not allowed to access the network")
            //            message = "Not allowed to access the network"
        }
        //        let alert = UIAlertController(title: "Cannot host game",
        //                                      message: message, preferredStyle: .alert)
        //        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        //        self.present(alert, animated: true)
    }
    
    // Ignore connection failures and messages prior to starting a game.
    func connectionFailed() { }
    
    func receivedMessage(content: Data?, message: NWProtocolFramer.Message) {
        guard let content = content else {
            return
        }
        switch message.controlMessageType {
        case .invalid:
            print("Received invalid message")
        case .pose:
            handlePose(content, message)
        case .action:
            handleAction(content, message)
        }
    }
    
    func handlePose(_ content: Data, _ message: NWProtocolFramer.Message) {
        // Handle the peer selecting a character family.
        //        if let pose = String(data: content, encoding: .unicode) {
        //
        //        }
        let buf = ByteBuffer(data: content)
        let pose = MController_Pose.init(buf, o: Int32(buf.read(def: UOffset.self, position: buf.reader)) + Int32(buf.reader))
        
        var joints :[String] = []
        var locations : [CGPoint] = []

        for i in 0..<pose.landmarksCount{
            let landmark = pose.landmarks(at: i)
//            print("landmark["+String(i)+"]: " + (landmark?.name)!)
            joints.append((landmark?.name)!)
            locations.append(CGPoint(x: CGFloat((landmark?.x)!), y: CGFloat((landmark?.x)!)))
        }
        let zippedPairs = zip(joints, locations)
        let jointLocations = Dictionary(uniqueKeysWithValues: zippedPairs)
//        print("location of right_ear_joint: %f, %f", jointLocations["right_ear_joint"]?.x ?? 0, jointLocations["right_ear_joint"]?.y ?? 0)
        if joints.contains("right_ear_joint") && !joints.contains("left_ear_joint"){
            
//            moveRight()
//            NSLog("current mouse x: %@ y: %@", String(Double(NSEvent.mouseLocation.x)), String(Double(NSEvent.mouseLocation.y)))
//            moveRight()
//            NSLog("moved mouse x: %@ y: %@", String(Double(NSEvent.mouseLocation.x)), String(Double(NSEvent.mouseLocation.y)))
            if !self.avatarState.turnRight{
                if self.avatarState.turnLeft{
                    keyboardUp(self.uKeyCode)
//                    self.uKeyU?.post(tap: self.tapLoc)
                }
//                self.oKeyD?.post(tap: self.tapLoc)
                keyboardDown(self.oKeyCode)
                self.avatarState.turnRight = true
                self.avatarState.turnLeft = false
                print("Turn Right")
            }
            
        }else if !joints.contains("right_ear_joint") && joints.contains("left_ear_joint"){
            
            
            if !self.avatarState.turnLeft{
                if self.avatarState.turnRight{
                    keyboardUp(self.oKeyCode)
                }
//                self.uKeyD?.post(tap: self.tapLoc)
                keyboardDown(self.uKeyCode)
                self.avatarState.turnRight = false
                self.avatarState.turnLeft = true
                print("Turn Left")
            }
            
        }else{
//            print("face center or unknown")
            if self.avatarState.turnRight{
                keyboardUp(self.oKeyCode)
                self.avatarState.turnRight = false
                print("Turn Center")
            }
            
            if self.avatarState.turnLeft{
                keyboardUp(self.uKeyCode)
                self.avatarState.turnLeft = false
                print("Turn Center")
            }
            
        }
        
//        var pose:MController_Pose = try?getCheckedRoot(byteBuffer: &buf)
//        if let poses = Pose
    }
    
    func handleAction(_ content: Data, _ message: NWProtocolFramer.Message) {
        // Handle the peer placing a character on a given location.
        if let action = String(data: content, encoding: .unicode) {
            NSLog("recv action: " + action)
            switch action {
//            case "squat":
//                NSLog("press down")
//                if self.avatarState.jump{
//                    keyboardUp(self.spaceKeyCode)
//                }
//                self.downKeyD?.post(tap: self.tapLoc)
//                self.downKeyU?.post(tap: self.tapLoc)
//                break
            case "stand":
                NSLog("do nothing")
                if self.avatarState.jump{
                    keyboardUp(self.spaceKeyCode)
                }
                
                if self.avatarState.walk{
                    keyboardUp(self.wKeyCode)
                }
                
                if self.avatarState.run{
                    // right buttom up
                    rightMouseUp()
                    keyboardUp(self.wKeyCode)
                }
                
                self.avatarState.walk = false
                self.avatarState.jump = false
                self.avatarState.run = false
                
                break
                
            case "jump":
                NSLog("press space")
//                self.spaceKeyD?.post(tap: self.tapLoc)
//                self.spaceKeyU?.post(tap: self.tapLoc)
                
                if !self.avatarState.jump{
                    keyboardDown(self.spaceKeyCode)
                }
                
                self.avatarState.jump = true
                
                break
            case "walk":
                NSLog("press up")
                if self.avatarState.jump{
                    keyboardUp(self.spaceKeyCode)
                }
                
                if self.avatarState.run{
                    // right buttom up
                    rightMouseUp()
                } else if !avatarState.walk{
                    keyboardDown(self.wKeyCode)
                }
                
                self.avatarState.walk = true
                self.avatarState.jump = false
                self.avatarState.run = false
//                self.wKeyD?.post(tap: self.tapLoc)
//                self.upKeyU?.post(tap: self.tapLoc)
                
                break
            case "run":
                NSLog("run")
                if self.avatarState.jump{
                    keyboardUp(self.spaceKeyCode)
                }
                
                if self.avatarState.run{
                    break
                }
                
                if self.avatarState.walk{
                    // right buttom down
                    rightMouseDown()
                } else {
                    keyboardDown(self.wKeyCode)
                }
                self.avatarState.walk = false
                self.avatarState.jump = false
                self.avatarState.run = true
//                self.upKeyD?.flags = CGEventFlags.maskShift
//                self.wKeyD?.post(tap: self.tapLoc)
//                self.shiftKeyD?.post(tap: self.tapLoc)
//                self.upKeyU?.post(tap: self.tapLoc)
                
                break
            default:
                print("Unknown Action")
                if self.avatarState.jump{
                    keyboardUp(self.spaceKeyCode)
                }
                
                if self.avatarState.walk{
                    keyboardUp(self.wKeyCode)
                }
                
                if self.avatarState.run{
                    // right buttom up
                    rightMouseUp()
                    keyboardUp(self.wKeyCode)
                }
                
                self.avatarState.walk = false
                self.avatarState.jump = false
                self.avatarState.run = false
                
                break
            }
        }
    }
    
    func moveLeft(){
        let currentPos = NSEvent.mouseLocation
        let leftPose = CGPoint(x: currentPos.x - 1.0, y: CGFloat(1080)-currentPos.y)
        mouseMove(onPoint: leftPose)
    }
    
    func moveRight(){
        let currentPos = NSEvent.mouseLocation
        let rightPose = CGPoint(x: currentPos.x + 1.0, y: CGFloat(1080)-currentPos.y)
        mouseMove(onPoint: rightPose)
    }
    
    func moveUp(){
        let currentPos = NSEvent.mouseLocation
        let upPose = CGPoint(x: currentPos.x, y: CGFloat(1080) - (currentPos.y + 1.0))
        mouseMove(onPoint: upPose)
    }
    
    func mouseMove(onPoint point: CGPoint) {
//        CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
        let source = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
        guard let moveEvent = CGEvent(mouseEventSource: source, mouseType: .mouseMoved, mouseCursorPosition: point, mouseButton: .left) else {
            return
        }
        moveEvent.post(tap: CGEventTapLocation.cghidEventTap)
    }
    
    func rightMouseDown(){
        let source = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
        var mousePos = NSEvent.mouseLocation
        mousePos.y = CGFloat(1080) - mousePos.y
        guard let moveEvent = CGEvent(mouseEventSource: source, mouseType: .rightMouseDown, mouseCursorPosition: mousePos, mouseButton: .right) else {
            return
        }
        moveEvent.post(tap: CGEventTapLocation.cghidEventTap)
        
    }
    
    func rightMouseUp(){
        let source = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
        var mousePos = NSEvent.mouseLocation
        mousePos.y = CGFloat(1080) - mousePos.y
        guard let moveEvent = CGEvent(mouseEventSource: source, mouseType: .rightMouseUp, mouseCursorPosition: mousePos, mouseButton: .right) else {
            return
        }
        moveEvent.post(tap: CGEventTapLocation.cghidEventTap)
        
    }
    
    func leftMouseDown(){
        let source = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
        var mousePos = NSEvent.mouseLocation
        mousePos.y = CGFloat(1080) - mousePos.y
        guard let moveEvent = CGEvent(mouseEventSource: source, mouseType: .leftMouseDown, mouseCursorPosition: mousePos, mouseButton: .left) else {
            return
        }
        moveEvent.post(tap: CGEventTapLocation.cghidEventTap)
        
    }
    
    func leftMouseUp(){
        let source = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
        var mousePos = NSEvent.mouseLocation
        mousePos.y = CGFloat(1080) - mousePos.y
        guard let moveEvent = CGEvent(mouseEventSource: source, mouseType: .leftMouseUp, mouseCursorPosition: mousePos, mouseButton: .left) else {
            return
        }
        moveEvent.post(tap: CGEventTapLocation.cghidEventTap)
        
    }
    
    func leftMouseClicked(){
        leftMouseDown()
        leftMouseUp()
    }
    
    func rightMouseClicked(){
        rightMouseDown()
        rightMouseUp()
    }
    
    func keyboardDown(_ keycode: CGKeyCode){
        keyboardDown(keycode, CGEventFlags.maskNonCoalesced)
    }
    
    func keyboardUp(_ keycode: CGKeyCode){
        keyboardUp(keycode, CGEventFlags.maskNonCoalesced)
    }
    
    func keyboardDown(_ keycode:CGKeyCode, _ flags:CGEventFlags){
        let source = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
        guard let keyboardEvent = CGEvent(keyboardEventSource: source, virtualKey: keycode, keyDown: true) else{
            return
        }
        keyboardEvent.flags = flags
        keyboardEvent.post(tap: CGEventTapLocation.cghidEventTap)
    }
    
    func keyboardUp(_ keycode:CGKeyCode, _ flags:CGEventFlags){
        let source = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
        guard let keyboardEvent = CGEvent(keyboardEventSource: source, virtualKey: keycode, keyDown: false) else{
            return
        }
        keyboardEvent.flags = flags
        keyboardEvent.post(tap: CGEventTapLocation.cghidEventTap)
    }
}

