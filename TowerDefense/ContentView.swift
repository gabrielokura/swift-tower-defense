//
//  ContentView.swift
//  TowerDefense
//
//  Created by Gabriel Motelevicz Okura on 25/07/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var manager = Manager.instance
    
    var body: some View {
        ZStack {
            GameLevelView(manager: manager)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
