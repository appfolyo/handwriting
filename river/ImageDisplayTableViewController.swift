//
//  ImageDisplayTableViewController.swift
//  river
//
//  Created by Dev on 2026.02.22.
//

import UIKit

class ImageDisplayTableViewController: UITableViewController {
    
    var assetURL: URL!
    var pages: [Page] = []
    var subscriptionTitle: String?
    var fileNames: [String] = []
    let acceptedFiletype = ".heic"

    var defaultsKey: String {
        "index_"+assetURL.lastPathComponent
    }

    func jump(to page: Int, animated: Bool = false) {
        var page = page
        if page >= tableView(tableView, numberOfRowsInSection: 0) {
            page = tableView(tableView, numberOfRowsInSection: 0) - 1
        }
        if page < 0 {
            page = 0
        }
        if page < tableView(tableView, numberOfRowsInSection: 0), page > 0 {
            tableView.scrollToRow(at: IndexPath(row: page, section: 0), at: .bottom, animated: animated)
        }
    }
    
    func loadFileNames(acceptedFiletype: String = ".heic") {
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: assetURL, includingPropertiesForKeys: [URLResourceKey.nameKey, URLResourceKey.isDirectoryKey], options: .skipsHiddenFiles)
            
            let titleName = "title"
            var hastitle: Bool = false
            
            for item in contents {
                let fileName = item.lastPathComponent
                if fileName.hasSuffix(acceptedFiletype) {
                    if fileName == titleName + acceptedFiletype {
                        hastitle = true
                    } else {
                        fileNames.append(String(fileName.dropLast(acceptedFiletype.count)))
                    }
                }
            }
            fileNames.sort(using: .localizedStandard)
            if hastitle {
                fileNames.insert(titleName, at: 0)
            }
        }
        catch let error as NSError {
            print(error)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let index = UserDefaults.standard.integer(forKey: defaultsKey)
        jump(to: index)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UserDefaults.standard.set(currentIndex, forKey: defaultsKey)
        
        super.viewWillDisappear(animated)
    }
    
    var currentIndex: Int? {
        tableView.indexPathsForVisibleRows?.first?.row
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = pages[indexPath.row].image else {
            return UITableView.automaticDimension
        }
        return image.size.height * tableView.bounds.width / image.size.width
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pages.count
    }
}

