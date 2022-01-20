//
//  File.swift
//  
//
//  Created by Alessandro Toschi on 02/01/22.
//

import SwiftUI
import MetalKit

extension MTKView {
    
    @discardableResult
    func apply(_ environment: EnvironmentValues) -> Self {

        self.colorPixelFormat = environment.colorPixelFormat
        self.framebufferOnly = environment.framebufferOnly
        if let drawableSize = environment.drawableSize {
            self.drawableSize = drawableSize
        }
        self.autoResizeDrawable = environment.autoResizeDrawable
        self.clearColor = environment.clearColor
        self.preferredFramesPerSecond = environment.preferredFramesPerSecond
        self.enableSetNeedsDisplay = environment.enableSetNeedsDisplay
        self.isPaused = environment.isPaused
        self.presentsWithTransaction = environment.presentWithTransaction
        return self
        
    }
    
}
