//
//  SceneDelegate.swift
//  Folium
//
//  Created by Jarrod Norwell on 2/7/2024.
//

import Firebase
import FirebaseAuth
import UIKit
import WidgetKit
import DirectoryManager

enum ApplicationState: Int {
    case backgrounded = 0
    case foregrounded = 1
    case disconnected = 2
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
       
        
        guard let windowScene = scene as? UIWindowScene else { return }
        
        window = UIWindow(windowScene: windowScene)
        window?.tintColor = .systemGreen
        
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        
        if let version, let build {
            let currentlyInstalledVersion = "\(version).\(build)"
            let currentlySavedVersion = UserDefaults.standard.string(forKey: "currentlySavedVersion")
            
            if Double(version) ?? 0 >= 1.10 {
                if currentlySavedVersion != currentlyInstalledVersion {
                    UserDefaults.standard.setValue(currentlyInstalledVersion, forKey: "currentlySavedVersion")
                }
                try? configureMissingDirectories(for: LibraryManager.shared.cores.map { $0.rawValue })
                
            } else {
                
            }
        }
        
        configureDefaultUserDefaults()
        
        if let userDefaults = UserDefaults(suiteName: "group.techguy.folium") {
            userDefaults.set(AppStoreCheck.shared.additionalFeaturesAreAllowed, forKey: "additionalFeaturesAreAllowed")
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        NotificationCenter.default.post(name: .init("applicationStateDidChange"), object: ApplicationState.disconnected)
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        NotificationCenter.default.post(name: .init("applicationStateDidChange"), object: ApplicationState.foregrounded)
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        NotificationCenter.default.post(name: .init("applicationStateDidChange"), object: ApplicationState.backgrounded)
    }
}

extension SceneDelegate {
    
    
    

    fileprivate func configureMissingDirectories(for cores: [String]) throws {
        try DirectoryManager.shared.createMissingDirectoriesInDocumentsDirectory(for: cores)
    }
    
    fileprivate func configureDefaultUserDefaults() {
        let defaults: [String: [String: Any]] = [
            "Folium": [
                "showBetaConsoles": false,
                "showConsoleNames": false,
                "showGameTitles": true
            ]
        ]
        
        defaults.forEach { core, values in
            values.forEach { key, value in
                let fullKey = "\(core.lowercased()).\(key)"
                if UserDefaults.standard.value(forKey: fullKey) == nil {
                    UserDefaults.standard.set(value, forKey: fullKey)
                }
            }
        }
    }

   
 
}
