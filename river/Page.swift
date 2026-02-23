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
    var invertable: Bool = true
    
    var lastVisitedKey: String {
        guard let assetURL else {
            return ""
        }
        return "last_visited_" + assetURL.lastPathComponent
    }
    
    var isNew: Bool {
        guard let lastUpdated = lastUpdated else {
            return false
        }
        let lastVisited = UserDefaults.standard.object(forKey: lastVisitedKey) as? Date
        return lastUpdated > lastVisited ?? .distantPast

    }
    
    enum ContentType: String {
        case bundle, pages, epub, url
    }
    var contentType: ContentType = .pages
    
}
