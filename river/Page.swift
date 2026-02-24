//
//  Page.swift
//  river
//
//  Created by Dev on 2026.02.23.
//

import UIKit

class Page {
    var code: String?
    var image: UIImage?
    var assetURL: URL?
    var title: String?
    var lastUpdated: Date?
    var isInvertable: Bool = true
    
    var lastDisplayedKey: String {
        guard let assetURL else {
            return ""
        }
        return "last_displayed_" + assetURL.lastPathComponent
    }
    
    var isNew: Bool {
        guard let lastUpdated = lastUpdated else {
            return false
        }
        let lastVisited = UserDefaults.standard.object(forKey: lastDisplayedKey) as? Date
        return lastUpdated > lastVisited ?? .distantPast

    }
    
    enum ContentType: String {
        case bundle, pages, epub, url
    }
    var contentType: ContentType = .pages
    
    enum PageType {
        case normal, empty, subscription
    }
    var pageType: PageType = .normal
    
    static var empty: Page {
        var clearImageSize = UIScreen.main.bounds.size
        clearImageSize.height *= 0.5
        let clearImage = UIColor.clear.image(clearImageSize)
        let emptyPage = Page()
        emptyPage.image = clearImage
        return emptyPage
    }
    
}
