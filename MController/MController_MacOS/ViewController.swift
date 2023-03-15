//
//  ViewController.swift
//  MController_MacOS
//
//  Created by Jerry Rong on 2023/2/28.
//  Copyright © 2023 Apple. All rights reserved.
//

import Cocoa
import Vision
import FlatBuffers

class ViewController: NSViewController {
    
    /// The full-screen view that presents the pose on top of the video frames.
    @IBOutlet var imageView: NSImageView!
    
    @IBOutlet weak var labelStack: NSStackView!
    
    /// The label that displays the model's exercise action prediction.
    @IBOutlet weak var actionLabel: NSTextField!

    /// The label that displays the model's confidence in its prediction.
    @IBOutlet weak var confidenceLabel: NSTextField!
    
    /// Captures the frames from the camera and creates a frame publisher.
    var videoCapture: VideoCapture!

    /// Builds a chain of Combine publishers from a frame publisher.
    ///
    /// The video-processing chain provides the view controller with:
    /// - Each video camera frame as a `CGImage`.
    /// - A `Pose` array of any people `Vision` observed in that frame.
    /// - Action predictions from the prominent person's poses over time.
    var videoProcessingChain: VideoProcessingChain!

    /// Maintains the aggregate time for each action the model predicts.
    /// - Tag: actionFrameCounts
    var actionFrameCounts = [String: Int]()
    
    private var virtualHID: VirtualHIDDriver = VirtualHIDDriver()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Round the corners of the stack views.
        let views = [labelStack]
        views.forEach { view in
            view?.wantsLayer = true
            view?.layer?.cornerRadius = 10
            view?.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.4).cgColor
            view?.isHidden = false
        }

        // Set the view controller as the video-processing chain's delegate.
        videoProcessingChain = VideoProcessingChain()
        videoProcessingChain.delegate = self

        // Begin receiving frames from the video capture.
        videoCapture = VideoCapture()
        videoCapture.delegate = self

        updateUILabelsWithPrediction(.startingPrediction)
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

// MARK: - Video Capture Delegate
extension ViewController: VideoCaptureDelegate {
    /// Receives a video frame publisher from a video capture.
    /// - Parameters:
    ///   - videoCapture: A `VideoCapture` instance.
    ///   - framePublisher: A new frame publisher from the video capture.
    func videoCapture(_ videoCapture: VideoCapture,
                      didCreate framePublisher: FramePublisher) {
        updateUILabelsWithPrediction(.startingPrediction)
        
        // Build a new video-processing chain by assigning the new frame publisher.
        videoProcessingChain.upstreamFramePublisher = framePublisher
    }
}

// MARK: - video-processing chain Delegate
extension ViewController: VideoProcessingChainDelegate {
    /// Receives an action prediction from a video-processing chain.
    /// - Parameters:
    ///   - chain: A video-processing chain.
    ///   - actionPrediction: An `ActionPrediction`.
    ///   - duration: The span of time the prediction represents.
    /// - Tag: detectedAction
    func videoProcessingChain(_ chain: VideoProcessingChain,
                              didPredict actionPrediction: ActionPrediction,
                              for frameCount: Int) {

        if actionPrediction.isModelLabel {
            // Update the total number of frames for this action.
            addFrameCount(frameCount, to: actionPrediction.label)
//            sharedConnection?.sendAction(actionPrediction.label)
//            print("send action: " + actionPrediction.label)
        }
        
        // Present the prediction in the UI.
        updateUILabelsWithPrediction(actionPrediction)
        
        guard let data = actionPrediction.label.data(using: .unicode) else {return}
        handleAction(data)
    }

    /// Receives a frame and any poses in that frame.
    /// - Parameters:
    ///   - chain: A video-processing chain.
    ///   - poses: A `Pose` array.
    ///   - frame: A video frame as a `CGImage`.
    func videoProcessingChain(_ chain: VideoProcessingChain,
                              didDetect poses: [Pose]?,
                              in frame: CGImage) {
//        sharedConnection?.sendPoses(poses!)
        // Render the poses on a different queue than pose publisher.
        DispatchQueue.global(qos: .userInteractive).async {
            // Draw the poses onto the frame.
            self.drawPoses(poses, onto: frame)
        }
        
        guard let poses:[Pose] = poses else {return}
        
        for pose in poses{
            handlePose(pose.poseData)
        }
    }
}


// MARK: - Helper methods
extension ViewController {
    /// Add the incremental duration to an action's total time.
    /// - Parameters:
    ///   - actionLabel: The name of the action.
    ///   - duration: The incremental duration of the action.
    private func addFrameCount(_ frameCount: Int, to actionLabel: String) {
        // Add the new duration to the current total, if it exists.
        let totalFrames = (actionFrameCounts[actionLabel] ?? 0) + frameCount

        // Assign the new total frame count for this action.
        actionFrameCounts[actionLabel] = totalFrames
    }

    /// Updates the user interface's labels with the prediction and its
    /// confidence.
    /// - Parameters:
    ///   - label: The prediction label.
    ///   - confidence: The prediction's confidence value.
    private func updateUILabelsWithPrediction(_ prediction: ActionPrediction) {
        // Update the UI's prediction label on the main thread.
        DispatchQueue.main.async { self.actionLabel.stringValue = prediction.label }

        // Update the UI's confidence label on the main thread.
        let confidenceString = prediction.confidenceString ?? "Observing..."
        DispatchQueue.main.async { self.confidenceLabel.stringValue = confidenceString }
    }

    /// Draws poses as wireframes on top of a frame, and updates the user
    /// interface with the final image.
    /// - Parameters:
    ///   - poses: An array of human body poses.
    ///   - frame: An image.
    /// - Tag: drawPoses
    private func drawPoses(_ poses: [Pose]?, onto frame: CGImage) {
        // Create a default render format at a scale of 1:1.
//        let renderFormat = NSGraphicsImageRendererFormat()
//        renderFormat.scale = 1.0

        // Create a renderer with the same size as the frame.
        let frameSize = CGSize(width: frame.width, height: frame.height)
//        let poseRenderer = UIGraphicsImageRenderer(size: frameSize,
//                                                   format: renderFormat)

        // Draw the frame first and then draw pose wireframes on top of it.
//        let frameWithPosesRendering = poseRenderer.image { rendererContext in
            // The`UIGraphicsImageRenderer` instance flips the Y-Axis presuming
            // we're drawing with UIKit's coordinate system and orientation.
        guard let cgContext = CGContext(data: nil, width: frame.width, height: frame.height, bitsPerComponent: frame.bitsPerComponent, bytesPerRow: frame.bytesPerRow, space: frame.colorSpace!, bitmapInfo: frame.bitmapInfo.rawValue)else {
            return
        }
        
        // Get the inverse of the current transform matrix (CTM).
//        let inverse = cgContext.ctm.inverted()

        // Restore the Y-Axis by multiplying the CTM by its inverse to reset
        // the context's transform matrix to the identity.
//        cgContext.concatenate(inverse)
        
        //Get the mirror transform matrix
        let mirror = CGAffineTransform(a: -1, b: 0, c: 0, d: 1, tx: frameSize.width, ty: 0)
        
        cgContext.concatenate(mirror)
        
        // Draw the camera image first as the background.
        let imageRectangle = CGRect(origin: .zero, size: frameSize)
        cgContext.draw(frame, in: imageRectangle)

        // Create a transform that converts the poses' normalized point
        // coordinates `[0.0, 1.0]` to properly fit the frame's size.
        let pointTransform = CGAffineTransform(scaleX: frameSize.width,
                                               y: frameSize.height)

        guard let poses = poses else { return }

        // Draw all the poses Vision found in the frame.
        for pose in poses {
            // Draw each pose as a wireframe at the scale of the image.
            pose.drawWireframeToContext(cgContext, applying: pointTransform)
        }
        
        guard let image = cgContext.makeImage() else { return }
//        }

        // Update the UI's full-screen image view on the main thread.
        DispatchQueue.main.async { self.imageView.image = NSImage(cgImage: image, size: .zero) }

    }
    
    private func handlePose(_ content: Data) {
        
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
            virtualHID.faceLeft()
            
        }else if !joints.contains("right_ear_joint") && joints.contains("left_ear_joint"){
            virtualHID.faceRight()
            
        }else{
            virtualHID.faceCenter()
            
        }
    }
    
    private func handleAction(_ content: Data) {
        // Handle the peer placing a character on a given location.
        guard let action = String(data: content, encoding: .unicode) else { return}
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

