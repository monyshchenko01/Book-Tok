//
//  booksApi.swift
//  Book-Tok1
//
//  Created by Kira Zholtikova on 10.12.2024.
//
import Foundation
import UIKit
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
    func fetchAuthor(with name: String) -> AnyPublisher<Author, Error> {
        let booksURL = APIEndpoint.baseURL.appendingPathComponent("volumes")

        guard var components = URLComponents(url: booksURL, resolvingAgainstBaseURL: true) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        components.queryItems = [
            URLQueryItem(name: "q", value: "inauthor:\(encodedName)"),
            URLQueryItem(name: "key", value: APIEndpoint.apiKey),
            URLQueryItem(name: "maxResults", value: "10")
        ]

        guard let url = components.url else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: GoogleBooksResponse.self, decoder: JSONDecoder())
            .tryMap { response in
                guard let items = response.items, !items.isEmpty else {
                    print("No books found for author: \(name)")
                    throw URLError(.badServerResponse)
                }

                let books = items.map { $0.volumeInfo }
                let biography = "This is a biography of \(name)."
                let photoURL = "https://via.placeholder.com/150"

                return Author(name: name, biography: biography, photoURL: photoURL, books: books)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    func fetchAuthorDetails(with name: String) -> AnyPublisher<Author, Error> {
        return fetchAuthor(with: name)
    }
}
