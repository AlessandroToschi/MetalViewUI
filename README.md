# MetalViewUI

`MetalView` is a `SwiftUI`  view wrapper over a `MTKView`.
This package allows users to draw in a `MTKView` natively in SwiftUI, by exposing the two callbacks of `MTKViewDelegate`.
Both callbacks are optional and a default render is provided to display the `clearColor`.

The `MetalView` exposes the following view modifiers that are directly mapped to the `MTKView` properties:

- `colorPixelFormat`
- `framebufferOnly`
- `drawableSize`
- `autoResizeDrawable`
- `clearColor`
- `preferredFramesPerSecond`
- `isPaused`
- `enableSetNeedsDisplay`
- `presentWithTransaction`

All these properties uses the same default values as defined in the `MTKView`.

## Drawing Modes

The `MetalView` supports two drawing modes:

- Time updates: the `MTKView` content is redrawn based on the internal timer, driven by `preferredFramesPerSecond` property.
- Draw notifications: the `MTKView` content is refreshed upon calling `setNeedsDisplay` like a traditional `UIView`.

The drawing mode can be configured by calling the `drawingMode` view modifiers.

The time updates mode requires to specify the `preferredFramesPerSecond`, whereas the draw notifications mode requires a publisher to trigger the redraw of the `MTKView` from the external.

## Installation

This package supports both Cocoapods and Swift Package Manager.

### Cocoapods

To import this package in a `Podfile` add the following line:
```
pod 'MetalViewUI', :git => 'https://github.com/AlessandroToschi/MetalViewUI.git'
```

### Swift Package Manager

`Xcode --> File --> Add packages...` and paste the following link: `https://github.com/AlessandroToschi/MetalViewUI`

or add the following line to `Project.swift`:

`.Package(url: "https://github.com/AlessandroToschi/MetalViewUI", branch: "main")`

## Demo

The `Demo` folder contains two pratical examples on how to use the `MetalView`:

- Background color: change the `clearColor` of the `MTKView` using the default `ColorPicker` and updates the content whenever a new color has been selected. The drawing mode is draw notification because the view needs to be redrawn only when the color change, and so an external trigger is used.

- Random color: change the `clearColor` of the `MTKView` according to a user configurable delay in seconds. The drawing mode is time updates since we need to change the color as time passes.
