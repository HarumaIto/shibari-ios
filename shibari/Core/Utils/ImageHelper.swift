import SwiftUI

final class ImageHelper {
    static func compressImage(image: UIImage, maxSize: CGFloat, quality: CGFloat) -> Data? {
        let size = image.size
        let ratio = min(maxSize / size.width, maxSize / size.height)
        
        // すでに指定サイズより小さい場合は、リサイズせずJPEG圧縮のみ行う
        if ratio >= 1.0 {
            return image.jpegData(compressionQuality: quality)
        }
        
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0 // スケールを1に固定し、Retinaディスプレイによる意図しないファイル肥大化を防ぐ
        
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        
        return resizedImage.jpegData(compressionQuality: quality)
    }
}
