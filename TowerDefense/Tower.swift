//
//  Tower.swift
//  TowerDefense
//
//  Created by Gabriel Motelevicz Okura on 28/07/23.
//

import SceneKit

enum TowerLevel {
case idle, wood1, wood2, base, bottom, middle, top, full
    
    var sceneName: String {
        switch self {
        case .wood1:
            return "art.scnassets/woodStructure.scn"
        case .wood2:
            return "art.scnassets/woodStructure_high.scn"
        case .base:
            return "art.scnassets/towerA_1.scn"
        case .bottom:
            return "art.scnassets/towerA_2.scn"
        case .middle:
            return "art.scnassets/towerA_3.scn"
        case .top:
            return "art.scnassets/towerA_4.scn"
        case .full:
            return "art.scnassets/towerA_5.scn"
            
        default:
            return ""
        }
    }
}

class Tower: SCNNode {
    var sceneNode: SCNNode!
    
    var level: TowerLevel = .idle
    
    var cannon: Cannon!
    var isFiring = false
    
    static func create(in sceneNode: SCNNode!) {
        let tower = Tower()
        
        tower.name = "tower_base"
        tower.position = SCNVector3(tower.position.x, tower.position.y + 0.2, tower.position.z)
        
        tower.sceneNode = sceneNode
        tower.setupPhysicsBody()
        tower.setupGrowingAnimation()
    }
    
    func setupPhysicsBody() {
        let square = SCNBox(width: 3, height: 3, length: 3, chamferRadius: 0)
        let shape = SCNPhysicsShape(geometry: square, options: nil)
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        self.physicsBody?.isAffectedByGravity = false
        
        self.physicsBody?.categoryBitMask = CollisionCategory.tower.rawValue
        self.physicsBody?.contactTestBitMask = CollisionCategory.alien.rawValue
        self.physicsBody?.collisionBitMask = 0
    }
    
    func setupGrowingAnimation() {
        sceneNode.addChildNode(self)
        
        let firstWait = SCNAction.wait(duration: 0.05)
        let finalWait = SCNAction.wait(duration: 1)
        let timeBetweenAnimations = SCNAction.wait(duration: 0.1)
        
        let grow = SCNAction.run { node in
            node.childNodes.first?.removeFromParentNode()
            
            switch self.level {
            case .idle:
                self.level = .wood1
            case .wood1:
                self.level = .wood2
            case .wood2:
                self.level = .base
            case .base:
                self.level = .bottom
            case .bottom:
                self.level = .middle
            case .middle:
                self.level = .top
            case .top:
                self.level = .full
            case .full:
                self.level = .full
            }
            
            guard let scene = SCNScene(named: self.level.sceneName) else {
                return
            }
            guard let newNode = scene.rootNode.childNodes.first else {
                return
            }
            node.addChildNode(newNode)
        }
        
        let addCannon = SCNAction.run { node in
            let cannon = Cannon.build()!
            self.cannon = cannon
            
            cannon.position = SCNVector3(cannon.position.x, cannon.position.y + 1.3, cannon.position.z)
            print("cannon position \(cannon.position)")
            node.addChildNode(cannon)
        }
        
        let sequence = SCNAction.sequence([firstWait, grow, timeBetweenAnimations, grow, timeBetweenAnimations, grow, timeBetweenAnimations, grow, timeBetweenAnimations, grow, timeBetweenAnimations, grow, finalWait, grow, addCannon])
        self.runAction(sequence)
    }
    
    func aimCannon(in alien: Alien) {
        cannon.lockAim(in: alien)
    }
    
    func stopCannonRotation() {
        cannon.removeAllActions()
    }
    
    func startFire() {
        if isFiring {
            return
        }
        
        isFiring = true
        cannon.fire()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: { // remove/replace ship after half a second to visualize collision
            self.isFiring = false
        })
    }
}
