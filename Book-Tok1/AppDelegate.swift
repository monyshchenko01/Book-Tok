//
//  AppDelegate.swift
//  Book-Tok1
//
//  Created by Matvii Onyshchenko on 06.12.2024.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func applicationWillTerminate(_ application: UIApplication) {
        self.saveContext()
    }
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "BookData")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
// Reference: https://github.com/mohammadalijf/CoreData-AppDelegate/blob/master/AppDelegate.swift

