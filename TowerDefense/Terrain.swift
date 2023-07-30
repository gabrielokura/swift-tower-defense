//
//  Terrain.swift
//  TowerDefense
//
//  Created by Gabriel Motelevicz Okura on 27/07/23.
//

import SceneKit

class Terrain {
    var nodes: [SCNNode]!
    var sceneNode: SCNNode!
    
    var isEditing = false
    
    private let editableObjectName = "editable_tile"
    private let nonEditableObjectName = "tile"
    private let clickableName = "clickable"
    
    init(in sceneNode: SCNNode!) {
        self.sceneNode = sceneNode
        
        self.nodes = sceneNode.childNodes(passingTest: { (node, stop) -> Bool in
            return node.name == editableObjectName
        })
        
        print(self.nodes.count)
//        setup()
    }
    
    private func setup() {
        for i in 0..<nodes.count {
            nodes[i].name! += "_on\(i)"
        }
    }
    
    func startEditing() {
        print("start editing terrain")
        isEditing = true
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(.red)
        
        for node in nodes {
            let childNode = node.childNodes.first!
            let redBox = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0)
            let redBoxnode = SCNNode(geometry: redBox)
            redBoxnode.position = SCNVector3(childNode.position.x, childNode.position.y + 0.3, childNode.position.z)
            redBoxnode.geometry?.materials = [material]
            redBoxnode.name = clickableName
            
            let sequence = SCNAction.sequence([SCNAction.moveBy(x: 0, y: 0.6, z: 0, duration: 0.5), SCNAction.moveBy(x: 0, y: -0.6, z: 0, duration: 0.5)])
            redBoxnode.runAction(SCNAction.repeatForever(sequence))
            
            childNode.addChildNode(redBoxnode)
        }
    }
    
    func finishEditing() {
        print("finish editing terrain")
        isEditing = false
        
        let clear = SCNMaterial()
        clear.diffuse.contents = UIColor(.clear)
        
        for node in nodes {
            let childNode = node.childNodes.first!
            guard let clickable = childNode.childNode(withName: clickableName, recursively: false) else {
                return
            }
            clickable.removeFromParentNode()
        }
    }
    
    func tapOnTerrain(node terrain: SCNNode) {
        print("tap on \(terrain.name ?? "sem nome")")
        
        if !isEditing {
            print("ignore tap")
            return
        }
        
       addTowerInTerrain(terrain)
    }
    
    private func addTowerInTerrain(_ terrain: SCNNode) {
        // adiciona a torre
        let _ = Tower.create(in: terrain)
        
        // remove a redBox
        guard let clickable = terrain.childNode(withName: clickableName, recursively: false) else {
            return
        }
        clickable.removeFromParentNode()
        
        //torna o parent node não editable
        terrain.parent?.name = nonEditableObjectName
        
        //atualiza a lista de terrenos
        nodes = sceneNode.childNodes(passingTest: { (node, stop) -> Bool in
            return node.name == editableObjectName
        })
    }
}
