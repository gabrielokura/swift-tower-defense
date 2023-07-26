//
//  Alien.swift
//  TowerDefense
//
//  Created by Gabriel Motelevicz Okura on 26/07/23.
//

import SceneKit

enum AlienType {
    case purple
}

class Alien {
    var node: SCNNode!
    var lifeNode: SCNNode!
    var type: AlienType!
    var path: [SCNVector3] = []
    var sceneNode: SCNNode!
    
    var fullHealth = 100
    var health = 100
    
    init(of type: AlienType!, in sceneNode: SCNNode!) {
        guard let alienScene = SCNScene(named: "art.scnassets/enemy_ufoPurple.scn") else {
            return
        }
        guard let alienNode = alienScene.rootNode.childNodes.first else {
            return
        }

        self.type = type
        self.node = alienNode
        self.lifeNode = alienNode.childNode(withName: "life", recursively: false)
        self.lifeNode.pivot = SCNMatrix4MakeTranslation(-0.5, 0, 0)
        self.lifeNode.position = SCNVector3(-0.5, 0.5, 0)
        self.sceneNode = sceneNode

        switch type {
        case .purple:
            self.node.position = SCNVector3(5, 1, -10)
            self.path = setupPath()
            
        default:
            print("invalid alien")
        }
        
        startMovement()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupPath() -> [SCNVector3]{
        var pathNodeName = ""
        var result: [SCNVector3] = []
        
        switch type {
        case .purple:
            pathNodeName = "purple_path"
        default:
            return []
        }
        
        guard let pathNode = sceneNode.childNode(withName: pathNodeName, recursively: false) else {
            return []
        }
        
        for nodes in pathNode.childNodes {
            result.append(nodes.position)
        }
        
        return result
    }
    
    func startMovement() {
        print("starting movement")
        
        let moveActions = path.map { current in
            SCNAction.move(to: current, duration: 1)
        }
        
        let sequence = SCNAction.sequence(moveActions)
        
        node.runAction(sequence) {
            print("finalizou movimento")
            self.takeDamage(40)
        }
    }
    
    func takeDamage(_ damage: Int) {
        health = max(health - damage, 0)
        
        let healthScale = Float(health)/Float(fullHealth)
        lifeNode.scale.x = healthScale
    }
}
