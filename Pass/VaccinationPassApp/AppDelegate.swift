//
//  AppDelegate.swift
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Keychain
import UIKit
import VaccinationCommon
import VaccinationUI
import VaccinationPass

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var sceneCoordinator: DefaultSceneCoordinator?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        try? clearKeychainOnFreshInstall()
        try? UIFont.loadCustomFonts()

        let window = UIWindow(frame: UIScreen.main.bounds)
        let sceneCoordinator = DefaultSceneCoordinator(window: window)
        let mainScene = PassAppSceneFactory(sceneCoordinator: sceneCoordinator)
        sceneCoordinator.asRoot(mainScene)
        window.rootViewController = sceneCoordinator.rootViewController
        window.makeKeyAndVisible()
        self.window = window
        self.sceneCoordinator = sceneCoordinator

        return true
    }

    private func clearKeychainOnFreshInstall() throws {
        if !UserDefaults.StartupInfo.bool(.appInstalled) {
            UserDefaults.StartupInfo.set(true, forKey: .appInstalled)
            try Keychain.deletePassword(for: KeychainConfiguration.vaccinationCertificateKey)
        }
    }
}
