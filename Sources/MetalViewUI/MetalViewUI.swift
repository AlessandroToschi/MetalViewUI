import SwiftUI
import MetalKit
import Combine

public struct MetalView: UIViewRepresentable {

    public typealias UIViewType = MTKView
    
    private let device: MTLDevice?
    private let delegate: MTKViewDelegate?
    private let setNeedsDisplayTrigger: AnyPublisher<Void, Never>?
    private var cancellables: NSMutableSet
    
    public init(device: MTLDevice?, delegate: MTKViewDelegate?, setNeedsDisplayTrigger: AnyPublisher<Void, Never>?) {
        self.device = device
        self.delegate = delegate
        self.setNeedsDisplayTrigger = setNeedsDisplayTrigger
        self.cancellables = NSMutableSet()
    }
    
    public func makeUIView(context: Context) -> MTKView {
        
        let metalView = MTKView(frame: .zero, device: self.device)
        metalView.delegate = self.delegate
        metalView.apply(context.environment)
        
        let cancellable = self.setNeedsDisplayTrigger?.sink { [weak metalView] in
            
            guard let metalView = metalView, metalView.enableSetNeedsDisplay, metalView.isPaused else { return }
            
            metalView.setNeedsDisplay()
            
        }
        
        if let cancellable = cancellable {
            self.cancellables.add(cancellable)
        }
        
        return metalView
    }
    
    public func updateUIView(_ uiView: MTKView, context: Context) {
        uiView.apply(context.environment)
    }
    
}
