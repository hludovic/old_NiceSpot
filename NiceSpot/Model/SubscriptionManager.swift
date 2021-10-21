//
//  SubscriptionManager.swift
//  NiceSpot
//
//  Created by Ludovic HENRY on 19/10/2021.
//

import Foundation
import CloudKit
import UIKit

class SubscriptionManager {
    static func sbscriptionnize() {
        let genre = "River"
        let database = PersistenceController.publicCKDB

        database.fetchAllSubscriptions { subscriptions, error in
            guard error == nil else {
                print("\(error!.localizedDescription) ❌")
                return
            }
            deleteSubscriptions(subscriptions: subscriptions, database: database) { result in
                if case .failure(let error) = result {
                    print("\(error.localizedDescription) ❌")
                    return
                }
                writeSubscriptions(subscription: genre, database: database) { result in
                    switch result {
                    case .failure(let error):
                        print("\(error.localizedDescription) ❌")
                    case .success:
                        print("ECRIT")
                    }
                }
            }
        }
    }

    static func writeSubscriptions(subscription: String, database: CKDatabase, completion: @escaping (Result<Bool, Error>) -> Void) {
        let predicate = NSPredicate(format: "category = %@", subscription)
        let subsciption = CKQuerySubscription(recordType: "SpotCK", predicate: predicate, options: .firesOnRecordCreation)
        let notification = CKSubscription.NotificationInfo()
        notification.alertBody = "Added a new \(subscription) in the base"
        notification.soundName = "default"
        subsciption.notificationInfo = notification
        database.save(subsciption) { sub, error in
            guard error == nil else { return completion(.failure(error!)) }
            // ATTENTION PERSONALIZE ERROR
            guard sub != nil else { return completion(.failure(SpotError.favAlreadyFaved)) }
            return completion(.success(true))
        }
    }

    static func deleteSubscriptions(subscriptions: [CKSubscription]?, database: CKDatabase, completion: @escaping (Result<Bool, Error>) -> Void ) {
        // ATTENTION PERSONALIZE ERROR
        guard let subscriptions = subscriptions else { return completion(.failure(SpotError.favAlreadyFaved)) }
        let myGroup = DispatchGroup()
        for subscription in subscriptions {
            myGroup.enter()
            database.delete(withSubscriptionID: subscription.subscriptionID) { _, error in
                guard error == nil else { return completion(.failure(error!)) }
                myGroup.leave()
            }
        }
        myGroup.notify(queue: .main) {
            completion(.success(true))
        }
    }
}

private extension SubscriptionManager {
    func saveToUserDefaults(subscriptions: [String]) {
    }

    func getFromUserDefaults() -> [String] {
        return []
    }
}
