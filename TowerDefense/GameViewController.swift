//
//  GameViewController.swift
//  TowerDefense
//
//  Created by Gabriel Motelevicz Okura on 25/07/23.
//

import UIKit
import SceneKit
import Combine
import SwiftUI

struct GameLevelViewRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {
        return GameSceneController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}


class GameSceneController: UIViewController {
    var sceneView: SCNView!
    
    private var initialCameraPosition: SCNVector3!
    private var initialCameraRotation: SCNVector4!
    
    var cameraNode: SCNNode!
    var scene: SCNScene!
    
    var manager: Manager = Manager.instance
    var cancellableBag = Set<AnyCancellable>()
    
    var terrain: Terrain!
    
    override func loadView() {
        super.loadView()
        
        let view = SCNView()
        self.view = view
        
        self.sceneView = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = SCNScene(named: "art.scnassets/GameLevel.scn")!
        self.sceneView.scene = scene
        self.scene = scene
        
        self.sceneView.showsStatistics = true
        self.sceneView.debugOptions = [.showConstraints, .showSkeletons, .showPhysicsShapes]
        
        self.setupCamera()
        self.setupBackground()
        self.subscribeToFixedCameraEvents()
        self.subscribeToActions()
        self.setupAliens()
        self.setupTerrain()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.sceneView.addGestureRecognizer(tapGesture)
        self.scene.physicsWorld.contactDelegate = self
    }
    
    private func subscribeToFixedCameraEvents() {
        manager.$isCameraFixed.sink { value in
            self.sceneView.allowsCameraControl = !value
        }.store(in: &cancellableBag)
    }
    
    private func subscribeToActions() {
        manager.actionStream.sink { action in
            switch action {
            case .returnCamera:
                self.returnCameraToInitialPosition()
            case .startEditing:
                self.terrain.startEditing()
            case .finishEditing:
                self.terrain.finishEditing()
            default:
                print("dont do anything")
            }
        }.store(in: &cancellableBag)
    }
    
    private func setupCamera() {
        cameraNode = self.scene.rootNode.childNode(withName: "camera", recursively: false)
        
        initialCameraPosition = cameraNode!.position
        initialCameraRotation = cameraNode!.rotation
    }
    
    private func setupBackground() {
        let skyboxImages = [UIImage(named: "space_rt"),
                            UIImage(named: "space_lf"),
                            UIImage(named: "space_up"),
                            UIImage(named: "space_dn"),
                            UIImage(named: "space_ft"),
                            UIImage(named: "space_bk")]
        
        self.scene.background.contents = skyboxImages
    }
    
    func returnCameraToInitialPosition() {
        cameraNode.position = initialCameraPosition
        cameraNode.rotation = initialCameraRotation
        self.sceneView.pointOfView = cameraNode
    }
    
    func setupAliens() {
        let alien = Alien.create(.purple, in: self.scene.rootNode)!
        sceneView.scene?.rootNode.addChildNode(alien)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: { // remove/replace ship after half a second to visualize collision
            self.setupAliens()
        })
    }
    
    func setupTerrain() {
        terrain = Terrain(in: self.scene.rootNode)
    }
    
    @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // check what nodes are tapped
        let p = gestureRecognize.location(in: sceneView)
        let hitResults = sceneView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result: SCNHitTestResult = hitResults[0]
            let name = result.node.parent?.name
            
            if (name != nil && name!.contains("editable")) {
                terrain.tapOnTerrain(node: result.node)
                return
            }
//            print(result.textureCoordinates(withMappingChannel 0)) // This line is added here.
//            print("x: \(p.x) y: \(p.y)") // <--- THIS IS WHERE I PRINT THE COORDINATES
        }
    }
}

extension GameSceneController: SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let alien = contact.nodeA is Alien ? contact.nodeA as! Alien : contact.nodeB as! Alien
        
        if contact.nodeA is Bullet || contact.nodeB is Bullet {
            let bullet = contact.nodeA is Bullet ? contact.nodeA as! Bullet : contact.nodeB as! Bullet
            bullet.removeFromParentNode()
            alien.takeDamage(30)
            print("alien tomou tiro")
            return
        }
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didUpdate contact: SCNPhysicsContact) {
        let alien = contact.nodeA is Alien ? contact.nodeA as! Alien : contact.nodeB as! Alien
        
        if contact.nodeA is Tower || contact.nodeB is Tower {
            let tower = contact.nodeA is Tower ? contact.nodeA as! Tower : contact.nodeB as! Tower
            tower.aimCannon(in: alien)
            tower.startFire()
        }
    }
}
