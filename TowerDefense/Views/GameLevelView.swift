//
//  GameLevelView.swift
//  TowerDefense
//
//  Created by Gabriel Motelevicz Okura on 25/07/23.
//

import SwiftUI
import SceneKit

struct GameLevelView: View {
    @ObservedObject var manager: Manager
    
    var body: some View {
        ZStack {
            GameLevelViewRepresentable()
                .ignoresSafeArea()
            
            if !manager.hasStarted {
                startButton
                    .padding(.leading, 56)
                    .padding(.top, 24)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            
            HStack(spacing: 24) {
                editTerrainButton
                fixCameraButton
                returnCameraPositionButton
            }
            .padding(.trailing, 56)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        }
    }
    
    var fixCameraButton: some View {
        Image(systemName: manager.isCameraFixed ? "mappin.slash.circle" :  "mappin.circle")
            .font(.largeTitle)
            .foregroundColor(.white)
            .onTapGesture {
                manager.isCameraFixed.toggle()
            }
    }
    
    var returnCameraPositionButton: some View {
        Image(systemName: "camera.circle")
            .font(.largeTitle)
            .foregroundColor(.white)
            .onTapGesture {
                manager.returnCameraToInitialPosition()
            }
    }
    
    var editTerrainButton: some View {
        Image(systemName: manager.isEditingTerrain ? "square.and.pencil.circle.fill" : "square.and.pencil.circle")
            .font(.largeTitle)
            .foregroundColor(.white)
            .onTapGesture {
                manager.editTerrain()
            }
    }
    
    var startButton: some View {
        Image(systemName: "play.circle")
            .font(.largeTitle)
            .foregroundColor(.green)
            .onTapGesture {
                manager.startGame()
            }
    }
}

struct GameLevelView_Previews: PreviewProvider {
    static var previews: some View {
        GameLevelView(manager: Manager.instance)
    }
}
