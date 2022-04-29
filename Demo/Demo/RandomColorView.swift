//
//  RandomColorView.swift
//  Demo
//
//  Created by Alessandro Toschi on 03/01/22.
//

import SwiftUI
import MetalViewUI
import MetalKit

struct RandomColorView: View {
    
    private let metalDevice: MTLDevice
    @StateObject private var randomColorRenderer: RandomColorRenderer
    
    init(metalDevice: MTLDevice) {
        
        self.metalDevice = metalDevice
        self._randomColorRenderer = StateObject(
            wrappedValue: RandomColorRenderer(
                delay: 3.0,
                commandQueue: metalDevice.makeCommandQueue()
            )
        )
        
    }
    
    var body: some View {
        VStack {
            MetalViewUI(
                metalDevice: self.metalDevice,
                renderer: self.randomColorRenderer
            )
            .drawingMode(.timeUpdates(preferredFramesPerSecond: 120))
            .framebufferOnly(true)
            .padding(10.0)
            Text("Frequency: \(Int(self.randomColorRenderer.delay)) Hz")
            Slider(
                value: $randomColorRenderer.delay,
                in: 1.0 ... 10.0,
                step: 1.0,
                label: { Text("Delay") },
                minimumValueLabel: { Text("1") },
                maximumValueLabel: { Text("10.0") }
            )
            .padding(10.0)
        }
    }
    
}

class RandomColorRenderer: NSObject, MTKViewDelegate, ObservableObject {
    
    @Published public var delay: Double
    
    private var commandQueue: MTLCommandQueue?
    private var lastTime: CFTimeInterval
    private var color: MTLClearColor
    
    public init(delay: Double, commandQueue: MTLCommandQueue?) {
        
        self.delay = delay
        
        self.commandQueue = commandQueue
        self.lastTime = 0.0
        self.color = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) { }
    
    func draw(in view: MTKView) {
        
        let currentTime = CACurrentMediaTime()
        
        if (currentTime - self.lastTime) > self.delay {
            
            self.color = MTLClearColor(
                red: .random(in: 0.0 ... 1.0),
                green: .random(in: 0.0 ... 1.0),
                blue: .random(in: 0.0 ... 1.0),
                alpha: 1.0
            )
            
            self.lastTime = currentTime
            
        }
        
        let currentRenderPassDescriptor = view.currentRenderPassDescriptor
        currentRenderPassDescriptor?.colorAttachments[0].clearColor = self.color
        
        guard let commandQueue = commandQueue,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let renderPassDescriptor = currentRenderPassDescriptor,
              let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor),
              let drawable = view.currentDrawable else { return }
        
        renderCommandEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
        
    }
    
}
