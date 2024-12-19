import Foundation
import CoreData
import UIKit

class CommentsViewModel {
    private let context: NSManagedObjectContext
    private var commentsList: [CommentsEntity] = [] {
        didSet {
            self.updateUI?()
        }
    }
    var updateUI: (() -> Void)?

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    var comments: [String] {
        return commentsList.compactMap { $0.comment }
    }

    func fetchComments(for book: BookEntity) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("Failed to get AppDelegate")
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<CommentsEntity> = CommentsEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "relationship == %@", book)

        do {
            commentsList = try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch comments: \(error.localizedDescription)")
        }
    }

    func addComment(_ text: String, to book: BookEntity) {
        let newComment = CommentsEntity(context: context)
        newComment.comment = text
        newComment.relationship = book
        saveContext()
        fetchComments(for: book)
    }

    func deleteComment(at index: Int, for book: BookEntity) {
        let commentToDelete = commentsList[index]
        context.delete(commentToDelete)

        saveContext()
        fetchComments(for: book)
    }

    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error.localizedDescription)")
        }
    }
}
