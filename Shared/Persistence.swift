//
//  Persistence.swift
//  Shared
//
//  Created by g.lofrumento on 19/07/22.
//

import CoreData

class PersistenceController {
    static let shared = PersistenceController()

    private let container: NSPersistentContainer
    var context: NSManagedObjectContext {
        container.viewContext
    }

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "MultiFactor")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate.
                // You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible due to permissions or data protection when device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    fileprivate func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch { }
        }
    }
}

//MARK: UserEntity
extension PersistenceController {
    var user: MFUser? {
        set {
            let request = MFUserEntity.fetchRequest()
            request.fetchLimit = 1
            if let oldUser = try? context.fetch(request).first {
                if let newValue = newValue {
                    oldUser.id = newValue.id
                    oldUser.email = newValue.email
                } else {
                    context.delete(oldUser)
                }
            } else {
                if let newValue = newValue {
                    let newUser = MFUserEntity(context: context)
                    newUser.id = newValue.id
                    newUser.email = newValue.email
                }
            }

            save()
        }
        get {
            let request = MFUserEntity.fetchRequest()
            request.fetchLimit = 1
            let user = try? context.fetch(request).first
            return MFUser(entity: user)
        }
    }
}

extension MFUser {
    init?(entity: MFUserEntity?) {
        if let entity = entity {
            self.id = entity.id!
            self.email = entity.email!
        } else {
            return nil
        }
    }
}

#if DEBUG
extension PersistenceController {
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate.
            // You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
}
#endif
