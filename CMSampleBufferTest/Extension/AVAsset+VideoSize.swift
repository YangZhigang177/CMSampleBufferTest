
import Foundation
import AVFoundation

extension AVAsset {
    var videoSize: CGSize {
        tracks(withMediaType: .video).first?.naturalSize ?? .zero
    }
}
