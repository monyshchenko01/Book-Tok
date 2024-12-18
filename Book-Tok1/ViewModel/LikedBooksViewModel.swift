import Combine
import UIKit
import CoreData

class LikedBooksViewModel {
    @Published private(set) var likedBooks: [Book] = []
    private var cancellables = Set<AnyCancellable>()
    func loadBooks() {
        fetchBooksFromCoreData()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Failed to fetch liked books: \(error)")
                }
            } receiveValue: { [weak self] books in
                self?.likedBooks = books
            }
            .store(in: &cancellables)
    }
    func addLikedBook(_ book: Book) {
        likedBooks.append(book)
    }
    private func fetchBooksFromCoreData() -> AnyPublisher<[Book], Error> {
        Future { promise in
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                promise(.failure(NSError(domain: "CoreDataError", code: 0, userInfo: nil)))
                return
            }
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest: NSFetchRequest<BookEntity> = BookEntity.fetchRequest()

            do {
                let bookEntities = try context.fetch(fetchRequest)
                let books = bookEntities.map { entity in
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
                promise(.success(books))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
}
