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

enum UserInterfaceStyle: String {
    case light, dark, system
    
    var icon: UIImage {
        switch self {
        case .light:
            return .init(systemName: "sun.max")!
        case .dark:
            return .init(systemName: "moon")!
        case .system:
            return .init(systemName: "a.circle")!
        }
    }
    
    func toggle() -> UserInterfaceStyle {
        switch self {
        case .light:
            return .dark
        case .dark:
            return .system
        case .system:
            return .light
        }
    }
}

extension String {
    func toDateyyyyMMdd() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        formatter.locale = Locale(identifier: "en_US_POSIX")

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
            
            let interfaceStyle = UserDefaults.standard.string(forKey: "interfaceStyle") ?? defaultInterfaceStyle.rawValue
            if let style = UserInterfaceStyle(rawValue: interfaceStyle), style != .system {
                
                switch style {
                case .light:
                    super.image = newValue
                case .dark:
                    super.image = newValue?.inverseImage
                case .system:
                    fatalError("Can't access it.")
                }
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
