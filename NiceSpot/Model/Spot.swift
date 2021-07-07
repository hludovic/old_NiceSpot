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

    init(id: String, date: Date, title: String, category: Spot.Category,
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
        if result.count > 0 {
            return true
        } else { return false}
    }

    static func getAll(context: NSManagedObjectContext = viewContext, completion: @escaping (Result<[Spot], SpotErrors>) -> Void) {
        let request: NSFetchRequest<SpotMO> = SpotMO.fetchRequest()
        let sort = NSSortDescriptor(key: "creationDate", ascending: false)
        request.sortDescriptors = [sort]
        do {
            let spotsFetched = try context.fetch(request)
            var result: [Spot] = []
            for spotFetched in spotsFetched {
                guard let spoty = managedObjectToSpot(spotFetched) else {  return completion(.failure(.failReadingSpotsMO)) }
                result.append(spoty)
            }
            return completion(.success(result))
        } catch {
            return completion(.failure(.failFetchingSpotsMO))
        }
    }

//    static func getAllFavorite(context: NSManagedObjectContext = viewContext, @escaping ()

    func searchSpots() {
    }

    func refresh() {
    }

    func setFavorite(context: NSManagedObjectContext = viewContext, _ favorite: Bool) {
    }
}

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

    func getSpot(context: NSManagedObjectContext = viewContext, id: String) -> Spot? {
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
        if let fetchedFavoriteIDs = try? context.fetch(request) {
            var result: [String] = []
            for fetchedFavoriteID in fetchedFavoriteIDs {
                guard let favorite = fetchedFavoriteID.spotID else { return [] }
                result.append(favorite)
            }
            return result
        } else { return [] }
    }

    func saveToFavorite() {
    }

    func removeToFavorite() {
    }
}

// MARK: - Errors

enum SpotErrors: Error {
    case failReadingSpotsMO
    case failFetchingSpotsMO
}

extension SpotErrors: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .failReadingSpotsMO:
            return NSLocalizedString("ERROR", comment: "")
        case .failFetchingSpotsMO:
            return NSLocalizedString("ERROR", comment: "")
        }
    }
}
