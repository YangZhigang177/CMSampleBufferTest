
import SwiftUI
import AVFoundation

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
