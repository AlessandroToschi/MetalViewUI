import SwiftUI
import MetalKit
import Combine

#if os(macOS)
typealias XXViewRepresentable = NSViewRepresentable
#else
typealias XXViewRepresentable = UIViewRepresentable
#endif

public struct MetalViewUI: XXViewRepresentable {
#if os(macOS)
    public typealias NSViewType = MTKView
#else
    public typealias UIViewType = MTKView
#endif

    public typealias SetNeedsDisplayTrigger = AnyPublisher<Void, Never>

    public enum DrawingMode {
        
        case timeUpdates(preferredFramesPerSecond: Int)
        case drawNotifications(setNeedsDisplayTrigger: SetNeedsDisplayTrigger?)
        
    }

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
    
#if os(macOS)
    public func makeNSView(context: Context) -> MTKView {
        makeUIView(context: context)
    }
#endif
    
    public func updateUIView(_ uiView: MTKView, context: Context) {
        
        context.coordinator.metalView.apply(context.environment)
        context.coordinator.setNeedsDisplayTrigger = context.environment.setNeedsDisplayTrigger
        print("UPDATE VIEW")
    }
    
#if os(macOS)
    public func updateNSView(_ nsView: MTKView, context: Context) {
        updateUIView(nsView, context: context)
    }
#endif
    
    public class Coordinator {
        
        private var cancellable: AnyCancellable?
        
        public var metalView: MTKView = {
            MTKView(frame: .zero)
        }()
        
        public var setNeedsDisplayTrigger: SetNeedsDisplayTrigger? {
            
            didSet {
                
                self.cancellable = self.setNeedsDisplayTrigger?.receive(on: DispatchQueue.main).sink { [weak self] in
                    
                    guard let self = self,
                          self.metalView.isPaused,
                          self.metalView.enableSetNeedsDisplay
                    else { return }
                    
#if os(macOS)
                    self.metalView.setNeedsDisplay(self.metalView.bounds)
#else
                    self.metalView.setNeedsDisplay()
#endif
                    
                }
                
            }
            
        }
        
        public init() {
            
            self.cancellable = nil
            self.setNeedsDisplayTrigger = nil
            
        }
        
    }
    
}
