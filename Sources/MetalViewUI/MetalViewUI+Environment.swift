//
//  File.swift
//  
//
//  Created by Alessandro Toschi on 02/01/22.
//

import SwiftUI
import MetalKit
import Combine

private struct ColorPixelFormatKey: EnvironmentKey {
    static let defaultValue: MTLPixelFormat = .bgra8Unorm
}

private struct FramebufferOnlyKey: EnvironmentKey {
    static let defaultValue: Bool = true
}

private struct DrawableSizeKey: EnvironmentKey {
    static var defaultValue: CGSize? = nil
}

private struct AutoResizeDrawableKey: EnvironmentKey {
    static var defaultValue: Bool = true
}

private struct ClearColorKey: EnvironmentKey {
    static var defaultValue: MTLClearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
}

private struct PreferredFramesPerSecondKey: EnvironmentKey {
    static var defaultValue: Int = 60
}

private struct IsPausedKey: EnvironmentKey {
    static var defaultValue: Bool = false
}

private struct EnableSetNeedsDisplayKey: EnvironmentKey {
    static var defaultValue: Bool = false
}

private struct PresentWithTransactionKey: EnvironmentKey {
    static var defaultValue: Bool = false
}

private struct SetNeedsDisplayTriggerKey: EnvironmentKey {
    static var defaultValue: AnyPublisher<Void, Never>? = nil
}

extension EnvironmentValues {
    
    var colorPixelFormat: MTLPixelFormat {
        get { self[ColorPixelFormatKey.self] }
        set { self[ColorPixelFormatKey.self] = newValue }
    }
    
    var framebufferOnly: Bool {
        get { self[FramebufferOnlyKey.self] }
        set { self[FramebufferOnlyKey.self] = newValue }
    }
    
    var drawableSize: CGSize? {
        get { self[DrawableSizeKey.self] }
        set { self[DrawableSizeKey.self] = newValue }
    }
    
    var autoResizeDrawable: Bool {
        get { self[AutoResizeDrawableKey.self] }
        set { self[AutoResizeDrawableKey.self] = newValue }
    }
    
    var clearColor: MTLClearColor {
        get { self[ClearColorKey.self] }
        set { self[ClearColorKey.self] = newValue }
    }
    
    var preferredFramesPerSecond: Int {
        get { self[PreferredFramesPerSecondKey.self] }
        set { self[PreferredFramesPerSecondKey.self] = newValue }
    }
    
    var enableSetNeedsDisplay: Bool {
        get { self[EnableSetNeedsDisplayKey.self] }
        set { self[EnableSetNeedsDisplayKey.self] = newValue }
    }
    
    var isPaused: Bool {
        get { self[IsPausedKey.self] }
        set { self[IsPausedKey.self] = newValue }
    }
    
    var presentWithTransaction: Bool {
        get { self[PresentWithTransactionKey.self] }
        set { self[PresentWithTransactionKey.self] = newValue }
    }
    
    var setNeedsDisplayTrigger: AnyPublisher<Void, Never>? {
        get { self[SetNeedsDisplayTriggerKey.self] }
        set { self[SetNeedsDisplayTriggerKey.self] = newValue }
    }
    
}

public extension View {
    
    func colorPixelFormat(_ value: MTLPixelFormat) -> some View {
        self.environment(\.colorPixelFormat, value)
    }

    func framebufferOnly(_ value: Bool) -> some View {
        self.environment(\.framebufferOnly, value)
    }

    func drawableSize(_ value: CGSize?) -> some View {
        self.environment(\.drawableSize, value)
    }

    func autoResizeDrawable(_ value: Bool) -> some View {
        self.environment(\.autoResizeDrawable, value)
    }

    func clearColor(_ value: MTLClearColor) -> some View {
        self.environment(\.clearColor, value)
    }

    func preferredFramesPerSecond(_ value: Int) -> some View {
        self.environment(\.preferredFramesPerSecond, value)
    }

    func isPaused(_ value: Bool) -> some View {
        self.environment(\.isPaused, value)
    }

    func enableSetNeedsDisplay(_ value: Bool) -> some View {
        self.environment(\.enableSetNeedsDisplay, value)
    }

    func presentWithTransaction(_ value: Bool) -> some View {
        self.environment(\.presentWithTransaction, value)
    }
    
    func setNeedsDisplayTrigger(_ value: AnyPublisher<Void, Never>) -> some View {
        self.environment(\.setNeedsDisplayTrigger, value)
    }
    
    @ViewBuilder
    func drawingMode(_ value: MetalView.DrawingMode) -> some View {
        
        switch value {
                
            case .timeUpdates(let preferredFramesPerSecond):
                self.isPaused(false).enableSetNeedsDisplay(false).preferredFramesPerSecond(preferredFramesPerSecond)
                
            case .drawNotifications(let setNeedsDisplayTrigger):
                self.isPaused(true).enableSetNeedsDisplay(true).setNeedsDisplayTrigger(setNeedsDisplayTrigger)
                
            case .explicitDrawing:
                self.isPaused(true).enableSetNeedsDisplay(false)
                
        }
        
    }
    
}
