import SwiftUI
import MetalKit
import Combine

public struct MetalView: UIViewRepresentable {

    public enum DrawingMode {
        
        case timeUpdates(preferredFramesPerSecond: Int)
        case drawNotifications(setNeedsDisplayTrigger: AnyPublisher<Void, Never>)
        
    }
    
    public typealias DrawCallback = (MTKView, MTLCommandQueue?) -> Void
    public typealias DrawableSizeWillChangeCallback = (MTKView, CGSize, MTLCommandQueue?) -> Void

    public typealias UIViewType = MTKView
    
    private let metalDevice: MTLDevice?
    private let drawableSizeWillChangeCallback: DrawableSizeWillChangeCallback?
    private let drawCallback: DrawCallback?
    
    public init(
        metalDevice: MTLDevice?,
        drawableSizeWillChangeCallback: DrawableSizeWillChangeCallback?,
        drawCallback: DrawCallback?
    ) {
        
        self.metalDevice = metalDevice
        self.drawableSizeWillChangeCallback = drawableSizeWillChangeCallback
        self.drawCallback = drawCallback
        
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(
            metalDevice: self.metalDevice,
            drawableSizeWillChangeCallback: self.drawableSizeWillChangeCallback,
            drawCallback: self.drawCallback
        )
    }
    
    public func makeUIView(context: Context) -> MTKView {
        context.coordinator.metalView.apply(context.environment)
        context.coordinator.setNeedsDisplayTrigger = context.environment.setNeedsDisplayTrigger
        return context.coordinator.metalView
    }
    
    public func updateUIView(_ uiView: MTKView, context: Context) {
        context.coordinator.metalView.apply(context.environment)
        context.coordinator.setNeedsDisplayTrigger = context.environment.setNeedsDisplayTrigger
    }
    
    public class Coordinator: NSObject, MTKViewDelegate {
        
        let metalView: MTKView
        let commandQueue: MTLCommandQueue?
        
        let drawableSizeWillChangeCallback: DrawableSizeWillChangeCallback?
        let drawCallback: DrawCallback?

        var cancellable: AnyCancellable?
        var setNeedsDisplayTrigger: AnyPublisher<Void, Never>? {
            didSet {
                if let setNeedsDisplayTrigger = self.setNeedsDisplayTrigger {
                    self.cancellable = setNeedsDisplayTrigger.sink { [weak self] in
                        if let self = self, self.metalView.enableSetNeedsDisplay, self.metalView.isPaused {
                            self.metalView.setNeedsDisplay()
                        }
                    }
                }
            }
        }
        
        public init(
            metalDevice: MTLDevice?,
            drawableSizeWillChangeCallback: DrawableSizeWillChangeCallback?,
            drawCallback: DrawCallback?
        ) {
            
            self.commandQueue = metalDevice?.makeCommandQueue()
            self.metalView = MTKView(frame: .zero, device: metalDevice)

            self.drawableSizeWillChangeCallback = drawableSizeWillChangeCallback
            self.drawCallback = drawCallback
            
            self.cancellable = nil
            
            super.init()
            
            self.metalView.delegate = self
            
        }
        
        public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
            self.drawableSizeWillChangeCallback?(view, size, self.commandQueue);
        }
        
        public func draw(in view: MTKView) {
            
            if let drawCallback = drawCallback {
                drawCallback(view, self.commandQueue)
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
