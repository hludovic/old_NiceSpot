//
//  PersistenceController.swift
//  NiceSpot
//
//  Created by Ludovic HENRY on 04/07/2021.
//

import CoreData
import CloudKit

class PersistenceController {

    // MARK: - CloudKit Static Property

    static let publicCKDB: CKDatabase = CKContainer(identifier: "iCloud.fr.hludovic.container1").publicCloudDatabase

    static var isICloudAvailable: Bool {
        if FileManager.default.ubiquityIdentityToken != nil {
            return true
        } else { return false }
    }

    // MARK: - CoreData Static Property

    static let shared = PersistenceController()

    static var tests: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "NiceSpot")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (_, error) in
            self.container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
}
