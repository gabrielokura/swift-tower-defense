//
//  Cannon.swift
//  TowerDefense
//
//  Created by Gabriel Motelevicz Okura on 29/07/23.
//

import SceneKit

class Cannon: SCNNode {
    var fireSpot: SCNNode!
    var weaponCannon: SCNNode!
    
    static func build() -> Cannon? {
        guard let scene = SCNScene(named: "art.scnassets/weapon_cannon.scn") else {
            return nil
        }
        guard let newNode = scene.rootNode.childNodes.first else {
            return nil
        }
        
        let cannon = Cannon()
        cannon.geometry = newNode.geometry
        
        for node in newNode.childNodes {
            cannon.addChildNode(node)
        }
        
        guard let fireSpot = cannon.childNode(withName: "fire_spot", recursively: false) else {
            return nil
        }
        
        guard let weapon = cannon.childNode(withName: "weapon_cannon", recursively: false) else {
            return nil
        }
        
        cannon.weaponCannon = weapon
        cannon.fireSpot = fireSpot
        
        return cannon
    }
    
    func fire() {
        print("cannon firing")
        let bulletsNode = Bullet()
        
        let (direction, position) = getCannonVector()
        bulletsNode.position = position
        
        let force: Float = 10
        
        let bulletDirection = SCNVector3(x: direction.x * force, y: direction.y * force, z: direction.z * force)
        bulletsNode.physicsBody?.applyForce(bulletDirection, asImpulse: true)
        self.fireSpot.addChildNode(bulletsNode)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: { // remove/replace ship after half a second to visualize collision
            self.removeNodeWithAnimation(bulletsNode, explosion: false)
        })
    }
    
    func lockAim(in node: SCNNode) {
        self.look(at: node.position)
        self.rotation.z = 0
        self.rotation.x = 0
        
        self.fireSpot.look(at: node.position)
        self.weaponCannon.look(at: node.position)
    }
    
    private func removeNodeWithAnimation(_ node: SCNNode, explosion: Bool) {
        // remove node
        node.physicsBody = nil
        node.removeFromParentNode()
        
        print("removing bullet")
    }
    
    private func getCannonVector() -> (SCNVector3, SCNVector3) { // (direction, position)
        let dir = SCNVector3(fireSpot.worldFront.x, fireSpot.worldFront.y, fireSpot.worldFront.z) // orientation of cannon in world space
        let pos = SCNVector3(0,0,0)
        
        return (dir, pos)
    }
}
