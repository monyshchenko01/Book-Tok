//
//  SceneDelegate.swift
//  Book-Tok1
//
//  Created by Matvii Onyshchenko on 06.12.2024.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var coordinator: Coordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let navigationController = UINavigationController()
        coordinator = Coordinator(rootViewController: navigationController)
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = navigationController
        window?.backgroundColor = .systemGray2
        window?.makeKeyAndVisible()
        coordinator?.start()
    }

}
