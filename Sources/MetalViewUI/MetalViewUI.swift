import SwiftUI
import MetalKit

public struct MetalView: UIViewRepresentable {

    public typealias UIViewType = MTKView
    
    let device: MTLDevice?
    let delegate: MTKViewDelegate?
    
    public init(device: MTLDevice?, delegate: MTKViewDelegate?) {
        self.device = device
        self.delegate = delegate
    }
    
    public func makeUIView(context: Context) -> MTKView {
        let metalView = MTKView(frame: .zero, device: self.device)
        metalView.delegate = self.delegate
        metalView.apply(context.environment)
        return metalView
    }
    
    public func updateUIView(_ uiView: MTKView, context: Context) {
        uiView.apply(context.environment)
    }
    
}
