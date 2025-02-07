//
//  OnboardingRouter.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import Foundation
import UIKit

struct OnboardingRouter: OnboardingRouterProtocol {
    // MARK: - Properties

    let sceneCoordinator: SceneCoordinator

    // MARK: - Lifecycle

    init(sceneCoordinator: SceneCoordinator) {
        self.sceneCoordinator = sceneCoordinator
    }

    // MARK: - Methods

    func showNextScene() {
        sceneCoordinator.asRoot(
            ValidatorOverviewSceneFactory(
                router: ValidatorOverviewRouter(sceneCoordinator: sceneCoordinator)
            )
        )
    }

    func showPreviousScene() {
        sceneCoordinator.asRoot(
            WelcomeSceneFactory(
                router: WelcomeRouter(sceneCoordinator: sceneCoordinator)
            )
        )
    }

    func showDataPrivacyScene() {
        let staticHtmlUrl = Bundle.main.url(forResource: "privacy-covpasscheck", withExtension: "html")
        let webViewScene = WebviewSceneFactory(title: "app_information_title_datenschutz".localized, url: staticHtmlUrl!, closeButtonShown: true)
        sceneCoordinator.present(webViewScene)
    }
}
