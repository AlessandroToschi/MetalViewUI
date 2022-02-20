import SwiftUI
import MetalKit
import Combine

public struct MetalViewUI: UIViewRepresentable {

    public enum DrawingMode {
        
        case timeUpdates(preferredFramesPerSecond: Int)
        case drawNotifications(setNeedsDisplayTrigger: AnyPublisher<Void, Never>)
        
    }

    public typealias UIViewType = MTKView
    
    private let metalDevice: MTLDevice?
    private weak var renderer: MTKViewDelegate?
    
    public init(metalDevice: MTLDevice?, renderer: MTKViewDelegate?) {
        
        self.metalDevice = metalDevice
        self.renderer = renderer
        
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    public func makeUIView(context: Context) -> MTKView {
        
        let metalView = context.coordinator.metalView
        metalView.device = self.metalDevice
        metalView.delegate = self.renderer
        metalView.apply(context.environment)
        
        context.coordinator.setNeedsDisplayTrigger = context.environment.setNeedsDisplayTrigger
        
        return metalView
    }
    
    public func updateUIView(_ uiView: MTKView, context: Context) {
        
        context.coordinator.metalView.apply(context.environment)
        context.coordinator.setNeedsDisplayTrigger = context.environment.setNeedsDisplayTrigger
        
    }
    
    public class Coordinator {
        
        private var cancellable: AnyCancellable?
        
        public var metalView: MTKView = {
            MTKView(frame: .zero)
        }()
        
        public var setNeedsDisplayTrigger: AnyPublisher<Void, Never>? {
            
            didSet {
                
                self.cancellable = self.setNeedsDisplayTrigger?.receive(on: DispatchQueue.main).sink { [weak self] in
                    
                    guard let self = self,
                          self.metalView.isPaused,
                          self.metalView.enableSetNeedsDisplay
                    else { return }
                    
                    self.metalView.setNeedsDisplay()
                    
                }
                
            }
            
        }
        
        public init() {
            
            self.cancellable = nil
            self.setNeedsDisplayTrigger = nil
            
        }
        
    }
    
}
