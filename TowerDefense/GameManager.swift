//
//  GameManager.swift
//  TowerDefense
//
//  Created by Gabriel Motelevicz Okura on 26/07/23.
//

import Foundation
import Combine

enum GameActions {
    case start, returnCamera, startEditing, finishEditing
}

class Manager: ObservableObject {
    static var instance = Manager()
    
    @Published var isCameraFixed: Bool = false
    @Published var isEditingTerrain: Bool = false
    @Published var hasStarted: Bool = false
    
    var actionStream = PassthroughSubject<GameActions, Never>()
    
    func returnCameraToInitialPosition() {
        isCameraFixed = true
        actionStream.send(.returnCamera)
    }
    
    func editTerrain() {
        isEditingTerrain.toggle()
        actionStream.send(isEditingTerrain ? .startEditing : .finishEditing)
    }
    
    func startGame() {
        hasStarted = true
        actionStream.send(.start)
    }
    
}
