//
//  Book.swift
//  Book-Tok1
//
//  Created by Kira Zholtikova on 11.12.2024.
//
import Foundation

struct Book : Decodable {
    let title: String
    let authors: [String]?
    let description: String?
    let categories: [String]?
    let averageRating: Double?
    let coverURL: String?
}

struct GoogleBooksResponse: Decodable {
    let items: [Volume]?
}

struct Volume: Decodable {
    let volumeInfo: Book
}
