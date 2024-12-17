import Foundation
import UIKit
import Combine

final class AuthorViewModel {
    private var authorSubject = CurrentValueSubject<Author?, Never>(nil)
    private var authorImageSubject = CurrentValueSubject<UIImage?, Never>(nil)
    var bookAPIservice: BookAPIService
    var cancellables = Set<AnyCancellable>()
//    private let author: Author

    init(/*author: Author,*/ bookAPIservice: BookAPIService) {
//        self.author = author
        self.bookAPIservice = bookAPIservice
    }
    var authorPublisher: AnyPublisher<Author?, Never> {
        authorSubject.eraseToAnyPublisher()
    }
    
    var authorImagePublisher: AnyPublisher<UIImage?, Never> {
        authorImageSubject.eraseToAnyPublisher()
    }

    func fetchAuthorDetails(name: String) {
        bookAPIservice.fetchAuthorDetails(with: name)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure = completion {
                    self?.authorSubject.send(nil)
                    self?.authorImageSubject.send(nil)
                }
            } receiveValue: { [weak self] author in
                self?.authorSubject.send(author)
                if let photoURLString = author.photoURL, let photoURL = URL(string: photoURLString) {
                    self?.fetchAuthorImage(from: photoURL)
                }
            }
            .store(in: &cancellables)
    }

    func fetchAuthorImage(from url: URL) {
        bookAPIservice.fetchImage(at: url)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure = completion {
                    self?.authorImageSubject.send(nil)
                }
            } receiveValue: { [weak self] image in
                self?.authorImageSubject.send(image)
            }
            .store(in: &cancellables)
    }

    func getAuthor() -> Author? {
        return authorSubject.value
    }

    func getAuthorName() -> String {
        return authorSubject.value?.name ?? "Unknown Author"
    }

    func getAuthorBiography() -> String {
        return authorSubject.value?.biography ?? "Biography not available."
    }
}