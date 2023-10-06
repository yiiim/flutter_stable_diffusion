//
//  FlutterStableDiffusionPipeline.swift
//  flutter_stable_diffusion_core_ml
//
//  Created by ybz on 2023/9/2.
//

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#else
  #error("Unsupported platform.")
#endif

import CoreML
import ImageIO
import UniformTypeIdentifiers
import platform_object_channel_foundation

enum CoreMlStableDiffusionPipelineError : Error {
    case GenerateParamsError(message : String)
    case CreateStableDiffusionPipelineError(message : String)
}

struct FlutterStableDiffusionPipelineGenerateParams {
    init(_ flutterArgs: Any?) throws {
        guard let args = flutterArgs as? [String:Any],
              let prompt = args["prompt"] as? String,
              let negativePrompt = args["negativePrompt"] as? String,
              let stepCount = args["stepCount"] as? Int
        else{
            throw CoreMlStableDiffusionPipelineError.GenerateParamsError(message: "参数错误")
        }
        let seed = args["seed"] as? UInt32
        let guidanceScale = args["guidanceScale"] as? Float
        let disableSafety = args["disableSafety"] as? Bool
        
        let cancelToken = args["cancelToken"] as? CoreMlStableDiffusionGenerateCancelToken
        self.prompt = prompt
        self.negativePrompt = negativePrompt
        self.scheduler = .dpmSolverMultistepScheduler
        self.stepCount = stepCount
        self.seed = seed ?? 0
        self.guidanceScale = guidanceScale ?? 7.5
        self.disableSafety = disableSafety ?? false
        self.cancelToken = cancelToken
    }
    let prompt : String
    let negativePrompt : String
    let scheduler : StableDiffusionScheduler
    let stepCount : Int
    let seed : UInt32
    let guidanceScale : Float
    let disableSafety : Bool
    let cancelToken : CoreMlStableDiffusionGenerateCancelToken?
}

@objc(CoreMlStableDiffusionPipeline)
class CoreMlStableDiffusionPipeline : NSObject, FoundationPlatformObject {
    required init(_ flutterArgs: Any?, _ messager: FoundationPlatformObjectMessenger) throws{
        guard let args = flutterArgs as? [String:Any] else {
            throw CoreMlStableDiffusionPipelineError.CreateStableDiffusionPipelineError(message: "create stable diffusion fail, args is not map")
        }
        guard let modelPath = args["modelPath"] as? String else {
            throw CoreMlStableDiffusionPipelineError.CreateStableDiffusionPipelineError(message: "create stable diffusion fail, modelPath is not string")
        }
        let modelPathUrl = URL.init(filePath: modelPath)
        let configuration = MLModelConfiguration()
        configuration.computeUnits = .cpuAndGPU
        self.pipeline = try StableDiffusionPipeline(
            resourcesAt: modelPathUrl,
            controlNet: [],
            configuration: configuration,
            disableSafety: false,
            reduceMemory: true
        )
    }
    
    let pipeline : StableDiffusionPipeline
    
    func handleFlutterMethodCall(_ method: String, _ arguments: Any?) async -> Any? {
        do {
            switch method {
            case "loadResources":
                try loadResources()
                return 0
            default:
                return -1
            }
        } catch {
            return -1
        }
    }
    
    func handleFlutterStreamMethodCall(_ method: String, _ arguments: Any?, _ sink: FoundationPlatformStreamMethodSink) {
        if method == "generate" {
            OperationQueue().addOperation {
                do {
                    let params = try FlutterStableDiffusionPipelineGenerateParams(arguments)
                    defer {
                        params.cancelToken?.generateDone()
                    }
                    let theSeed = params.seed > 0 ? params.seed : UInt32.random(in: 1...100)
                    var config = StableDiffusionPipeline.Configuration(prompt: params.prompt)
                    config.negativePrompt = params.negativePrompt
                    config.stepCount = params.stepCount
                    config.seed = theSeed
                    config.guidanceScale = params.guidanceScale
                    config.disableSafety = params.disableSafety
                    config.schedulerType = params.scheduler
                    config.useDenoisedIntermediates = true
                    let images = try self.pipeline.generateImages(configuration: config) { progress in
                        let currentImages = progress.currentImages.map({ item in
                            if let image = item {
                                return self.convertCGImageToData(cgImage: image)
                            }
                            return nil
                        })
                        sink.add([
                            "event": "progress",
                            "step": progress.step,
                            "stepCount": progress.stepCount,
                            "currentImages": currentImages
                        ] as [String : Any])
                        return !(params.cancelToken?.isCancel == true)
                    }
                    if params.cancelToken?.isCancel == true {
                        sink.add(["event": "done", "isCancel": true] as [String : Any])
                        sink.done()
                    }else{
                        if let image = images.compactMap({ $0 }).first,
                           let imageData = self.convertCGImageToData(cgImage: image) {
                            sink.add(["event": "done", "image": imageData] as [String : Any])
                            sink.done()
                        } else {
                            sink.error("fail")
                        }
                    }
                } catch CoreMlStableDiffusionPipelineError.GenerateParamsError(let message) {
                    sink.error(message)
                } catch {
                    sink.error("\(error)")
                }
            }
        }
    }
    func unloadResources() throws {
        try pipeline.loadResources()
    }
    func loadResources() throws {
        try pipeline.loadResources()
    }
    func dispose() {
        try? self.unloadResources()
    }
    
    private func convertCGImageToData(cgImage: CGImage) -> Data? {
        let data = CFDataCreateMutable(nil, 0)
        guard let imageDestination = CGImageDestinationCreateWithData(data! , UTType.png.identifier as CFString, 1, nil) else {
            return nil
        }
        CGImageDestinationAddImage(imageDestination, cgImage, nil)
        CGImageDestinationFinalize(imageDestination)
        
        return data as Data?
    }
}

