//
//  ViewController.swift
//  river
//
//  Created by Dev on 2024.09.29.
//

import UIKit

let defaultInterfaceStyle: UserInterfaceStyle = .light

class TitlesViewController: ImageDisplayTableViewController {

    var rootBundleName = "books.bundle"
    let sampleBundleName = "sample-books.bundle"
    var parentBundleURL = Bundle.main.bundleURL
    var bundleTitle = Text.mainTitle
    let fileManager = FileManager.default

    var codeTitle: [String: String] = [:]
    
    var interfaceStyle: UserInterfaceStyle = defaultInterfaceStyle
    var interfaceStyleButton: UIBarButtonItem!

    @objc func rightbarButtonTapped() {
        interfaceStyle = interfaceStyle.toggle()
        navigationItem.rightBarButtonItem?.image = interfaceStyle.icon
        UserDefaults.standard.set(interfaceStyle.rawValue, forKey: "interfaceStyle")
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        title = bundleTitle
        
        let candidateURL = parentBundleURL.appendingPathComponent(rootBundleName)

        if FileManager.default.fileExists(atPath: candidateURL.path) {
            assetURL = candidateURL
        } else {
            rootBundleName = sampleBundleName
            assetURL = parentBundleURL.appendingPathComponent(rootBundleName)
        }

        interfaceStyleButton = UIBarButtonItem(image: interfaceStyle.icon, style: .plain, target: self, action: #selector(rightbarButtonTapped))
        navigationItem.rightBarButtonItem = interfaceStyleButton
        
        tableView.separatorInset = .zero

        do {
            let contents = try fileManager.contentsOfDirectory(at: assetURL, includingPropertiesForKeys: [.nameKey, .isDirectoryKey], options: .skipsHiddenFiles)
            
            var fileOrder: [String] = []
            
            for item in contents {
                let filename = item.lastPathComponent
                if filename.hasSuffix(".bundle") {
                    let newTitle = Page()
                    newTitle.code = filename.split(separator: ".").dropLast().joined(separator: ".")
                    pages.append(newTitle)
                    let assetURL = item
                    newTitle.assetURL = assetURL
                    
                    do {
                        let contents = try fileManager.contentsOfDirectory(at: assetURL, includingPropertiesForKeys: [URLResourceKey.nameKey, URLResourceKey.isDirectoryKey], options: .skipsHiddenFiles)
                        
                        for item in contents {
                            if item.lastPathComponent == "title.heic" {
                                let bundle = Bundle(url: assetURL)
                                newTitle.image = .init(named: item.lastPathComponent, in: bundle, with: nil)
                            } else if item.lastPathComponent.hasSuffix(Page.ContentType.bundle.rawValue) {
                                newTitle.contentType = .bundle
                            } else if item.lastPathComponent.hasSuffix(Page.ContentType.epub.rawValue) {
                                newTitle.contentType = .epub
                                newTitle.assetURL = item
                            } else if item.lastPathComponent == "action.txt" {
                                newTitle.contentType = .url
                                newTitle.assetURL = try? URL(string: String(contentsOf: item).trimmingCharacters(in: .newlines))
                            }
                        }
                    }
                    catch let error as NSError {
                        print(error)
                    }
                }
                else if filename == "code-title-order.txt",
                        let contents = try? String(contentsOf: item) {
                    fileOrder = contents.split(separator: "\n").compactMap{ String( $0 )}
                }
            }
            
            fileOrder.forEach { line in
                let components = line.components(separatedBy: "::")
                guard !components.isEmpty else { return }
                let code = components[0].trimmingCharacters(in: .whitespaces)
                if components.count > 1, let currentTitle = pages.first(where: { code == $0.code }) {
                    currentTitle.title = components[1].trimmingCharacters(in: .whitespaces)
                    if components.count > 2 {
                        
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyyMMdd"
                        formatter.locale = Locale(identifier: "en_US_POSIX")

                        if let date = formatter.date(from: components[2].trimmingCharacters(in: .whitespaces)) {
                            currentTitle.lastUpdated = date
                        }
                    }
                }
            }
            
            pages = fileOrder.compactMap{ code in
                pages.first(where: { $0.code == code.components(separatedBy: "::").first ?? "" })
            }
        }
        catch let error as NSError {
          print(error)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        interfaceStyle = UserInterfaceStyle.init(rawValue: UserDefaults.standard.string(forKey: "interfaceStyle") ?? defaultInterfaceStyle.rawValue) ?? defaultInterfaceStyle
        navigationItem.rightBarButtonItem?.image = interfaceStyle.icon
        tableView.reloadData()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        tableView.reloadData()
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        
        let title = pages[tableView.indexPathForSelectedRow!.row]
        UserDefaults.standard.set(Date(), forKey: title.lastVisitedKey)

        switch title.contentType {
        case .pages:
            return true
        case .bundle:
            let subTitlesViewController = storyboard?.instantiateViewController(withIdentifier: "TitlesViewController") as! TitlesViewController
            subTitlesViewController.rootBundleName = title.assetURL!.lastPathComponent
            subTitlesViewController.parentBundleURL = assetURL
            subTitlesViewController.bundleTitle = title.title ?? ""
            navigationController?.pushViewController(subTitlesViewController, animated: true)
            return false
        case .epub:
            guard let url = title.assetURL else { return false }
            let activity = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            activity.popoverPresentationController?.sourceView = tableView
            self.present(activity, animated: true)
            return false
        case .url:
            UIApplication.shared.open(title.assetURL!)
            print ("Opening \(title.assetURL!)")
            return false
        }
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? ContentTableViewController,
            let row = tableView.indexPathForSelectedRow?.row else { return }
        
        destination.assetURL = pages[row].assetURL
        destination.title = pages[row].title
        
    }
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "title", for: indexPath) as! ImageCell
        cell.contentImageView.image = pages[indexPath.row].image
        cell.newLabel.isHidden = !pages[indexPath.row].isNew
        cell.newLabel.text = Text.new.uppercased()
        cell.linkSymbol.isHidden = pages[indexPath.row].contentType != .url || pages[indexPath.row].isNew
        return cell
    }
    
}
