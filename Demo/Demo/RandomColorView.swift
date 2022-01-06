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
    
    @State private var delay: Double = 3.0
    
    let metalDelegate = RandomRenderer()
    let metalDevice = MTLCreateSystemDefaultDevice()!
    
    var colorPixelFormat: MTLPixelFormat = {
        #if targetEnvironment(simulator)
        return .bgra8Unorm
        #else
        return (UIScreen.main.traitCollection.displayGamut == .P3) ? .bgra10_xr : .bgra8Unorm
        #endif
    }()
    
    init() {
        self.metalDelegate.delay = self.delay
    }
    
    var body: some View {
        VStack {
            MetalView(
                device: self.metalDevice,
                delegate: self.metalDelegate,
                setNeedsDisplayTrigger: nil
            )
                .preferredFramesPerSecond(60)
                .framebufferOnly(true)
                .colorPixelFormat(colorPixelFormat)
                .padding(10.0)
            Text("Frequency: \(Int(delay)) Hz")
            Slider(
                value: $delay,
                in: 1.0 ... 10.0,
                step: 1.0,
                label: { Text("Delay") },
                minimumValueLabel: { Text("1") },
                maximumValueLabel: { Text("10.0") }
            )
                .padding(10.0)
                .onChange(of: delay, perform: { _ in
                    self.metalDelegate.delay = self.delay
                })
        }
    }
}

class RandomRenderer: NSObject, MTKViewDelegate {
    
    private var commandQueue: MTLCommandQueue? = nil
    private var lastTime: CFTimeInterval = 0.0
    private var color: MTLClearColor?
    
    var delay: Double = 3.0
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) { }
    
    func draw(in view: MTKView) {
        
        if self.commandQueue == nil {
            self.commandQueue = view.device?.makeCommandQueue()
        }
        
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
        currentRenderPassDescriptor?.colorAttachments[0].clearColor = self.color ?? view.clearColor
                                
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

struct RandomColorView_Previews: PreviewProvider {
    static var previews: some View {
        RandomColorView()
    }
}
