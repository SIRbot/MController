//
//  VirtualHID.swift
//  MController
//
//  Created by Jerry Rong on 2023/3/2.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation
import AppKit

class VirtualHID : NSObject{
    struct AvatarState{
        var walk : Bool = false
        var run : Bool = false
        var jump : Bool = false
        var turnLeft : Bool = false
        var turnRight : Bool = false
    }
    
    var avatarState = AvatarState()
    
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
    
    public func faceLeft(){
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
    }
    
    public func faceRight(){
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
    }
    
    public func faceUp(){
        
    }
    
    public func faceDown(){
        
    }
    
    public func faceCenter(){
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
    
    public func walk(){
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
            rightMouseDown()
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
            rightMouseUp()
            keyboardUp(self.wKeyCode)
        }
        
        self.avatarState.walk = false
        self.avatarState.jump = false
        self.avatarState.run = false
    }
    
    private func moveLeft(){
        let currentPos = NSEvent.mouseLocation
        let leftPose = CGPoint(x: currentPos.x - 1.0, y: CGFloat(1080)-currentPos.y)
        mouseMove(onPoint: leftPose)
    }
    
    private func moveRight(){
        let currentPos = NSEvent.mouseLocation
        let rightPose = CGPoint(x: currentPos.x + 1.0, y: CGFloat(1080)-currentPos.y)
        mouseMove(onPoint: rightPose)
    }
    
    private func moveUp(){
        let currentPos = NSEvent.mouseLocation
        let upPose = CGPoint(x: currentPos.x, y: CGFloat(1080) - (currentPos.y + 1.0))
        mouseMove(onPoint: upPose)
    }
    
    private func mouseMove(onPoint point: CGPoint) {
//        CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
        let source = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
        guard let moveEvent = CGEvent(mouseEventSource: source, mouseType: .mouseMoved, mouseCursorPosition: point, mouseButton: .left) else {
            return
        }
        moveEvent.post(tap: CGEventTapLocation.cghidEventTap)
    }
    
    private func rightMouseDown(){
        let source = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
        var mousePos = NSEvent.mouseLocation
        mousePos.y = CGFloat(1080) - mousePos.y
        guard let moveEvent = CGEvent(mouseEventSource: source, mouseType: .rightMouseDown, mouseCursorPosition: mousePos, mouseButton: .right) else {
            return
        }
        moveEvent.post(tap: CGEventTapLocation.cghidEventTap)
        
    }
    
    private func rightMouseUp(){
        let source = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
        var mousePos = NSEvent.mouseLocation
        mousePos.y = CGFloat(1080) - mousePos.y
        guard let moveEvent = CGEvent(mouseEventSource: source, mouseType: .rightMouseUp, mouseCursorPosition: mousePos, mouseButton: .right) else {
            return
        }
        moveEvent.post(tap: CGEventTapLocation.cghidEventTap)
        
    }
    
    private func leftMouseDown(){
        let source = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
        var mousePos = NSEvent.mouseLocation
        mousePos.y = CGFloat(1080) - mousePos.y
        guard let moveEvent = CGEvent(mouseEventSource: source, mouseType: .leftMouseDown, mouseCursorPosition: mousePos, mouseButton: .left) else {
            return
        }
        moveEvent.post(tap: CGEventTapLocation.cghidEventTap)
        
    }
    
    private func leftMouseUp(){
        let source = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
        var mousePos = NSEvent.mouseLocation
        mousePos.y = CGFloat(1080) - mousePos.y
        guard let moveEvent = CGEvent(mouseEventSource: source, mouseType: .leftMouseUp, mouseCursorPosition: mousePos, mouseButton: .left) else {
            return
        }
        moveEvent.post(tap: CGEventTapLocation.cghidEventTap)
        
    }
    
    private func leftMouseClicked(){
        leftMouseDown()
        leftMouseUp()
    }
    
    private func rightMouseClicked(){
        rightMouseDown()
        rightMouseUp()
    }
    
    private func keyboardDown(_ keycode: CGKeyCode){
        keyboardDown(keycode, CGEventFlags.maskNonCoalesced)
    }
    
    private func keyboardUp(_ keycode: CGKeyCode){
        keyboardUp(keycode, CGEventFlags.maskNonCoalesced)
    }
    
    private func keyboardDown(_ keycode:CGKeyCode, _ flags:CGEventFlags){
        let source = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
        guard let keyboardEvent = CGEvent(keyboardEventSource: source, virtualKey: keycode, keyDown: true) else{
            return
        }
        keyboardEvent.flags = flags
        keyboardEvent.post(tap: CGEventTapLocation.cghidEventTap)
    }
    
    private func keyboardUp(_ keycode:CGKeyCode, _ flags:CGEventFlags){
        let source = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
        guard let keyboardEvent = CGEvent(keyboardEventSource: source, virtualKey: keycode, keyDown: false) else{
            return
        }
        keyboardEvent.flags = flags
        keyboardEvent.post(tap: CGEventTapLocation.cghidEventTap)
    }
}
