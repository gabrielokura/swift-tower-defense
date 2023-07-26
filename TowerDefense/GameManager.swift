//
//  GameManager.swift
//  TowerDefense
//
//  Created by Gabriel Motelevicz Okura on 26/07/23.
//

import Foundation
import Combine

enum GameActions {
    case start, returnCamera
}

class Manager: ObservableObject {
    static var instance = Manager()
    
    @Published var isCameraFixed: Bool = false
    var actionStream = PassthroughSubject<GameActions, Never>()
    
    func returnCameraToInitialPosition() {
        isCameraFixed = true
        actionStream.send(.returnCamera)
    }
    
}
