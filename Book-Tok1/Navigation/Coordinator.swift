//
//  Coordinator.swift
//  Book-Tok1
//
//  Created by Matvii Onyshchenko on 06.12.2024.
//

import UIKit

class Coordinator {
    let navigationController: UINavigationController

    init(rootViewController: UINavigationController) {
        self.navigationController = rootViewController
    }
    func start() {
        let commentsViewController = CommentsViewController()
        navigationController.viewControllers = [// тут буде перший контролер]
    }

}
