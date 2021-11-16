//
//  User.swift
//  NiceSpot
//
//  Created by Ludovic HENRY on 22/10/2021.
//

import Foundation
import CloudKit

class User {
    let pseudonym: String
    let isBanned: Bool
    private let database = PersistenceController.publicCKDB

    private init (pseudonym: String, isBanned: Bool) {
        self.pseudonym = pseudonym
        self.isBanned = isBanned
    }

    static func getCurrentUser(completion: @escaping (Result<Bool, Error>) -> Void) {

    }

    func fetchUser(userID: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let predicate = NSPredicate(format: "creatorUserRecordID == %@", userID)
        let query = CKQuery(recordType: "User", predicate: predicate)
        let operation =  CKQueryOperation(query: query)
        
    }

}
