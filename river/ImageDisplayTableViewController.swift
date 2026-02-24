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
        if page < tableView(tableView, numberOfRowsInSection: 0) {
            tableView.scrollToRow(at: IndexPath(row: page, section: 0), at: .bottom, animated: animated)
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
            return 0
        }
        return image.size.height * tableView.frame.width / image.size.width
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pages.count
    }
}

