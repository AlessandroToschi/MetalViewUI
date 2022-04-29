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
    
    private let metalDevice: MTLDevice
    
    @StateObject private var solidColorRenderer: SolidColorRenderer
    
    public init(metalDevice: MTLDevice) {
        
        self.metalDevice = metalDevice
        self._solidColorRenderer = StateObject(
            wrappedValue: SolidColorRenderer(
                commandQueue: metalDevice.makeCommandQueue(),
                solidColor: .yellow
            )
        )
        
    }
    
    var body: some View {
        return VStack {
            MetalViewUI(
                metalDevice: self.metalDevice,
                renderer: self.solidColorRenderer
            )
            .drawingMode(.drawNotifications(setNeedsDisplayTrigger: self.solidColorRenderer.setNeedsDisplayTrigger))
            .padding(10.0)
            ColorPicker(
                "Choose color:",
                selection: $solidColorRenderer.solidColor
            )
            .padding(10.0)
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

class SolidColorRenderer: NSObject, MTKViewDelegate, ObservableObject {
    
    @Published public var solidColor: Color {
        didSet {
            self.setNeedsDisplayPublisher.send()
        }
    }
    
    public var setNeedsDisplayTrigger: AnyPublisher<Void, Never> {
        self.setNeedsDisplayPublisher.eraseToAnyPublisher()
    }
    
    private var commandQueue: MTLCommandQueue?
    private var setNeedsDisplayPublisher: CurrentValueSubject<Void, Never>
    
    public init(commandQueue: MTLCommandQueue? = nil, solidColor: Color = .clear) {
        
        self.solidColor = solidColor
        self.setNeedsDisplayPublisher = CurrentValueSubject<Void, Never>(())
        
        self.commandQueue = commandQueue
        
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
