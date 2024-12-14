//
//  Coordinator.swift
//  Book-Tok1
//
//  Created by Matvii Onyshchenko on 06.12.2024.
//

import UIKit

class Coordinator {
    let navigationController: UINavigationController
    let window: UIWindow
    private let bookAPIService: BookAPIService

    init(navigationController: UINavigationController, window: UIWindow, APIservice: BookAPIService) {
        self.navigationController = navigationController
        self.window = window
        self.bookAPIService = APIservice
    }
    
    func start() {
        let tabBarController = UITabBarController()
        
        let bookTokViewModel = BookTokViewModel(bookAPIservice: bookAPIService)
        let bookTokViewController = BookTokViewController(viewModel: bookTokViewModel)
        bookTokViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "house.fill"), tag: 0)
        
        let commentsViewController = CommentsViewController()
        
        tabBarController.viewControllers = [bookTokViewController]
        navigationController.pushViewController(tabBarController, animated: false)
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }

}
