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
        self.drawableSize = environment.drawableSize
        self.autoResizeDrawable = environment.autoResizeDrawable
        self.clearColor = environment.clearColor
        self.preferredFramesPerSecond = environment.preferredFramesPerSecond
        self.enableSetNeedsDisplay = environment.enableSetNeedsDisplay
        self.isPaused = environment.isPaused
        self.presentsWithTransaction = environment.presentWithTransaction
        
        if self.enableSetNeedsDisplay && self.isPaused {
            self.setNeedsDisplay()
        }

        return self
        
    }
    
}
