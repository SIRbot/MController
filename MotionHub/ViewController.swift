//
//  ViewController.swift
//  MotionHub
//
//  Created by Jerry Rong on 2023/2/7.
//  Copyright © 2023 Apple. All rights reserved.
//

import Cocoa
import Network
//import AppKit
import FlatBuffers

class ViewController: NSViewController, NSWindowDelegate {
    
    @IBOutlet weak var centerLabel: NSTextField!
    
    var results: [NWBrowser.Result] = [NWBrowser.Result]()
    var name: String = "Default"
    var passcode: String = ""
    let virtualHID: VirtualHID = VirtualHID()
    
    // Generate a new random passcode when the app starts hosting games.
    func generatePasscode() -> String {
        return String("\(Int.random(in: 0...9))\(Int.random(in: 0...9))\(Int.random(in: 0...9))\(Int.random(in: 0...9))")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    
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
        
        //Decode from flatbuffer
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
        
        //construct a name-landmark dict
//        let zippedPairs = zip(joints, locations)
//        let jointLocations = Dictionary(uniqueKeysWithValues: zippedPairs)
        
        if joints.contains("right_ear_joint") && !joints.contains("left_ear_joint"){
            virtualHID.faceRight()
            
        }else if !joints.contains("right_ear_joint") && joints.contains("left_ear_joint"){
            virtualHID.faceLeft()
            
        }else{
            virtualHID.faceCenter()
            
        }
    }
    
    func handleAction(_ content: Data, _ message: NWProtocolFramer.Message) {
        // Handle the peer placing a character on a given location.
        if let action = String(data: content, encoding: .unicode) {
            NSLog("recv action: " + action)
            switch action {
//            case "squat":
//                break
            case "stand":
                virtualHID.stand()
                
                break
            case "jump":
                virtualHID.jump()
                
                break
            case "walk":
                virtualHID.walk()
                
                break
            case "run":
                virtualHID.run()
                
                break
            default:
                print("Unknown Action")
                virtualHID.stand()
                
                break
            }
        }
    }
}

