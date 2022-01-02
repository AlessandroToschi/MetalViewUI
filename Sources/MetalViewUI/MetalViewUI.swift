import SwiftUI
import MetalKit

struct MetalView: UIViewRepresentable {

    typealias UIViewType = MTKView
    
    let device: MTLDevice?
    let delegate: MTKViewDelegate?
    
    func makeUIView(context: Context) -> MTKView {
        let metalView = MTKView(frame: .zero, device: self.device)
        metalView.delegate = self.delegate
        metalView.apply(context.environment)
        return metalView
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {
        uiView.apply(context.environment)
    }
    
}
