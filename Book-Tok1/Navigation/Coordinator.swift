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
        bookTokViewController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house.fill"), tag: 0)
//        let likedBooksViewController = LikedBooksViewController()
//        likedBooksViewController.tabBarItem = UITabBarItem(title: "Liked Books", image: UIImage(systemName: "heart.circle"), tag: 1)
        
        tabBarController.viewControllers = [bookTokViewController]
        navigationController.pushViewController(tabBarController, animated: false)
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }

}
