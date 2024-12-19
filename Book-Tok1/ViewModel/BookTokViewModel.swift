//
//  BookTokViewModels.swift
//  Book-Tok1
//
//  Created by Kira Zholtikova on 18.12.2024.
//
import CoreData
import UIKit
import Combine

final class BookTokViewModel : BaseBookTokViewModel {
    
    override func fetchBook() {
       bookAPIservice.fetchRandomBook()
           .receive(on: DispatchQueue.main)
           .sink { [weak self] completion in
               if case .failure = completion {
                   self?.bookSubject.send(nil)
                   self?.isLikedSubject.send(false)
               }
           } receiveValue: { [weak self] book in
               self?.bookSubject.send(book)
               self?.isLikedSubject.send(self?.findBook(book) != nil)
           }
           .store(in: &cancellables)
   }
   
   override func fetchCurrentBookImage() {
       guard let coverUrl = bookSubject.value?.imageLinks?.thumbnail, let url = URL(string: coverUrl) else { return }
       bookAPIservice.fetchImage(at: url)
          .receive(on: DispatchQueue.main)
          .sink(receiveCompletion: { [weak self] completion in
              if case .failure = completion {
                  self?.bookImageSubject.send(nil)
              }
          }, receiveValue: { [weak self] image in
              self?.bookImageSubject.send(image)
          })
          .store(in: &cancellables)
   }
}

