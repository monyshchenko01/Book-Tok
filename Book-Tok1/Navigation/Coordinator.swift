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
        let likedBooksViewModel = LikedBooksViewModel(bookAPIservice: bookAPIService)
        let likedBooksViewController = LikedBooksViewController(viewModel: likedBooksViewModel)
        likedBooksViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "heart.circle"), tag: 1)
        
        tabBarController.viewControllers = [bookTokViewController, likedBooksViewController]
        navigationController.pushViewController(tabBarController, animated: false)
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }

}
