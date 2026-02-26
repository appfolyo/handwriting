//
//  SceneDelegate.swift
//  river
//
//  Created by Dev on 2024.09.29.
//

import UIKit

//A key used for exchanging associated object
var _BUNDLE_KEY = 0

class BundleEx : Bundle, @unchecked Sendable {
    
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        
        let bundle : Bundle? = objc_getAssociatedObject(self, &_BUNDLE_KEY) as? Bundle
        
        return bundle != nil ? bundle!.localizedString(forKey: key, value: value, table: tableName) : super.localizedString(forKey: key, value: value, table: tableName)
    }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }

        let langs = UserDefaults.standard.value(forKey: "AppleLanguages") as? [String]
        
        let alreadyStartedKey = "alreadyStartedKey"
        let alreadyStarted = UserDefaults.standard.value(forKey: alreadyStartedKey) as? Bool ?? false
        
        let overrideLanguage = "hu"
        if !alreadyStarted, langs == nil || !langs!.contains(overrideLanguage) {
            
            let newLangs: [String] = [overrideLanguage] + (langs ?? [])
            UserDefaults.standard.set(newLangs, forKey: "AppleLanguages" )
            UserDefaults.standard.set(true, forKey: alreadyStartedKey)
            UserDefaults.standard.synchronize()
            
            object_setClass(Bundle.main, BundleEx.self)
            
            let bundle = Bundle(path: Bundle.main.path(forResource: overrideLanguage, ofType: "lproj")!)
            objc_setAssociatedObject(Bundle.main, &_BUNDLE_KEY, bundle, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                        
            let sb = UIStoryboard(name: "Main", bundle: Bundle.main)
            let vc = sb.instantiateInitialViewController()
            self.window?.rootViewController = vc
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
    }


}

