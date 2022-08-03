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
        deleteAll()
    }

    func save(cloudEncryptedOTPs: [CloudEncryptedOTP]) {
        var otpIDs = cloudEncryptedOTPs.enumerated().reduce(into: [String: CloudEncryptedOTP]()) {
            $0[$1.element.id] = $1.element
        }

        let fetchRequest = EncryptedOTP.fetchRequest()
        fetchRequest.includesPropertyValues = false

        if let otps = try? context.fetch(fetchRequest) {
            for otp in otps {
                if let updatedItem = otpIDs.removeValue(forKey: otp.id!) {
                    otp.copy(updatedItem)
                } else {
                    context.delete(otp)
                }
            }
        }

        for (_, otp) in otpIDs {
            let newOTP = EncryptedOTP(context: context)
            newOTP.copy(otp)
        }

        save()
    }

    func deleteAll() {
        let fetchRequest = EncryptedOTP.fetchRequest()
        fetchRequest.includesPropertyValues = false

        if let items = try? context.fetch(fetchRequest) {
            for item in items {
                context.delete(item)
            }
        }

        self.save()
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
                    oldUser.copy(newValue)
                } else {
                    context.delete(oldUser)
                }
            } else {
                if let newValue = newValue {
                    let newUser = MFUserEntity(context: context)
                    newUser.copy(newValue)
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

//MARK: MFUser extensions
extension MFUser {
    init?(entity: MFUserEntity?) {
        if let entity = entity {
            self.id = entity.id!
            self.username = entity.username!
        } else {
            return nil
        }
    }
}

extension MFUserEntity {
    func copy(_ user: MFUser) {
        self.id = user.id
        self.username = user.username
    }
}

//MARK: EncryptedOTP extension
extension EncryptedOTP {
    func copy(_ cloudEncryptedOTP: CloudEncryptedOTP) {
        self.id = cloudEncryptedOTP.id
        self.issuer = cloudEncryptedOTP.issuer
        self.label = cloudEncryptedOTP.label
        self.secret = cloudEncryptedOTP.secret
        self.algorithm = cloudEncryptedOTP.algorithm.rawValue
        self.digits = Int16(cloudEncryptedOTP.digits.rawValue)
        self.period = Int16(cloudEncryptedOTP.period.rawValue)
    }
}
