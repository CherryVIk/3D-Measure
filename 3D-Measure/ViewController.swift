//
//  ViewController.swift
//  3D-Measure
//
//  Created by Victoria Boichenko on 30.08.2020.
//  Copyright © 2020 Victoria Boichenko. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

extension SCNGeometry {

    class func line(vector1: SCNVector3,
                    vector2: SCNVector3) -> SCNGeometry {

        let sources = SCNGeometrySource(vertices: [vector1,
                                                   vector2])
        let index: [Int32] = [0,1]

        let elements = SCNGeometryElement(indices: index,
                                    primitiveType: .line)

        return SCNGeometry(sources: [sources],
                          elements: [elements])
    }
}

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    let dotRadius = 0.005
    var dotNodes = [SCNNode]()
    var textNode = SCNNode()
    var lineNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if dotNodes.count >= 2 {
            for dot in dotNodes {
                dot.removeFromParentNode()
            }
            dotNodes = [SCNNode]()
        }
        
        if let touch = touches.first?.location(in: sceneView) {
            let hitTestResult = sceneView.hitTest(touch, types: .featurePoint) // .featurePoint - automatically identified
            if let hitResult = hitTestResult.first {
                addDot(at: hitResult )
            }
        }
        
    }
    
    func addDot(at location: ARHitTestResult){
        
        
        let dotGeometry = SCNSphere(radius: CGFloat(dotRadius))
        
        let dotMaterial = SCNMaterial()
        
        dotMaterial.diffuse.contents = UIColor.red
        
        dotGeometry.materials = [dotMaterial]
        
        let position = location.worldTransform.columns.3
        
        let dotNode = SCNNode(geometry: dotGeometry)
        dotNode.position = SCNVector3(position.x, position.y, position.z)
        
        sceneView.scene.rootNode.addChildNode(dotNode)
        
        dotNodes.append(dotNode)
        
        if dotNodes.count == 2 {
            calculateDistance()
            dotNodes.remove(at: 0)
        }
    }
    
    func calculateDistance(){
        let start = dotNodes[0]
        let end = dotNodes[1]
        
        print("start: \(start)")
        print("end: \(end)")
        
        let posS = start.position
        let posE = end.position
        
        let distanceSquared: Float =
            pow(posS.x - posE.x, 2) +
                pow(posS.y - posE.y, 2)  +
                pow(posS.z - posE.z, 2)
        
        let distance = sqrt(distanceSquared)
        
        print("without abs : \(distance)")
        print("with abs : \(abs(distance))")
        
        drawLine(start: posS, end: posE)
        
        let middlePoint = SCNVector3((posE.x + posS.x)/2, (posE.y + posS.y)/2, (posE.z + posS.z)/2 )
        updateText(distance, at: middlePoint)
    }
    
    func drawLine(start: SCNVector3, end: SCNVector3){
        lineNode.removeFromParentNode()
        
        let lineGeo = SCNGeometry.line(vector1: start, vector2: end)
        lineNode = SCNNode(geometry: lineGeo)
        sceneView.scene.rootNode.addChildNode(lineNode)
    }
    
    func updateText(_ distance: Float, at position: SCNVector3){
        textNode.removeFromParentNode()
        
        let textGeometry = SCNText(string: String(distance), extrusionDepth: 1.0)
        
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        
        textNode = SCNNode(geometry: textGeometry)
        
        textNode.position = SCNVector3(position.x, position.y + 0.01, position.z)

//        textNode.scale = SCNVector3(0.01, 0.01, 0.01)
         textNode.scale = SCNVector3(0.5, 0.5, 0.5)
         sceneView.scene.rootNode.addChildNode(textNode)
    }
    
}
