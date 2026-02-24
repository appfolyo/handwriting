//
//  ContentTableViewController.swift
//  river
//
//  Created by Dev on 2024.10.02.
//

import UIKit
import StoreKit

class ContentTableViewController: ImageDisplayTableViewController {
        
    let pageCounterButton = UIButton(type: .custom)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: assetURL, includingPropertiesForKeys: [URLResourceKey.nameKey, URLResourceKey.isDirectoryKey], options: .skipsHiddenFiles)
            
            var fileNames: [String] = []
            let acceptedFiletype = ".heic"
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
            
            fileNames.forEach { fileName in
                let imageURL = assetURL.appendingPathComponent(fileName + acceptedFiletype)
                let page = Page()
                page.image = UIImage(contentsOfFile: imageURL.path)!
                page.isInvertable = !fileName.contains("no-invert")
                let lastUpdatedString = "lastupdated"
                if fileName.contains(lastUpdatedString) {
                    let fileNameComponents = fileName.components(separatedBy: "-")
                    if let lastUpdatedIndex = fileNameComponents.firstIndex(where: { $0.hasSuffix(lastUpdatedString) }),
                       fileNameComponents.count > lastUpdatedIndex {
                        pages.forEach({ $0.lastUpdated = nil })
                        page.lastUpdated = fileNameComponents[lastUpdatedIndex + 1].toDateyyyyMMdd()
                    }
                }
                pages.append(page)
            }
                
            if let subscriptionTitle = subscriptionTitle {
                pages.append(.subscription(for: subscriptionTitle))
            } else {
                pages.append(.empty)
            }
        }
        
        catch let error as NSError {
            print(error)
        }
        
        pageCounterButton.frame = CGRect(x: 0, y: 0, width: 50, height: 20)
        pageCounterButton.titleLabel?.adjustsFontSizeToFitWidth = true
        let buttonColor = UIColor.label
        pageCounterButton.setTitleColor(buttonColor, for: .normal)
        pageCounterButton.setTitleColor(buttonColor, for: .highlighted)

        pageCounterButton.addTarget(
            self,
            action: #selector(pageCounterTapped),
            for: .touchUpInside
        )

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: pageCounterButton)

    }
    
    @objc func pageCounterTapped() {

        let alert = UIAlertController(
            title: .jumpToPage,
            message: .givePageNumber,
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.placeholder = .pageNumber
            textField.keyboardType = .numberPad
        }

        let cancelAction = UIAlertAction(title: .cancel, style: .cancel)

        let okAction = UIAlertAction(title: .jump, style: .default) { _ in
            guard
                let text = alert.textFields?.first?.text,
                let page = Int(text)
            else {
                return
            }

            self.jump(to: page - 1, animated: true)
        }

        alert.addAction(cancelAction)
        alert.addAction(okAction)

        present(alert, animated: true)
    }

    
    // MARK: - Table view data source

    let newLabelHeight = 40.0
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let page = pages[indexPath.row]
        
        if page.contentType == .subscription {
            return tableView.dequeueReusableCell(withIdentifier: "subscription", for: indexPath)
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "content", for: indexPath) as! ImageCell
        cell.contentImageView.isInvertable = page.isInvertable
        cell.contentImageView.image = page.image
        cell.newLabel.isHidden = !page.isNew
        cell.newLabel.text = .newPages + " — " + (page.lastUpdated?.formatted(date: .abbreviated, time: .omitted) ?? "")
        cell.newLabelHeight.constant = page.isNew ? newLabelHeight : 0
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if pages[indexPath.row].contentType == .subscription {
            return UITableView.automaticDimension
        }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
        + (pages[indexPath.row].isNew ? newLabelHeight : 0)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if pages[indexPath.row].contentType == .subscription {
            print("subscribe!!!" + subscriptionTitle!)
        }
    }
    
    var reviewRequested = false
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var index = currentIndex ?? 0
        
        if index > 0, pages.count > index + 1, pages[index - 1].isNew {
            UserDefaults.standard.set(Date(), forKey: pages[index - 1].lastDisplayedKey)
        }
        
        let pageCount = tableView.numberOfRows(inSection: 0)
        if tableView.indexPathsForVisibleRows?.last?.row == pageCount - 1  {
            index = pageCount - 3
            if index < 0 {
                index = 0
            }
        }
        pageCounterButton.setTitle("\(index+1)", for: .normal)
        
        if !reviewRequested && index > 5, let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            reviewRequested = true
            DispatchQueue.main.async {
                SKStoreReviewController.requestReview(in: scene)
            }
        }

    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        tableView.reloadData()
    }
}

extension UIColor {
    func image(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { rendererContext in
            self.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }
}
