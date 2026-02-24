//
//  ViewController.swift
//  river
//
//  Created by Dev on 2024.09.29.
//

import UIKit

class TitlesViewController: ImageDisplayTableViewController {

    var rootBundleName = "books.bundle"
    let sampleBundleName = "sample-books.bundle"
    var parentBundleURL = Bundle.main.bundleURL
    var bundleTitle = String.mainTitle
    let fileManager = FileManager.default

    var codeTitle: [String: String] = [:]

    var interfaceStyle: UIUserInterfaceStyle {
        get {
            return UIWindow.main?.overrideUserInterfaceStyle ?? .light
        }
        set {
            UIWindow.main?.overrideUserInterfaceStyle = newValue
        }
    }

    var interfaceStyleButton: UIBarButtonItem!

    @objc func rightbarButtonTapped() {

        interfaceStyle = interfaceStyle.toggle()
        navigationItem.rightBarButtonItem?.image = interfaceStyle.icon
        UserDefaults.standard.set(interfaceStyle.userDefaultsString, forKey: "interfaceStyle")
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

        interfaceStyle = .fromUserDefaultsString(UserDefaults.standard.string(forKey: "interfaceStyle"))
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
                        currentTitle.lastUpdated = components[2].toDateyyyyMMdd()
                        
                        if components.count > 3, components[3].lowercased() == "subscribe" {
                            if subscriptionTitle == nil {
                                currentTitle.canSubscribe = true
                            }
                        }
                    }
                }
            }

            pages = fileOrder.compactMap{ code in
                pages.first(where: { $0.code == code.components(separatedBy: "::").first ?? "" })
            }
            if subscriptionTitle != nil {
                pages.last(where: { [.bundle, .pages].contains($0.contentType) })?.canSubscribe = true
            }
        }
        catch let error as NSError {
          print(error)
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        tableView.reloadData()
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {


        let title = pages[tableView.indexPathForSelectedRow!.row]
        UserDefaults.standard.set(Date(), forKey: title.lastDisplayedKey)

        switch title.contentType {
        case .pages:
            return true
        case .bundle:
            let subTitlesViewController = storyboard?.instantiateViewController(withIdentifier: "TitlesViewController") as! TitlesViewController
            subTitlesViewController.rootBundleName = title.assetURL!.lastPathComponent
            subTitlesViewController.parentBundleURL = assetURL
            subTitlesViewController.bundleTitle = title.title ?? ""
            if title.canSubscribe {
                subTitlesViewController.subscriptionTitle = subscriptionTitle ?? title.title
            }
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
        case .empty, .subscription:
            return false
        }

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? ContentTableViewController,
            let row = tableView.indexPathForSelectedRow?.row else { return }

        destination.assetURL = pages[row].assetURL
        destination.title = pages[row].title
        if pages[row].canSubscribe {
            destination.subscriptionTitle = subscriptionTitle ?? destination.title
        }

    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "title", for: indexPath) as! ImageCell
        cell.contentImageView.image = pages[indexPath.row].image
        cell.newLabel.isHidden = !pages[indexPath.row].isNew
        cell.newLabel.text = .new.uppercased()
        cell.linkSymbol.isHidden = pages[indexPath.row].contentType != .url || pages[indexPath.row].isNew
        return cell
    }

}
