import UIKit

class Coordinator {
    let navigationController: UINavigationController

    init(rootViewController: UINavigationController) {
        self.navigationController = rootViewController
    }
    func start() {
        let tabBarController = UITabBarController()
        let mainBooksViewController = UIViewController()
        mainBooksViewController.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house"),
            tag: 0
        )
        let likedBooksViewController = LikedBooksViewController()
                likedBooksViewController.tabBarItem = UITabBarItem(
                    title: "Liked Books",
                    image: UIImage(systemName: "heart.circle"),
                    tag: 1
                )
        tabBarController.viewControllers = [mainBooksViewController, likedBooksViewController]
        navigationController.viewControllers = [tabBarController]
    }

}
