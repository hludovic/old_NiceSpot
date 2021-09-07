//
//  Spot.swift
//  NiceSpot
//
//  Created by Ludovic HENRY on 06/07/2021.
//

import Foundation
import CoreData

class Spot {
    let recordID: String
    let creationDate: Date
    let title: String
    let detail: String
    let category: Spot.Category
    let longitude: Double
    let latitude: Double
    let pictureName: String
    let municipality: Spot.Municipality
    let recordChangeTag: String
    private static let viewContext = PersistenceController.shared.container.viewContext

    private init(id: String,
                 date: Date,
                 title: String,
                 category: Spot.Category,
                 detail: String,
                 longitude: Double,
                 latitude: Double,
                 picture: String,
                 municipality: Spot.Municipality,
                 sha: String
    ) {
        self.recordID = id
        self.creationDate = date
        self.title = title
        self.detail = detail
        self.category = category
        self.longitude = longitude
        self.latitude = latitude
        self.pictureName = picture
        self.municipality = municipality
        self.recordChangeTag = sha
    }

    func isFavorite(context: NSManagedObjectContext = viewContext) -> Bool {
        let request: NSFetchRequest<FavoriteMO> = FavoriteMO.fetchRequest()
        let predicate = NSPredicate(format: "spotID == %@", self.recordID)
        request.predicate = predicate
        guard let result = try? context.fetch(request) else { return false }
        if result.count > 0 { return true }
        return false
    }

    static func getSpots(context: NSManagedObjectContext = viewContext) -> [Spot] {
        let request: NSFetchRequest<SpotMO> = SpotMO.fetchRequest()
        let sort = NSSortDescriptor(key: "creationDate", ascending: false)
        request.sortDescriptors = [sort]
        guard let spotsFetched = try? context.fetch(request) else { return [] }
        var result: [Spot] = []
        for spotFetched in spotsFetched {
            guard let spoty = managedObjectToSpot(spotFetched) else { return [] }
            result.append(spoty)
        }
        return result
    }

    static func getFavorites(context: NSManagedObjectContext = viewContext) -> [Spot] {
        let favoriteIDs = getFavoriteIDs(context: context)
        guard favoriteIDs.count > 0 else { return [] }
        var result: [Spot] = []
        for favoriteId in favoriteIDs {
            guard let spot = getSpot(context: context, id: favoriteId) else { return [] }
            result.append(spot)
        }
        return result
    }

    static func searchSpots(context: NSManagedObjectContext, titleContains: String) -> [Spot] {
        guard (titleContains != "") && (titleContains != " ") else {return [] }
        let request: NSFetchRequest<SpotMO> = SpotMO.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", titleContains)
        request.predicate = predicate
        guard  let fetchedSpots = try? context.fetch(request) else { return [] }
        var result: [Spot] = []
        for fetchedSpot in fetchedSpots {
            guard let resultItem = managedObjectToSpot(fetchedSpot) else { return [] }
            result.append(resultItem)
        }
        return result
    }

    func saveToFavorite(context: NSManagedObjectContext = viewContext, date: Date = Date()) -> Bool {
        guard !isFavorite(context: context) else { return false }
        let favoriteMO = FavoriteMO(context: context)
        favoriteMO.spotID = self.recordID
        favoriteMO.dateStarred = date
        do {
            try context.save()
        } catch {
            return false
        }
        return true
    }

    func removeToFavorite(context: NSManagedObjectContext = viewContext) -> Bool {
        guard isFavorite(context: context) else { return false }
        guard let favoriteMO = getFavoriteMO(context: context, id: self.recordID) else { return false }
        context.delete(favoriteMO)
        do {
            try context.save()
        } catch {
            return false
        }
        return true
    }
}

// MARK: - Private Methods CoreData

private extension Spot {

    static func managedObjectToSpot(_ spotMO: SpotMO) -> Spot? {
        guard
            let spotID = spotMO.recordID,
            let date = spotMO.creationDate,
            let title = spotMO.title,
            let detail = spotMO.detail,
            let categoryString = spotMO.category,
            let pictureName = spotMO.pictureName,
            let municipalityString = spotMO.municipality,
            let recordChangeTag = spotMO.recordChangeTag
        else { return nil }
        let spot = Spot(id: spotID,
                        date: date,
                        title: title,
                        category: Spot.Category(rawValue: categoryString) ?? .unknown,
                        detail: detail,
                        longitude: spotMO.longitude,
                        latitude: spotMO.latitude,
                        picture: pictureName,
                        municipality: Spot.Municipality(rawValue: municipalityString) ?? .unknown,
                        sha: recordChangeTag
        )
        return spot
    }

    func getFavoriteMO(context: NSManagedObjectContext = viewContext, id: String) -> FavoriteMO? {
        let request: NSFetchRequest<FavoriteMO> = FavoriteMO.fetchRequest()
        let predicate = NSPredicate(format: "spotID == %@", id)
        request.predicate = predicate
        guard let result = try? context.fetch(request)else { return nil }
        guard let favoriteMO = result.first else { return nil }
        return favoriteMO
    }

    static func getSpot(context: NSManagedObjectContext = viewContext, id: String) -> Spot? {
        let request: NSFetchRequest<SpotMO> = SpotMO.fetchRequest()
        let predicate = NSPredicate(format: "recordID == %@", id)
        request.predicate = predicate
        guard let result = try? context.fetch(request), result.count > 0 else { return nil }
        guard let spotMO = result.first else { return nil }
        guard let spot = Spot.managedObjectToSpot(spotMO) else { return nil }
        return spot
    }

    static func getFavoriteIDs(context: NSManagedObjectContext = viewContext) -> [String] {
        let request: NSFetchRequest<FavoriteMO> = FavoriteMO.fetchRequest()
        let sort = NSSortDescriptor(key: "dateStarred", ascending: true)
        request.sortDescriptors = [sort]
        var result: [String] = []
        if let fetchedFavoriteIDs = try? context.fetch(request) {
            for fetchedFavoriteID in fetchedFavoriteIDs {
                guard let favorite = fetchedFavoriteID.spotID else { return [] }
                result.append(favorite)
            }
        }
        return result
    }

}

// MARK: - Private Methods CloudKit

extension Spot {

    static func fetchSpots(completion: @escaping ([Spot]) -> Void) {
        let predicate = NSPredicate(value: true)
        let querry = CKQuery(recordType: "SpotCK", predicate: predicate)
        let operation = CKQueryOperation(query: querry)
        operation.desiredKeys = ["title", "detail", "category", "location", "municipality", "pictureName"]
        var newSpotsCK: [Spot] = []
        operation.recordFetchedBlock = { record in
            guard
                let date = record.creationDate,
                let title = record["title"] as? String,
                let detail = record["detail"] as? String,
                let recordChangeTag = record.recordChangeTag,
                let category = record["category"] as? String,
                let location = record["location"] as? CLLocation,
                let pictureName = record["pictureName"] as? String,
                let municipality = record["municipality"] as? String
            else { return completion([]) }
            let spotFetched = Spot(id: record.recordID.recordName,
                              date: date,
                              title: title,
                              category: Spot.Category(rawValue: category) ?? .unknown,
                              detail: detail,
                              longitude: location.coordinate.longitude,
                              latitude: location.coordinate.latitude,
                              picture: pictureName,
                              municipality: Spot.Municipality(rawValue: municipality) ?? .unknown,
                              sha: recordChangeTag
            )
            newSpotsCK.append(spotFetched)
        }
        operation.queryCompletionBlock = { (_, error) in
            guard error == nil else { return completion([]) }
            completion(newSpotsCK)
        }
        PersistenceController.publicCKDB.add(operation)
    }

    func saveSpot(context: NSManagedObjectContext = viewContext) -> Bool {
        let spotMO = SpotMO(context: context)
        spotMO.recordID = self.recordID
        spotMO.creationDate = self.creationDate
        spotMO.title = self.title
        spotMO.detail = self.detail
        spotMO.longitude = self.longitude
        spotMO.latitude = self.latitude
        spotMO.category = self.category.rawValue
        spotMO.municipality = self.municipality.rawValue
        spotMO.pictureName = self.pictureName
        spotMO.recordChangeTag = self.recordChangeTag
        do {
            try context.save()
        } catch {
            return false
        }
        print("OKER")
        return true
    }

}
