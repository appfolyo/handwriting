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
                page.invertable = !fileName.contains("no-invert")
                pages.append(page)
            }
                
            var clearImageSize = UIScreen.main.bounds.size
            clearImageSize.height *= 0.5
            let clearImage = UIColor.clear.image(clearImageSize)
            let clearPage = Page()
            clearPage.image = clearImage
            clearPage.invertable = true
            pages.append(clearPage)
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
            title: Text.jumpToPage,
            message: Text.givePageNumber,
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.placeholder = Text.pageNumber
            textField.keyboardType = .numberPad
        }

        let cancelAction = UIAlertAction(title: Text.cancel, style: .cancel)

        let okAction = UIAlertAction(title: Text.jump, style: .default) { _ in
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

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let page = pages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "content", for: indexPath) as! ImageCell
        cell.contentImageView.isInvertable = page.invertable
        cell.contentImageView.image = page.image
        if !page.invertable {
            print("no-invertable")
        }
        return cell
    }
    
    var reviewRequested = false
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var index = currentIndex ?? 0
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
