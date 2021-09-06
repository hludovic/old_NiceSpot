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
    private static let viewContext = PersistenceController.shared.container.viewContext

    private init(id: String, date: Date, title: String, category: Spot.Category,
                 detail: String, longitude: Double, latitude: Double,
                 picture: String, municipality: Spot.Municipality) {
        self.recordID = id
        self.creationDate = date
        self.title = title
        self.detail = detail
        self.category = category
        self.longitude = longitude
        self.latitude = latitude
        self.pictureName = picture
        self.municipality = municipality
    }

    func isFavorite(context: NSManagedObjectContext = viewContext) -> Bool {
        let request: NSFetchRequest<FavoriteMO> = FavoriteMO.fetchRequest()
        let predicate = NSPredicate(format: "spotID == %@", self.recordID)
        request.predicate = predicate
        guard let result = try? context.fetch(request) else { return false }
        if result.count > 0 { return true }
        return false
    }

    static func getAll(context: NSManagedObjectContext = viewContext) -> [Spot] {
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

    static func getAllFavorite(context: NSManagedObjectContext = viewContext) -> [Spot] {
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

    func saveToFavorite(context: NSManagedObjectContext = viewContext) -> Bool {
        guard !isFavorite(context: context) else { return false }
        let favoriteMO = FavoriteMO(context: context)
        favoriteMO.spotID = self.recordID
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

// MARK: - Private Methods

private extension Spot {

    static func managedObjectToSpot(_ spotMO: SpotMO) -> Spot? {
        guard
            let spotID = spotMO.recordID,
            let date = spotMO.creationDate,
            let title = spotMO.title,
            let detail = spotMO.detail,
            let categoryString = spotMO.category,
            let pictureName = spotMO.pictureName,
            let municipalityString = spotMO.municipality
        else { return nil }
        let spot = Spot(id: spotID,
                        date: date,
                        title: title,
                        category: Spot.Category(rawValue: categoryString) ?? .unknown,
                        detail: detail,
                        longitude: spotMO.longitude,
                        latitude: spotMO.latitude,
                        picture: pictureName,
                        municipality: Spot.Municipality(rawValue: municipalityString) ?? .unknown
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
