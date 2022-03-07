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
    @State var videoLayer = AVPlayerLayer()
    @State var sampleData:[CMSampleBuffer] = []

    var body: some View {
        GeometryReader{ geometry in
            ZStack {
                VStack {
                    DisplayView(displayLayer: $displayLayer, geometry: geometry)
                        .onAppear {

                            DispatchQueue.global().async {
                                self.decodeVideo()
                            }

                        }
                    
                    Spacer()
                    
                    CompositedView(videoLayer: $videoLayer, videoName: "semi_sphere", geometry: geometry)
                        .onAppear {
                            self.videoLayer.player?.play()
                        }

                }

                Button {
                    DispatchQueue.global().async {
                        self.videoLayer.player?.seek(to: .zero)
                        self.videoLayer.player?.play()
                    }
                } label: {
                    Text("Show Video")
                }
            }
        }

    }
    
    func enqueueData() {
        let index = Int.random(in: 0...self.sampleData.count)
        self.displayLayer.enqueue(self.sampleData[index])
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
//                self.sampleData.append(sample!)
                sample = readerOutput.copyNextSampleBuffer()
            }
        }

        let t = CFAbsoluteTimeGetCurrent()
        print("extract time: \(t-s)")
        
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




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
