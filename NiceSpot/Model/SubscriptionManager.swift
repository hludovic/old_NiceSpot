//
//  SubscriptionManager.swift
//  NiceSpot
//
//  Created by Ludovic HENRY on 19/10/2021.
//

import Foundation
import CloudKit
import UIKit

/// Subscribe user to notifications
class SubscriptionManager {

    // MARK: - private Properties

    private static let KeyUserDefault: String = "userSubscriptions"
    private static let database = PersistenceController.publicCKDB

    private init() {}

    // MARK: - Public Methods

    /// Saves a subscription Array on Cloudkit, then on UserDefaults.
    /// - Parameters:
    ///   - subscriptions: The list of Spot.Category that will have to be saved.
    ///   - database: The CloudKit database that will have to be used for the save.
    ///   - completion: Returns True if the operation is successful or an error if it fails.
    static func subscribe(subscriptions: [Spot.Category], database: CKDatabase = database, completion: @escaping (Result<Bool, Error>) -> Void) {
        database.fetchAllSubscriptions { fetchedSubscriptions, error in
            guard error == nil else { return completion(Result.failure(error!)) }
            guard let fetchedSubscriptions = fetchedSubscriptions else { return completion(Result.failure(SubscriptionError.fetchRetunsNil)) }
            deleteSubscriptionsCK(subscriptions: fetchedSubscriptions, database: database) { result in
                if case .failure(let error) = result { return completion(Result.failure(error)) }
                saveSubscriptionsCK(subscriptions: subscriptions, database: database) { result in
                    switch result {
                    case .failure(let error):
                        return completion(Result.failure(error))
                    case .success:
                        saveSubscriptionsUD(subscriptions: subscriptions)
                        completion(Result.success(true))
                    }
                }
            }
        }
    }

    /// Retrieves subscriptions saved in UserDefaults.
    /// - Returns: An Array of subscriptions or an Error if the recovery fails.
    static func getSubscriptionsUD() -> Result<[String], Error> {
        let defaults = UserDefaults.standard
        guard let result = defaults.value(forKey: KeyUserDefault) as? [String] else {
            return Result.failure(SubscriptionError.failGetSubscriptions)
        }
        return Result.success(result)
    }

    static func deleteSubscriptionsUD() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: KeyUserDefault)
    }

}

private extension SubscriptionManager {

    static func saveSubscriptionsUD(subscriptions: [Spot.Category]) {
        let defaults = UserDefaults.standard
        var subscriptionsString: [String] = []
        for subscription in subscriptions {
            subscriptionsString.append(subscription.rawValue)
        }
        defaults.set(subscriptionsString, forKey: KeyUserDefault )
    }

    static func saveSubscriptionsCK(subscriptions: [Spot.Category], database: CKDatabase, completion: @escaping (Result<Bool, Error>) -> Void) {
        let dispatchGroup = DispatchGroup()
        for subscription in subscriptions {
            dispatchGroup.enter()
            let predicate = NSPredicate(format: "category = %@", subscription.rawValue)
            let subsciption = CKQuerySubscription(recordType: "SpotCK", predicate: predicate, options: .firesOnRecordCreation)
            let notification = CKSubscription.NotificationInfo()
            notification.alertBody = "Added a new \(subscription) in the base"
            notification.soundName = "default"
            subsciption.notificationInfo = notification
            database.save(subsciption) { _, error in
                if let error = error { return completion(.failure(error)) }
            }
            dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: .main) { return completion(.success(true)) }
    }

    static func deleteSubscriptionsCK(subscriptions: [CKSubscription], database: CKDatabase, completion: @escaping (Result<Bool, Error>) -> Void) {
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
