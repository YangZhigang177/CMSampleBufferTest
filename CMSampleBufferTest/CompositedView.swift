
import SwiftUI
import AVFoundation

struct CompositedView: UIViewRepresentable {
    @Binding var videoLayer: AVPlayerLayer
    var videoName: String
    var geometry: GeometryProxy
    
    init(videoLayer: Binding<AVPlayerLayer>, videoName: String, geometry: GeometryProxy) {
        self._videoLayer = videoLayer
        self.videoName = videoName
        self.geometry = geometry
    }
    
    func createTransparentItem(asset: AVAsset) -> AVPlayerItem {
        let playerItem = AVPlayerItem(asset: asset)
        // Set the video so that seeking also renders with transparency
        playerItem.seekingWaitsForVideoCompositionRendering = true
        // Apply a video composition (which applies our custom filter)
        playerItem.videoComposition = createVideoComposition(for: asset)
        return playerItem
    }

    func createVideoComposition(for asset: AVAsset) -> AVVideoComposition {
        let filter = AlphaFrameFilter(renderingMode: .builtInFilter)
        let composition = AVMutableVideoComposition(asset: asset, applyingCIFiltersWithHandler: { request in
            do {
                let (inputImage, maskImage) = request.sourceImage.verticalSplit()
                let outputImage = try filter.process(inputImage, mask: maskImage)
                return request.finish(with: outputImage, context: nil)
            } catch {
                print("Video composition error: %s", String(describing: error))
                return request.finish(with: error)
            }
        })

        composition.renderSize = asset.videoSize.applying(CGAffineTransform(scaleX: 1.0, y: 0.5))
        return composition
    }
   
    func makeUIView(context: Context)  -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: geometry.size.width, height: 300))
        
        guard let path = Bundle.main.url(forResource: videoName, withExtension: "mp4") else {return view}
        let asset = AVAsset(url: path)
        let playerItem = createTransparentItem(asset: asset)
        let player = AVPlayer(playerItem: playerItem)
        videoLayer.player = player
        videoLayer.frame = view.layer.bounds
        videoLayer.backgroundColor = CGColor(red:0.8, green: 0.8, blue: 0.8, alpha: 1)
        videoLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        
        view.layer.insertSublayer(videoLayer, at: 0)
        
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
    
}
