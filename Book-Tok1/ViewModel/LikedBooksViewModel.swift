import UIKit
import CoreData

class LikedBooksViewModel {
    var likedBooks: [Book] = []
    var reloadData: (() -> Void)?

    func loadBooks() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<BookEntity> = BookEntity.fetchRequest()
        do {
            let bookEntities = try context.fetch(fetchRequest)
            likedBooks = bookEntities.map { entity in
                Book(
                    title: entity.title ?? "Untitled",
                    authors: entity.authors,
                    description: entity.bookDescription,
                    categories: entity.categories,
                    averageRating: entity.averageRating,
                    imageLinks: entity.imageLinks.flatMap { imageEntity in
                        ImageLinks(
                            smallThumbnail: imageEntity.smallThumbnail,
                            thumbnail: imageEntity.thumbnail
                        )
                    }
                )
            }
            reloadData?()
        } catch {
            print("Failed to fetch liked books: \(error)")
        }
    }

    func getLikedBooks() -> [Book] {
        return likedBooks
    }
}
