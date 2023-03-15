//
//  VirtualHID.swift
//  MController
//
//  Created by Jerry Rong on 2023/3/2.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation
import AppKit

class BLEVirtualHIDDriver : NSObject{
    
    private let upKeyCode: CGKeyCode = 126
    private let downKeyCode: CGKeyCode = 125
    private let rightKeyCode: CGKeyCode = 124
    private let leftKeyCode: CGKeyCode = 123
    private let wKeyCode: CGKeyCode = 13
    private let sKeyCode: CGKeyCode = 1
    private let aKeyCode: CGKeyCode = 0
    private let dKeyCode: CGKeyCode = 2
    private let spaceKeyCode: CGKeyCode = 49
    private let oneKeyCode: CGKeyCode = 83
    private let twoKeyCode: CGKeyCode = 84 // 2, down, 84
    private let threeKeyCode: CGKeyCode = 85
    private let fourKeyCode: CGKeyCode = 86 // 4, left, 86
    private let fiveKeyCode: CGKeyCode = 87
    private let sixKeyCode: CGKeyCode = 88 //6, right, 88
    private let sevenKeyCode: CGKeyCode = 89
    private let eightKeyCode: CGKeyCode = 91 // 8, up, 90
    private let nightKeyCode: CGKeyCode = 92
    
    public func handleInput(input:String){
        let event: String = String(input.split(separator: ", ")[0])
        let key: String = String(input.split(separator: ", ")[1])
        if(event == "U"){
            keyboardUp(key)
        }else if(event == "D"){
            keyboardDown(key)
        }else{
            print("Error: invalid input")
            return
        }
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
    
    private func keyboardDown(_ key: String){
        switch key{
        case "w":
            keyboardDown(wKeyCode)
        case "s":
            keyboardDown(sKeyCode)
        case "a":
            keyboardDown(aKeyCode)
        case "d":
            keyboardDown(dKeyCode)
        case "/ ":
            keyboardDown(spaceKeyCode)
        case "m_l":
            keyboardDown(fourKeyCode)
        case "m_r":
            keyboardDown(sixKeyCode)
        case "m_u":
            keyboardDown(eightKeyCode)
        case "m_d":
            keyboardDown(twoKeyCode)
        default:
            return
        }
    }
    
    private func keyboardUp(_ key: String){
        switch key{
        case "w":
            keyboardUp(wKeyCode)
        case "s":
            keyboardUp(sKeyCode)
        case "a":
            keyboardUp(aKeyCode)
        case "d":
            keyboardUp(dKeyCode)
        case "/ ":
            keyboardUp(spaceKeyCode)
        case "m_l":
            keyboardUp(fourKeyCode)
        case "m_r":
            keyboardUp(sixKeyCode)
        case "m_u":
            keyboardUp(eightKeyCode)
        case "m_d":
            keyboardUp(twoKeyCode)
        default:
            return
        }
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
