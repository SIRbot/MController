//
//  PeerConnection+Send.swift
//  MController
//
//  Created by Jerry Rong on 2023/2/17.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation
import Network
import FlatBuffers

extension PeerConnection{
    // Handle sending a "select character" message.
    func sendPoses(_ poses: [Pose]) {
        guard let connection = connection else {
            return
        }

        // Create a message object to hold the command type.
        let message = NWProtocolFramer.Message(controlMessageType: .pose)
        let context = NWConnection.ContentContext(identifier: "Pose",
                                                  metadata: [message])
//        print("sendPoses has " + String(poses.count) + " pose")
        for pose in poses {
            // Send the app content along with the message.
//            var buf = ByteBuffer(data: pose.poseData)
//            let poseData : MController_Pose = try?getRoot(byteBuffer: &buf)
//            print("sendPoses has " + String(poseData.landmarksCount) + " pose")
            connection.send(content: pose.poseData, contentContext: context, isComplete: true, completion: .idempotent)
        }
        
    }

    // Handle sending a "move" message.
    func sendAction(_ action: String) {
        guard let connection = connection else {
            return
        }

        // Create a message object to hold the command type.
        let message = NWProtocolFramer.Message(controlMessageType: .action)
        let context = NWConnection.ContentContext(identifier: "Action",
                                                  metadata: [message])

        // Send the app content along with the message.
        connection.send(content: action.data(using: .unicode), contentContext: context, isComplete: true, completion: .idempotent)
    }
}
