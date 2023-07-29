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

class Tower {
    var node: SCNNode!
    var sceneNode: SCNNode!
    
    var level: TowerLevel = .idle
    
    init(in sceneNode: SCNNode!) {
        let towerNode = SCNNode()
        
        towerNode.name = "tower_base"
        towerNode.position = SCNVector3(towerNode.position.x, towerNode.position.y + 0.2, towerNode.position.z)
        
        self.sceneNode = sceneNode
        self.node = towerNode
        
        setupGrowingAnimation()
    }
    
    func setupGrowingAnimation() {
        sceneNode.addChildNode(node)
        
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
        
        let sequence = SCNAction.sequence([firstWait, grow, timeBetweenAnimations, grow, timeBetweenAnimations, grow, timeBetweenAnimations, grow, timeBetweenAnimations, grow, timeBetweenAnimations, grow, finalWait, grow])
        node.runAction(sequence)
    }
}
