//
//  ViewController.swift
//  Ramp Up
//
//  Created by ClementM on 30/11/2017.
//  Copyright © 2017 ClementM. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class RampPlacerVC: UIViewController, ARSCNViewDelegate, UIPopoverPresentationControllerDelegate {

    // Outlets
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var controls: UIStackView!
    @IBOutlet weak var rotateBtn: UIButton!
    @IBOutlet weak var upBtn: UIButton!
    @IBOutlet weak var downBtn: UIButton!
    
    // Variables
    var selectedRampName: String?
    var selectedRamp: SCNNode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/main.scn")!
        sceneView.autoenablesDefaultLighting = true
        
        // Set the scene to the view
        sceneView.scene = scene
        
        // Add gesture recognizers to control buttons
        let gestureForRotateButton = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(gesture:)))
        let gestureForUpButton = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(gesture:)))
        let gestureForDownButton = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(gesture:)))
        gestureForRotateButton.minimumPressDuration = 0.1
        gestureForUpButton.minimumPressDuration = 0.1
        gestureForDownButton.minimumPressDuration = 0.1
        rotateBtn.addGestureRecognizer(gestureForRotateButton)
        upBtn.addGestureRecognizer(gestureForUpButton)
        downBtn.addGestureRecognizer(gestureForDownButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    // Custom functions
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let results = sceneView.hitTest(touch.location(in: sceneView), types: .featurePoint)
        guard let hitFeature = results.last else { return }
        let hitTransform = SCNMatrix4(hitFeature.worldTransform)
        let hitPosition = SCNVector3Make(hitTransform.m41, hitTransform.m42, hitTransform.m43)
        
        placeRamp(position: hitPosition)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    // In a bigger app -> would be implemented as a protocol
    func onRampSelected(_ rampName: String) {
        selectedRampName = rampName
    }

    func placeRamp(position: SCNVector3) {
        if let rampName = selectedRampName {
            controls.isHidden = false
            let ramp = Ramp.getRampForName(rampName: rampName)
            selectedRamp = ramp
            ramp.position = position
            ramp.scale = SCNVector3Make(0.01, 0.01, 0.01)
            sceneView.scene.rootNode.addChildNode(ramp)
        }
    }
    
    @objc func onLongPress(gesture: UILongPressGestureRecognizer){
        if let ramp = selectedRamp {
            if gesture.state == .ended {
                ramp.removeAllActions()
            } else if gesture.state == .began {
                if gesture.view === rotateBtn {
                    let rotate = SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: CGFloat(0.08 * Double.pi), z: 0, duration: 0.1))
                    ramp.runAction(rotate)
                } else if gesture.view === upBtn {
                    let moveUp = SCNAction.repeatForever(SCNAction.moveBy(x: 0, y: 0.08, z: 0, duration: 0.1))
                    ramp.runAction(moveUp)
                } else if gesture.view === downBtn {
                    let moveDown = SCNAction.repeatForever(SCNAction.moveBy(x: 0, y: -0.08, z: 0, duration: 0.1))
                    ramp.runAction(moveDown)
                }
            }
        }
    }
    
    // IBActions
    @IBAction func rampBtnPressed(_ sender: UIButton) {
        let rampPickerVC = RampPickerVC(size: CGSize(width: 250, height: 500))
        rampPickerVC.rampPlacerVC = self
        rampPickerVC.modalPresentationStyle = .popover
        rampPickerVC.popoverPresentationController?.delegate = self
        present(rampPickerVC, animated: true, completion: nil)
        rampPickerVC.popoverPresentationController?.sourceView = sender
        rampPickerVC.popoverPresentationController?.sourceRect = sender.bounds
    }
    
    @IBAction func removeBtnPressed(_ sender: Any) {
        if let ramp = selectedRamp {
            ramp.removeFromParentNode()
            selectedRamp = nil
        }
    }
    

}
