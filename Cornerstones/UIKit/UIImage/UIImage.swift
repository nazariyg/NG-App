// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import UIKit

// MARK: - Image transformations

public extension UIImage {

    convenience init?(contentsOf url: URL) {
        guard let data = try? Data(contentsOf: url) else { return nil }
        self.init(data: data)
    }

    func tinted(withColor color: UIColor) -> UIImage {
        let image = withRenderingMode(.alwaysTemplate)

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }

        color.set()
        image.draw(in: size.rect)
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else {
            assertionFailure()
            return self
        }

        return newImage
    }

    static func pixelImage(withColor color: UIColor) -> UIImage {
        let pixelImage = solidImage(withColor: color, size: CGSize(width: 1, height: 1))
        return pixelImage
    }

    static func solidImage(withColor color: UIColor, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, color.alphaComponent == 1, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }

        guard let context = UIGraphicsGetCurrentContext() else {
            assertionFailure()
            return UIImage()
        }
        context.setFillColor(color.cgColor)
        context.fill(size.rect)

        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            assertionFailure()
            return UIImage()
        }
        return image
    }

    func croppedImage(inRect cropRect: CGRect) -> UIImage {
        let scaledCropRect =
            CGRect(
                x: cropRect.origin.x*scale,
                y: cropRect.origin.y*scale,
                width: cropRect.size.width*scale,
                height: cropRect.size.height*scale)
        if let cgCroppedImage = cgImage?.cropping(to: scaledCropRect) {
            let croppedImage = UIImage(cgImage: cgCroppedImage, scale: scale, orientation: imageOrientation)
            return croppedImage
        } else {
            assertionFailure()
            return self
        }
    }

    /// Resizes the image to a new size using the highest interpolation quality and keeping the rendering mode intact.
    func resized(newSize: CGSize, interpolationQuality: CGInterpolationQuality = .high) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
        defer { UIGraphicsEndImageContext() }

        guard let context = UIGraphicsGetCurrentContext() else {
            assertionFailure()
            return self
        }
        context.interpolationQuality = interpolationQuality

        draw(in: CGRect(origin: .zero, size: CGSize(width: newSize.width, height: newSize.height)))
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else {
            assertionFailure()
            return self
        }

        if renderingMode == .automatic {
            return newImage
        } else {
            return newImage.withRenderingMode(renderingMode)
        }
    }

    func resizedWithAspect(resizeScale: CGFloat, interpolationQuality: CGInterpolationQuality = .high) -> UIImage {
        let newSize = CGSize(width: size.width*resizeScale, height: size.height*resizeScale)
        return resized(newSize: newSize, interpolationQuality: interpolationQuality)
    }

    func resizedWithAspect(newWidth: CGFloat, interpolationQuality: CGInterpolationQuality = .high) -> UIImage {
        let resizeScale = newWidth/size.width
        let newHeight = size.height*resizeScale
        let newSize = CGSize(width: newWidth, height: newHeight)
        return resized(newSize: newSize, interpolationQuality: interpolationQuality)
    }

    func resizedWithAspect(newHeight: CGFloat, interpolationQuality: CGInterpolationQuality = .high) -> UIImage {
        let resizeScale = newHeight/size.height
        let newWidth = size.width*resizeScale
        let newSize = CGSize(width: newWidth, height: newHeight)
        return resized(newSize: newSize, interpolationQuality: interpolationQuality)
    }

    func withLargerCanvas(canvasSize: CGSize, newAreaColor: UIColor) -> UIImage {
        assert(canvasSize.width >= size.width && canvasSize.height >= size.height)
        guard !(canvasSize.width == size.width && canvasSize.height == size.height) else { return self }

        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }

        newAreaColor.setFill()
        UIRectFill(canvasSize.rect)

        guard let context = UIGraphicsGetCurrentContext() else {
            assertionFailure()
            return self
        }
        let centeredImageRect =
            CGRect(
                x: (canvasSize.width - size.width)/2,
                y: (canvasSize.height - size.height)/2,
                width: size.width,
                height: size.height)
        context.clear(centeredImageRect)
        draw(in: centeredImageRect)

        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            assertionFailure()
            return self
        }
        return image
    }

    func normalized() -> UIImage {
        guard imageOrientation != .up else { return self }

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }

        draw(in: size.rect)

        guard let normalizedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            assertionFailure()
            return self
        }
        return normalizedImage
    }

}
