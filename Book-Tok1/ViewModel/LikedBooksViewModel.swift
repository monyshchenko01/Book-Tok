import Combine
import UIKit
import CoreData

class LikedBooksViewModel {    
    private var likedBooksSubject = CurrentValueSubject<[Book], Never>([])
    private var likedBooksImagesSubject = CurrentValueSubject<[UIImage?], Never>([])
    private let bookAPIservice: BookAPIService
    var cancellables = Set<AnyCancellable>()
    
    var likedBooksPublisher: AnyPublisher<[Book], Never> {
        likedBooksSubject.eraseToAnyPublisher()
    }
    
    var likedBooksImagesPublisher: AnyPublisher<[UIImage?], Never> {
        likedBooksImagesSubject.eraseToAnyPublisher()
    }
    
    init(bookAPIservice: BookAPIService) {
        self.bookAPIservice = bookAPIservice
    }
    
    func loadBooks() {
        bookAPIservice.fetchBooksFromCoreData()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure = completion {
                    self?.likedBooksSubject.send([])
                }
            } receiveValue: { [weak self] books in
                self?.likedBooksSubject.send(books)
            }
            .store(in: &cancellables)
        
        self.fetchBooksImages()
    }
    
    private func fetchBooksImages() {
        likedBooksSubject
            .sink { [weak self] books in
                guard let self = self else { return }
                
                let likedBooksImagesPublishers = books.map { book -> AnyPublisher<UIImage?, Never> in
                    if let urlString = book.imageLinks?.thumbnail, let url = URL(string: urlString) {
                        return self.bookAPIservice.fetchImage(at: url)
                            .retry(3)
                            .catch { _ in Just(nil) }
                            .eraseToAnyPublisher()
                    } else {
                        return Just(nil).eraseToAnyPublisher()
                    }
                }
                
                Publishers.MergeMany(likedBooksImagesPublishers)
                    .collect()
                    .sink(receiveCompletion: { [weak self] completion in
                        if case .failure = completion {
                            self?.likedBooksImagesSubject.send([])
                        }
                    }, receiveValue: { [weak self] images in
                        self?.likedBooksImagesSubject.send(images)
                    })
                    .store(in: &self.cancellables)
            }
            .store(in: &cancellables)
    }

}
