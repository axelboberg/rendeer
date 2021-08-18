//
//  RenderView.swift
//  Rendeer
//
//  Created by Axel Boberg on 2021-05-02.
//

import AppKit
import MetalKit

protocol RenderViewDelegate: AnyObject {
    func renderView (willDraw: Bool)
}

class RenderView: MTKView, MTKViewDelegate {
    weak var renderDelegate: RenderViewDelegate?

    var queue: MTLCommandQueue?
    var texture: MTLTexture?
    var pipelineState: MTLRenderPipelineState?
    var mtkTextureLoader: MTKTextureLoader?
    var textureDescriptor: MTLTextureDescriptor?
    
    var backgroundImage: CGImage?
    
    deinit {
        self.delegate = nil
    }

    func setup () {
        self.clearColor = MTLClearColorMake(1, 0, 0, 1)
        
        if self.device == nil {
            guard let device = MTLCreateSystemDefaultDevice() else { return }
            self.device = device
        }
        
        self.delegate = self
        
        self.textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: 1920, height: 1080, mipmapped: false)
        self.texture = device?.makeTexture(descriptor: self.textureDescriptor!)
        
        let defaultLib = device?.makeDefaultLibrary()
        let vertexProgram = defaultLib?.makeFunction(name: "vertexShader")
        let fragmentProgram = defaultLib?.makeFunction(name: "fragmentShader")
        
        self.mtkTextureLoader = MTKTextureLoader(device: self.device!)
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexProgram
        pipelineDescriptor.fragmentFunction = fragmentProgram
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

        self.pipelineState = try! self.device!.makeRenderPipelineState(descriptor: pipelineDescriptor)
        
        self.queue = device?.makeCommandQueue()
    }
    
    func texturize () -> MTLTexture? {
        print("Texturize is not implemented")
        return nil
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        print("Drawable size will change")
    }
    
    private func getTexture () -> MTLTexture? {
        if self.backgroundImage == nil { return nil }
        return try! self.mtkTextureLoader?.newTexture(cgImage: self.backgroundImage!, options: nil)
    }
    
    func draw(in view: MTKView) {
        guard let onscreenCommandBuffer = self.queue?.makeCommandBuffer() else { return }
        
        self.renderDelegate?.renderView(willDraw: true)
        
        if let onscreenDescriptor = view.currentRenderPassDescriptor,
        let onscreenCommandEncoder = onscreenCommandBuffer.makeRenderCommandEncoder(descriptor: onscreenDescriptor) {
            /* Set render state and resources.
               ...
             */
            /* Issue draw calls.
               ...
             */
            if let texture = self.getTexture() {
//                onscreenCommandEncoder.setFragmentTexture(texture, index: 0)
//                onscreenCommandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4, instanceCount: 1)
            }

            onscreenCommandEncoder.endEncoding()
            // END encoding your onscreen render pass.
            
            // Register the drawable's presentation.
            if let currentDrawable = view.currentDrawable {
                onscreenCommandBuffer.present(currentDrawable)
            }
        }

        // Finalize your onscreen CPU work and commit the command buffer to a GPU.
        onscreenCommandBuffer.commit()
        
        
        
        
//        descriptor.colorAttachments[0].texture = drawable.texture
//        descriptor.colorAttachments[0].loadAction = .clear
//
//
//        guard let buf = self.queue?.makeCommandBuffer() else { return }
//        guard let encoder = buf.makeRenderCommandEncoder(descriptor: descriptor) else { return }
//
//        guard let state = self.pipelineState else { return }
//        encoder.setRenderPipelineState(state)
//
//        encoder.setFragmentTexture(texture, index: 0)
//        encoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4, instanceCount: 1)
//
//        encoder.endEncoding()
//        buf.present(self.mtlView.currentDrawable!)
//        buf.commit()
    }
    
    
}
