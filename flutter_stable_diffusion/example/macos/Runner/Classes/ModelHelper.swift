//
//  ModelHelper.swift
//  Runner
//
//  Created by ybz on 2023/9/20.
//


import platform_object_channel_foundation

@objc(ModelHelper)
class ModelHelper: NSObject, FoundationPlatformObject {
    required init(_ flutterArgs: Any?, _ messager: platform_object_channel_foundation.FoundationPlatformObjectMessenger) throws {
        
    }
    
    func handleFlutterMethodCall(_ method: String, _ arguments: Any?) async -> Any? {
        if method == "getModels" {
            return ModelInfo.MODELS.map({ info in
                return [
                    "id":info.modelId,
                    "url": info.modelURL(for: ModelInfo.defaultAttention).absoluteString,
                    "defaultComputeUnits":info.defaultComputeUnits.rawValue,
                    "reduceMemory":info.reduceMemory
                ] as [String : Any]
            })
        }
        return nil
    }
    
    func handleFlutterStreamMethodCall(_ method: String, _ arguments: Any?, _ sink: platform_object_channel_foundation.FoundationPlatformStreamMethodSink) {
        
    }
    
    func dispose() {
        
    }
    
}
