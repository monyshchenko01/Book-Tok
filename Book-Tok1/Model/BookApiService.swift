//
//  booksApi.swift
//  Book-Tok1
//
//  Created by Kira Zholtikova on 10.12.2024.
//
import Foundation
import UIKit
import CoreData
import Combine

private enum APIEndpoint {
    static let baseURL = URL(string: "https://www.googleapis.com/books/v1")!
    static let apiKey = "" // DO NOT COMMIT YOUR API KEY TO SOURCE CONTROL.
}

final class BookAPIService {
    private var cancellable = Set<AnyCancellable>()

    func fetchRandomBook() -> AnyPublisher<Book, Error> {
        let booksURL = APIEndpoint.baseURL.appendingPathComponent("volumes")

        guard var components = URLComponents(url: booksURL, resolvingAgainstBaseURL: true) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        let randomLetter = String(Character(UnicodeScalar(Int.random(in: 97...122))!))
        components.queryItems = [
            URLQueryItem(name: "q", value: randomLetter),
            URLQueryItem(name: "key", value: APIEndpoint.apiKey),
            URLQueryItem(name: "startIndex", value: "\(Int.random(in: 0...510))"),
            URLQueryItem(name: "maxResults", value: "40")
        ]

        guard let url = components.url else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\ .data)
            .decode(type: GoogleBooksResponse.self, decoder: JSONDecoder())
            .tryMap { response in
                guard let items = response.items, !items.isEmpty else {
                    throw URLError(.badServerResponse)
                }
                guard let randomVolume = items.randomElement() else {
                    throw URLError(.resourceUnavailable)
                }
                
                return randomVolume.volumeInfo
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetchImage(at url: URL) -> AnyPublisher<UIImage?, Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .map { UIImage(data: $0) }
            .mapError { $0 as Error }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetchBooksFromAuthor(with name: String) -> AnyPublisher<[Book], Error> {
        let booksURL = APIEndpoint.baseURL.appendingPathComponent("volumes")

        guard var components = URLComponents(url: booksURL, resolvingAgainstBaseURL: true) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        components.queryItems = [
            URLQueryItem(name: "q", value: "inauthor:\(encodedName)"),
            URLQueryItem(name: "key", value: APIEndpoint.apiKey),
        ]
        
        guard let url = components.url else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        print(url)

        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: GoogleBooksResponse.self, decoder: JSONDecoder())
            .tryMap { response in
                guard let items = response.items, !items.isEmpty else {
                    print("No books found for author: \(name)")
                    throw URLError(.badServerResponse)
                }

                return items.map { $0.volumeInfo }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetchBooksFromCoreData() -> AnyPublisher<[Book], Error> {
        Deferred {
            Future { promise in
                DispatchQueue.main.async {
                    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                        promise(.failure(NSError(domain: "CoreDataError", code: 0, userInfo: nil)))
                        return
                    }
                    
                    let context = appDelegate.persistentContainer.viewContext
                    let fetchRequest: NSFetchRequest<BookEntity> = BookEntity.fetchRequest()
                    
                    DispatchQueue.global(qos: .background).async {
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
                            DispatchQueue.main.async {
                                promise(.success(books))
                            }
                        } catch {
                            DispatchQueue.main.async {
                                promise(.failure(error))
                            }
                        }
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    
}
