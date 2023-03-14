//
//  BLE_VirtualHID.swift
//  MController
//
//  Created by Jerry Rong on 2023/3/8.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation

class BLEVirtualHID : NSObject{
    
    var ble: BLEPeripheralManager?
    
    var ble_open : Bool = false
    
    struct AvatarState{
        var walk : Bool = false
        var run : Bool = false
        var jump : Bool = false
        var turnLeft : Bool = false
        var turnRight : Bool = false
    }
    
    var avatarState = AvatarState()
    
    let wKeyCode: String = "w"
    let sKeyCode: String = "s"
    let aKeyCode: String = "a"
    let dKeyCode: String = "d"
    let spaceKeyCode: String = "/ "
    let sixKeyCode: String = "6"
    let threeKeyCode: String = "3" // u
    
    public func faceLeft(){
        if !self.avatarState.turnLeft{
            if self.avatarState.turnRight{
                keyboardUp(self.sixKeyCode)
            }
            keyboardDown(self.threeKeyCode)
            self.avatarState.turnRight = false
            self.avatarState.turnLeft = true
            print("Turn Left")
        }
    }
    
    public func faceRight(){
        if !self.avatarState.turnRight{
            if self.avatarState.turnLeft{
                keyboardUp(self.threeKeyCode)

            }
            keyboardDown(self.sixKeyCode)
            self.avatarState.turnRight = true
            self.avatarState.turnLeft = false
            print("Turn Right")
        }
    }
    
    public func faceUp(){
        
    }
    
    public func faceDown(){
        
    }
    
    public func faceCenter(){
        if self.avatarState.turnRight{
            keyboardUp(self.sixKeyCode)
            self.avatarState.turnRight = false
            print("Turn Center")
        }
        
        if self.avatarState.turnLeft{
            keyboardUp(self.threeKeyCode)
            self.avatarState.turnLeft = false
            print("Turn Center")
        }
    }
    
    public func walk(){
        if self.avatarState.jump{
            keyboardUp(self.spaceKeyCode)
        }
        
        if self.avatarState.run{
            // right buttom up
//            rightMouseUp()
        } else if !avatarState.walk{
            keyboardDown(self.wKeyCode)
        }
        
        self.avatarState.walk = true
        self.avatarState.jump = false
        self.avatarState.run = false
    }
    
    public func run(){
        if self.avatarState.jump{
            keyboardUp(self.spaceKeyCode)
        }
        
        if self.avatarState.run{
            return
        }
        
        if self.avatarState.walk{
            // right buttom down
//            rightMouseDown()
        } else {
            keyboardDown(self.wKeyCode)
        }
        self.avatarState.walk = false
        self.avatarState.jump = false
        self.avatarState.run = true
    }
    
    public func jump(){
        if !self.avatarState.jump{
            keyboardDown(self.spaceKeyCode)
        }
        
        self.avatarState.jump = true
    }
    
    public func stand(){
        if self.avatarState.jump{
            keyboardUp(self.spaceKeyCode)
        }
        
        if self.avatarState.walk{
            keyboardUp(self.wKeyCode)
        }
        
        if self.avatarState.run{
            // right buttom up
//            rightMouseUp()
            keyboardUp(self.wKeyCode)
        }
        
        self.avatarState.walk = false
        self.avatarState.jump = false
        self.avatarState.run = false
    }
    
    private func keyboardDown(_ key: String){
        ble?.sendEvent(key: key, type: .keyDown)
    }
    
    private func keyboardUp(_ key: String){
        ble?.sendEvent(key: key, type: .keyUp)
    }
    
}

