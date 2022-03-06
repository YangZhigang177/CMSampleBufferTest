//
//  ContentView.swift
//  CMSampleBufferTest
//
//  Created by 杨志刚 on 2022/3/4.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    
    @State var displayLayer = AVSampleBufferDisplayLayer()
    
    var body: some View {
        GeometryReader{ geometry in
            
            ZStack {
                DisplayView(displayLayer: $displayLayer, geometry: geometry)
                    
                
                
                Button {
                    DispatchQueue.global().async {
                        self.decodeVideo()
                    }
                } label: {
                    Text("Show Video")
                }

            }
            
        }

    }
    
    func decodeVideo() {
        
        guard let path = Bundle.main.url(forResource: "semi_sphere", withExtension: "mp4") else {return}
        
        
        let optDict = NSDictionary(object: NSNumber(value: false), forKey: AVURLAssetPreferPreciseDurationAndTimingKey as NSCopying)
        let asset = AVURLAsset(url: path, options: optDict as? [String : Any])
        
        let reader = try! AVAssetReader.init(asset: asset)

        let videoTrack = asset.tracks(withMediaType: .video).first
        
        //kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
        let readerOutputSetting: [String: Int] = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)
        ]
        let readerOutput = AVAssetReaderTrackOutput(track: videoTrack!, outputSettings: readerOutputSetting)
        reader.add(readerOutput)
        reader.startReading()
        
        var sample: CMSampleBuffer?
        sample = readerOutput.copyNextSampleBuffer()

        let s = CFAbsoluteTimeGetCurrent()
        while(sample != nil ){
            autoreleasepool {
                self.setSampleBufferAttachments(sample!)
                self.displayLayer.enqueue(sample!)
                sample = readerOutput.copyNextSampleBuffer()
            }
        }

        let t = CFAbsoluteTimeGetCurrent()
        print("time: \(t-s)")
        
    }
    
    func setSampleBufferAttachments(_ sampleBuffer: CMSampleBuffer) {
        let attachments: CFArray! = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, createIfNecessary: true)
        let dictionary = unsafeBitCast(CFArrayGetValueAtIndex(attachments, 0),
            to: CFMutableDictionary.self)
        let key = Unmanaged.passUnretained(kCMSampleAttachmentKey_DisplayImmediately).toOpaque()
        let value = Unmanaged.passUnretained(kCFBooleanTrue).toOpaque()
        CFDictionarySetValue(dictionary, key, value)
    }
}


struct DisplayView: UIViewRepresentable {
    @Binding var displayLayer: AVSampleBufferDisplayLayer
    var geometry: GeometryProxy
    
    init(displayLayer: Binding<AVSampleBufferDisplayLayer>, geometry: GeometryProxy) {
        self._displayLayer = displayLayer
        self.geometry = geometry
    }
   
    func makeUIView(context: Context)  -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: geometry.size.width, height: 300))
        displayLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        displayLayer.frame = view.layer.bounds
        print(displayLayer.frame)
        displayLayer.backgroundColor = CGColor(red:0.8, green: 0.8, blue: 0.8, alpha: 1)
        
        let _CMTimebasePointer = UnsafeMutablePointer<CMTimebase?>.allocate(capacity: 1)
        let status = CMTimebaseCreateWithSourceClock( allocator: kCFAllocatorDefault, sourceClock: CMClockGetHostTimeClock(),  timebaseOut: _CMTimebasePointer )
        displayLayer.controlTimebase = _CMTimebasePointer.pointee

        if let controlTimeBase = displayLayer.controlTimebase, status == noErr {
            CMTimebaseSetTime(controlTimeBase, time: CMTime.zero);
            CMTimebaseSetRate(controlTimeBase, rate: 1.0);
        }
        
        view.layer.insertSublayer(displayLayer, at: 0)
        
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
    }
    



    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
