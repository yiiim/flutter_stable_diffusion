//
//  CoreMlStableDiffusionGenerateCancelToken.swift
//  flutter_stable_diffusion_core_ml
//
//  Created by ybz on 2023/9/3.
//

import platform_object_channel_foundation

@objc(CoreMlStableDiffusionGenerateCancelToken)
class CoreMlStableDiffusionGenerateCancelToken: NSObject, FoundationPlatformObject {
    required init(_ flutterArgs: Any?,_ messager: FoundationPlatformObjectMessenger) throws {
        
    }
    var isCancel = false
    var cancelCallbackBlock : (()->Void)?
    
    func handleFlutterMethodCall(_ method: String, _ arguments: Any?) async -> Any? {
        if method == "cancel" {
            self.isCancel = true
            return await withUnsafeContinuation({ continuation in
                let beforeCallbackBlock = self.cancelCallbackBlock
                self.cancelCallbackBlock = {
                    beforeCallbackBlock?()
                    continuation.resume(returning: nil)
                }
            })
        }
        return nil
    }
    
    func handleFlutterStreamMethodCall(_ method: String, _ arguments: Any?, _ sink: platform_object_channel_foundation.FoundationPlatformStreamMethodSink) {
        
    }
    
    func dispose() {
        
    }
    
    func generateDone() {
        if self.isCancel {
            self.cancelCallbackBlock?()
        }
    }
}
