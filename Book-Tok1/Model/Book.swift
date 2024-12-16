//
//  Book.swift
//  Book-Tok1
//
//  Created by Kira Zholtikova on 11.12.2024.
//
import Foundation

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
    var isLiked = false
}

struct GoogleBooksResponse: Decodable {
    let items: [Volume]?
}

struct Volume: Decodable {
    let volumeInfo: Book
}