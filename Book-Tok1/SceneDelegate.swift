//
//  SceneDelegate.swift
//  Book-Tok1
//
//  Created by Matvii Onyshchenko on 06.12.2024.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var coordinator: Coordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let navigationContoller = UINavigationController()
        let window = UIWindow(windowScene: windowScene)
        let bookAPIService = BookAPIService()
        
        coordinator = Coordinator(navigationController: navigationContoller, window: window, APIservice: bookAPIService)
        coordinator?.start()
    }

}
