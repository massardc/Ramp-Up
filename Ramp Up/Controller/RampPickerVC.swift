//
//  RampPickerVC.swift
//  Ramp Up
//
//  Created by ClementM on 30/11/2017.
//  Copyright © 2017 ClementM. All rights reserved.
//

import UIKit
import SceneKit

class RampPickerVC: UIViewController {
 
    var sceneView: SCNView!
    var size: CGSize!
    
    init(size: CGSize) {
        super.init(nibName: nil, bundle: nil)
        self.size = size
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.frame = CGRect(origin: CGPoint.zero, size: size)
        sceneView = SCNView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        view.insertSubview(sceneView, at: 0)
        
        let scene = SCNScene(named: "art.scnassets/ramps.scn")!
        sceneView.scene = scene
        
        let camera = SCNCamera()
        camera.usesOrthographicProjection = true
        scene.rootNode.camera = camera
        
        let object = SCNScene(named: "art.scnassets/pipe.dae")
        let node = object?.rootNode.childNode(withName: "pipe", recursively: true)
        node?.scale = SCNVector3Make(0.0027, 0.0027, 0.0027)
        node?.position = SCNVector3Make(-1.05, 0.7, -1)
        scene.rootNode.addChildNode(node!)
        
        preferredContentSize = size
        
        
    }


}
