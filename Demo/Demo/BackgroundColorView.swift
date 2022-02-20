//
//  BackgroundColorView.swift
//  Demo
//
//  Created by Alessandro Toschi on 02/01/22.
//

import SwiftUI
import MetalViewUI
import MetalKit
import Combine

struct BackgroundColorView: View {
    
    @State private var backgroundColor: Color
    
    private let metalDevice: MTLDevice
    private let setNeedsDisplayTrigger: CurrentValueSubject<Void, Never>
    private let solidColorRenderer: SolidColorRenderer
    
    var colorPixelFormat: MTLPixelFormat = {
        #if targetEnvironment(simulator)
        return .bgra8Unorm
        #else
        return (UIScreen.main.traitCollection.displayGamut == .P3) ? .bgra10_xr : .bgra8Unorm
        #endif
    }()
    
    public init(metalDevice: MTLDevice) {
        
        self.backgroundColor = .yellow
        self.metalDevice = metalDevice
        self.setNeedsDisplayTrigger = CurrentValueSubject<Void, Never>(())
        self.solidColorRenderer = SolidColorRenderer(
            commandQueue: metalDevice.makeCommandQueue(),
            solidColor: .yellow
        )
        
    }
    
    var body: some View {
        return VStack {
            MetalViewUI(
                metalDevice: self.metalDevice,
                renderer: self.solidColorRenderer
            )
                .drawingMode(.drawNotifications(setNeedsDisplayTrigger: self.setNeedsDisplayTrigger.eraseToAnyPublisher()))
                .framebufferOnly(true)
                .colorPixelFormat(colorPixelFormat)
                .padding(10.0)
            ColorPicker("Choose color:", selection: $backgroundColor)
                .padding(10.0)
                .onChange(of: backgroundColor, perform: { color in
                    
                    self.setNeedsDisplayTrigger.send()
                    self.solidColorRenderer.solidColor = color
                    
            })
        }
    }
}

extension Color {
    
    func asMTLClearColor() -> MTLClearColor {
        
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        
        guard UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha) else { return MTLClearColorMake(0.0, 0.0, 0.0, 1.0) }
        
        return MTLClearColorMake(red, green, blue, alpha)
        
    }
    
}

class SolidColorRenderer: NSObject, MTKViewDelegate {
    
    public var solidColor: Color
    
    private var commandQueue: MTLCommandQueue?
    
    public init(commandQueue: MTLCommandQueue? = nil, solidColor: Color = .clear) {
        
        self.commandQueue = commandQueue
        self.solidColor = solidColor
        
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) { }
    
    func draw(in view: MTKView) {
        
        let currentRenderPassDescriptor = view.currentRenderPassDescriptor
        currentRenderPassDescriptor?.colorAttachments[0].clearColor = self.solidColor.asMTLClearColor()
        
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
