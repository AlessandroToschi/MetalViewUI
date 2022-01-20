//
//  ContentView.swift
//  Demo
//
//  Created by Alessandro Toschi on 02/01/22.
//

import SwiftUI

struct ContentView: View {
    
    let metalDevice = MTLCreateSystemDefaultDevice()!
    
    var body: some View {
        TabView {
            BackgroundColorView(metalDevice: self.metalDevice)
                .tabItem {
                    Image(systemName: "1.square.fill")
                    Text("Background Color")
                }
            RandomColorView(metalDevice: self.metalDevice)
                .tabItem {
                    Image(systemName: "1.circle.fill")
                    Text("Random Color")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
