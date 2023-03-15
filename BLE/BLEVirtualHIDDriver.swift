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
    
    let upKeyCode: CGKeyCode = 126
    let downKeyCode: CGKeyCode = 125
    let rightKeyCode: CGKeyCode = 124
    let leftKeyCode: CGKeyCode = 123
    let wKeyCode: CGKeyCode = 13
    let sKeyCode: CGKeyCode = 1
    let aKeyCode: CGKeyCode = 0
    let dKeyCode: CGKeyCode = 2
    let spaceKeyCode: CGKeyCode = 49
    let oneKeyCode: CGKeyCode = 83
    let twoKeyCode: CGKeyCode = 84 //2, down, 84
    let threeKeyCode: CGKeyCode = 85
    let fourKeyCode: CGKeyCode = 84 // 4, left, 86
    let fiveKeyCode: CGKeyCode = 87
    let sixKeyCode: CGKeyCode = 91 //6, right, 88
    let sevenKeyCode: CGKeyCode = 89
    let eightKeyCode: CGKeyCode = 91 // 8, up, 90
    let nightKeyCode: CGKeyCode = 92
    
    private func handleInput(input:String){
        let event = input.split(separator: ", ")[0]
        let key = input.split(separator: ", ")[1]
        if(event == "U"){
            
        }else if(event == "D"){
            
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
        case "4":
            keyboardDown(fourKeyCode)
        case "6":
            keyboardDown(sixKeyCode)
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
        case "4":
            keyboardUp(fourKeyCode)
        case "6":
            keyboardUp(sixKeyCode)
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
