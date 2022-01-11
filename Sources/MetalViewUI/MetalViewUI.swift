import SwiftUI
import MetalKit
import Combine

public struct MetalView<C>: UIViewRepresentable {
    
    public typealias DrawCallback = (C?, MTKView, MTLCommandQueue?) -> Void
    public typealias DrawableSizeWillChangeCallback = (C?, MTKView, CGSize, MTLCommandQueue?) -> Void

    public typealias UIViewType = MTKView
    
    private let metalDevice: MTLDevice?
    private let drawableSizeWillChangeCallback: DrawableSizeWillChangeCallback?
    private let drawCallback: DrawCallback?
    private let contentTrigger: AnyPublisher<C, Never>?
    
    public init(
        metalDevice: MTLDevice?,
        drawableSizeWillChangeCallback: DrawableSizeWillChangeCallback?,
        drawCallback: DrawCallback?,
        contentTrigger: AnyPublisher<C, Never>?
    ) {
        
        self.metalDevice = metalDevice
        self.drawableSizeWillChangeCallback = drawableSizeWillChangeCallback
        self.drawCallback = drawCallback
        self.contentTrigger = contentTrigger
        
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(
            metalDevice: self.metalDevice,
            drawableSizeWillChangeCallback: self.drawableSizeWillChangeCallback,
            drawCallback: self.drawCallback,
            contentTrigger: self.contentTrigger
        )
    }
    
    public func makeUIView(context: Context) -> MTKView {
        context.coordinator.metalView.apply(context.environment)
    }
    
    public func updateUIView(_ uiView: MTKView, context: Context) {
        uiView.apply(context.environment)
    }
    
    public class Coordinator: NSObject, MTKViewDelegate {
                
        let metalDevice: MTLDevice?
        let drawableSizeWillChangeCallback: DrawableSizeWillChangeCallback?
        let drawCallback: DrawCallback?
        let metalView: MTKView
        let commandQueue: MTLCommandQueue?
        var cancellable: AnyCancellable?
        var content: C?
        
        public init(
            metalDevice: MTLDevice?,
            drawableSizeWillChangeCallback: DrawableSizeWillChangeCallback?,
            drawCallback: DrawCallback?,
            contentTrigger: AnyPublisher<C, Never>?
        ) {
            
            self.metalDevice = metalDevice
            self.drawableSizeWillChangeCallback = drawableSizeWillChangeCallback
            self.drawCallback = drawCallback
            self.metalView = MTKView(frame: .zero, device: metalDevice)
            self.commandQueue = metalDevice?.makeCommandQueue()
            self.cancellable = nil
            
            super.init()
            
            self.metalView.delegate = self
            
            if let contentTrigger = contentTrigger{
                
                self.cancellable = contentTrigger.receive(on: DispatchQueue.main).sink { [weak self] content in
                    
                    guard let self = self else { return }
                    
                    self.content = content
                    
                    if self.metalView.enableSetNeedsDisplay && self.metalView.isPaused {
                        self.metalView.setNeedsDisplay()
                    }
                    
                }
                
            }
            
            
        }
        
        public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
            self.drawableSizeWillChangeCallback?(self.content, view, size, self.commandQueue);
        }
        
        public func draw(in view: MTKView) {
            
            if let drawCallback = drawCallback {
                drawCallback(self.content, view, self.commandQueue)
            } else {
                
                guard let commandQueue = self.commandQueue,
                      let commandBuffer = commandQueue.makeCommandBuffer(),
                      let currentRenderPassDescriptor = view.currentRenderPassDescriptor,
                      let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: currentRenderPassDescriptor),
                      let currentDrawable = view.currentDrawable else { return }
                
                renderCommandEncoder.endEncoding()
                
                commandBuffer.present(currentDrawable)
                commandBuffer.commit()
                commandBuffer.waitUntilScheduled()
                
            }
            
        }
        
    }
    
}
