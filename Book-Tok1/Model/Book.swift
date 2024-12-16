//
//  Book.swift
//  Book-Tok1
//
//  Created by Kira Zholtikova on 11.12.2024.
//
import Foundation
import UIKit
import CoreData

struct ImageLinks: Decodable {
    let smallThumbnail: String?
    let thumbnail: String?
}

struct Book : Decodable {
    let title: String
    let authors: [String]?
    let description: String?
    let categories: [String]?
    let averageRating: Double?
    let imageLinks: ImageLinks?
    
    var isLiked: Bool {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<BookEntity> = BookEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)

        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Error checking liked status: \(error)")
            return false
        }
    }
}

struct GoogleBooksResponse: Decodable {
    let items: [Volume]?
}

struct Volume: Decodable {
    let volumeInfo: Book
}
