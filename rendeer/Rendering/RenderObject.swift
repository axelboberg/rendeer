//
//  RenderObject.swift
//  Rendeer
//
//  Created by Axel Boberg on 2021-05-02.
//

import Foundation
import MetalKit

protocol RenderObject {
    /**
     Get the current frame from the
     object for rendering in the output
     */
    func frame (_ texture: inout MTLTexture, device: MTLDevice) -> MTLTexture
}
