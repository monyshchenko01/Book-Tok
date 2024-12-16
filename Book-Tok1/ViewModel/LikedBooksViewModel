import UIKit
import CoreData

class LikedBooksViewModel {
    private var likedBooks: [Book] = []
    var reloadData: (() -> Void)?

    func loadBooks() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<BookEntity> = BookEntity.fetchRequest()
        
        do {
            let bookEntities = try context.fetch(fetchRequest)
            likedBooks = bookEntities.map { Book(from: $0) }
            reloadData?()
        } catch {
            print("Failed to fetch liked books: \(error)")
        }
    }

    func getLikedBooks() -> [Book] {
        return likedBooks
    }
}
