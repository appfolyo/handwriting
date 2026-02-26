//
//  Extensions.swift
//  river
//
//  Created by Dev on 2025.04.09.
//

import UIKit

extension UIImage {
    var inverseImage: UIImage? {
        let coreImage = UIKit.CIImage(image: self)
        guard let filter = CIFilter(name: "CIColorInvert") else { return nil }
        filter.setValue(coreImage, forKey: kCIInputImageKey)
        guard let inverted = filter.value(forKey: kCIOutputImageKey) as? UIKit.CIImage else { return nil }
        
        let result = inverted.applyingFilter("CIColorControls", parameters: [
            kCIInputImageKey: inverted,
            kCIInputSaturationKey: 1.0,
            kCIInputBrightnessKey: 0.0,
            kCIInputContrastKey: 100.0
        ])
        return UIImage(ciImage: result)
    }
    
}

extension UIWindow {
    static var main: UIWindow? {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            return windowScene.windows.first
        }
        return nil
    }
}

extension UIUserInterfaceStyle {
    
    var icon: UIImage {
        switch self {
        case .light:
            return .init(systemName: "sun.max")!
        case .dark:
            return .init(systemName: "moon")!
        case .unspecified:
            return .init(systemName: "a.circle")!
        @unknown default:
            return UIUserInterfaceStyle.unspecified.icon
        }
    }
    
    var userDefaultsString: String {
        switch self {
        case .light:
            return "light"
        case .dark:
            return "dark"
        case .unspecified:
            return "system"
        @unknown default:
            return "system"
        }
    }
    
    static func fromUserDefaultsString(_ string: String?) -> UIUserInterfaceStyle {
        switch string {
        case "light":
            return .light
        case "dark":
            return .dark
        case "system":
            return .unspecified
        default:
            return .light
        }
    }
    
    func toggle() -> UIUserInterfaceStyle {
        switch self {
        case .light:
            return .dark
        case .dark:
            return .unspecified
        case .unspecified:
            return .light
        @unknown default:
            return .unspecified
        }
    }
    
}

extension String {
    
    var dateFormat: String { "yyyyMMdd" }
    
    func toDateyyyyMMdd() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat

        return formatter.date(from: self.trimmingCharacters(in: .whitespaces)) 
    }
}

class AutoInvertImageView: UIImageView {
    
    var isInvertable: Bool = true
    
    override var image: UIImage? {
        get {
            return super.image
        }
        set {
            guard isInvertable else {
                super.image = newValue
                return
            }
            
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first as? UIWindowScene
            let window = windowScene?.windows.first
            if window?.traitCollection.userInterfaceStyle == .dark {
                super.image = newValue?.inverseImage
            } else {
                super.image = newValue
            }
        }
    }
}

extension String {
    var decodingUnicodeCharacters: String { applyingTransform(.init("Hex-Any"), reverse: false) ?? "" }
}
