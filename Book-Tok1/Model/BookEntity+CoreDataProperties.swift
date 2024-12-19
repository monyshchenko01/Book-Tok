//
//  BookEntity+CoreDataProperties.swift
//  Book-Tok1
//
//  Created by owner on 16.12.2024.
//
//

import Foundation
import CoreData


extension BookEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BookEntity> {
        return NSFetchRequest<BookEntity>(entityName: "BookEntity")
    }

    @NSManaged public var authors: [String]?
    @NSManaged public var categories: [String]?
    @NSManaged public var coverURL: String?
    @NSManaged public var bookDescription: String?
    @NSManaged public var averageRating: Double
    @NSManaged public var title: String?
    @NSManaged public var relationship: CommentsEntity?
    @NSManaged public var imageLinks: ImageLinksEntity?

}

extension BookEntity : Identifiable {

}
