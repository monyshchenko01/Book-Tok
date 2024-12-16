import Foundation

class CommentsViewModel {
    private var commentsList: [String] = [] {
        didSet {
            self.updateUI?()
        }
    }
    var updateUI: (() -> Void)?

    var comments: [String] {
        return commentsList
    }

    func addComment(_ comment: String) {
        commentsList.append(comment)
    }

    func deleteComment(at index: Int) {
        commentsList.remove(at: index)
    }
}
