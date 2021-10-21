//
//  Spot.swift
//  NiceSpot
//
//  Created by Ludovic HENRY on 06/07/2021.
//

import Foundation
import CoreData
import CloudKit

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
        return result.count > 0 ? true : false
    }

    static func getSpots(context: NSManagedObjectContext = viewContext, completion: @escaping (Result<[Spot], Error>) -> Void) {
        let request: NSFetchRequest<SpotMO> = SpotMO.fetchRequest()
        let sort = NSSortDescriptor(key: "creationDate", ascending: false)
        request.sortDescriptors = [sort]
        let spotsFetched: [SpotMO]
        do {
            spotsFetched = try context.fetch(request)
        } catch let error {
            return completion(.failure(error))
        }
        var result: [Spot] = []
        for spotFetched in spotsFetched {
            switch managedObjectToSpot(spotFetched) {
            case .failure(let error ):
                return completion(.failure(error))
            case .success(let convertedSpot):
                result.append(convertedSpot)
            }
        }
        return completion(.success(result))
    }

    static func getFavorites(context: NSManagedObjectContext = viewContext, completion: @escaping (Result<[Spot], Error>) -> Void) {
        var result: [Spot] = []
        switch getFavoriteIDs(context: context) {
        case .failure(let error):
            return completion(.failure(error))
        case .success(let favoriteIDs):
            guard favoriteIDs.count > 0 else { return completion(.success([])) }
            for favoriteID in favoriteIDs {
                switch getSpot(context: context, id: favoriteID) {
                case .failure(let error):
                    return completion(.failure(error))
                case .success(let spot):
                    result.append(spot)
                }
            }
            return completion(.success(result))
        }
    }

    static func searchSpots(context: NSManagedObjectContext, titleContains: String) -> Result<[Spot], Error> {
        guard (titleContains != "") && (titleContains != " ") else {return .failure(SpotError.searchSpotWrongName) }
        let request: NSFetchRequest<SpotMO> = SpotMO.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", titleContains)
        let fetchedSpots: [SpotMO]
        request.predicate = predicate
        do {
            fetchedSpots = try context.fetch(request)
        } catch let error {
            return .failure(error)
        }
        var result: [Spot] = []
        for fetchedSpot in fetchedSpots {
            switch managedObjectToSpot(fetchedSpot) {
            case .failure(let error):
                return .failure(error)
            case .success(let convertedSpot):
                result.append(convertedSpot)
            }
        }
        return .success(result)
    }

    func saveToFavorite(context: NSManagedObjectContext = viewContext, date: Date = Date()) -> Result<Bool, Error> {
        guard !isFavorite(context: context) else { return Result.failure(SpotError.favAlreadyFaved) }
        let favoriteMO = FavoriteMO(context: context)
        favoriteMO.spotID = self.recordID
        favoriteMO.dateStarred = date
        do {
            try context.save()
        } catch let error {
            return Result.failure(error)
        }
        return Result.success(true)
    }

    func removeToFavorite(context: NSManagedObjectContext = viewContext) -> Result<Bool, Error> {
        guard isFavorite(context: context) else { return Result.failure(SpotError.unfavAlreadyUnfaved) }
        switch getFavoriteMO(context: context, id: self.recordID) {
        case .failure(let error):
            return Result.failure(error)
        case .success(let favoriteMO):
            context.delete(favoriteMO)
            do {
                try context.save()
            } catch let saveError {
                return Result.failure(saveError)
            }
        }
        return .success(true)
    }

    static func refreshSpots(context: NSManagedObjectContext = viewContext, completion: @escaping (Result<Bool, Error>) -> Void) {
        Spot.fetchSpots { result in
            switch result {
            case .failure(let error):
                return completion(Result.failure(error))
            case .success(let spots):
                Spot.saveSpots(context: context, spots: spots) { result in
                    switch result {
                    case .failure(let error):
                        return completion(.failure(error))
                    case .success(let success):
                        return completion(.success(success))
                    }
                }
            }
        }
    }

}

// MARK: - Private Methods CoreData

private extension Spot {

    static func managedObjectToSpot(_ spotMO: SpotMO) -> Result<Spot, Error> {
        guard
            let spotID = spotMO.recordID,
            let date = spotMO.creationDate,
            let title = spotMO.title,
            let detail = spotMO.detail,
            let categoryString = spotMO.category,
            let pictureName = spotMO.pictureName,
            let municipalityString = spotMO.municipality,
            let recordChangeTag = spotMO.recordChangeTag
        else { return .failure(SpotError.failReadingSpotMOWhenConvert) }
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
        return .success(spot)
    }

    func getFavoriteMO(context: NSManagedObjectContext, id: String) -> Result<FavoriteMO, Error> {
        let request: NSFetchRequest<FavoriteMO> = FavoriteMO.fetchRequest()
        let predicate = NSPredicate(format: "spotID == %@", id)
        request.predicate = predicate
        let resultMO: [FavoriteMO]
        do {
            resultMO = try context.fetch(request)
        } catch let error {
            return .failure(error)
        }
        guard let result = resultMO.first else { return .failure(SpotError.readFavoriteMOWhenGettingFavoriteMO) }
        return .success(result)
    }

    static func getSpot(context: NSManagedObjectContext, id: String) -> Result<Spot, Error> {
        let request: NSFetchRequest<SpotMO> = SpotMO.fetchRequest()
        let predicate = NSPredicate(format: "recordID == %@", id)
        request.predicate = predicate
        let result: [SpotMO]
        do {
            result = try context.fetch(request)
        } catch let error {
            return .failure(error)
        }
        guard let spotMO: SpotMO = result.first else { return.failure(SpotError.readSpotMOWhenGettingSpot) }
        switch Spot.managedObjectToSpot(spotMO) {
        case .failure(let error):
            return .failure(error)
        case .success(let convertedSpot):
            return .success(convertedSpot)
        }
    }

    static func getFavoriteIDs(context: NSManagedObjectContext) -> Result<[String], Error> {
        let request: NSFetchRequest<FavoriteMO> = FavoriteMO.fetchRequest()
        let sort = NSSortDescriptor(key: "dateStarred", ascending: true)
        request.sortDescriptors = [sort]
        var result: [String] = []
        let fetchedFavoriteIds: [FavoriteMO]
        do {
            fetchedFavoriteIds = try context.fetch(request)
        } catch let error {
            return .failure(error)
        }
        for fetchedFavoriteID in fetchedFavoriteIds {
            guard let favorite = fetchedFavoriteID.spotID else { return .failure(SpotError.readFavoriteInGetFav)}
            result.append(favorite)
        }
        return .success(result)
    }

}

// MARK: - CloudKit

private extension Spot {

    static func fetchSpots(completion: @escaping (Result<[Spot], Error>) -> Void ) {
        let predicate = NSPredicate(value: true)
        let querry = CKQuery(recordType: "SpotCK", predicate: predicate)
        let operation = CKQueryOperation(query: querry)
        operation.desiredKeys = ["title", "detail", "category", "location", "municipality", "pictureName"]
        var newSpotsCK: [Spot] = []
        // - recordMatchedBlock -
        operation.recordMatchedBlock = { recordID, recordResult in
            switch recordResult {
            case .failure(let error ):
                return completion(Result.failure(error))
            case .success(let ckrecord):
                guard
                    let date = ckrecord.creationDate,
                    let title = ckrecord["title"] as? String,
                    let detail = ckrecord["detail"] as? String,
                    let recordChangeTag = ckrecord.recordChangeTag,
                    let category = ckrecord["category"] as? String,
                    let location = ckrecord["location"] as? CLLocation,
                    let pictureName = ckrecord["pictureName"] as? String,
                    let municipality = ckrecord["municipality"] as? String
                else { return completion(Result.failure(SpotError.failReadingSpotCK)) }
                let spotFetched = Spot(id: recordID.recordName,
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
        }
        // - querryResultBlock -
        operation.queryResultBlock = { operationResult in
            switch operationResult {
            case .failure( let error ):
                return completion(Result.failure(error))
            case .success:
                return completion(Result.success(newSpotsCK))
            }
        }
        // - run the operation -
        PersistenceController.publicCKDB.add(operation)
    }

    static func saveSpots(context: NSManagedObjectContext, spots: [Spot], completion: @escaping (Result<Bool, Error>) -> Void) {
        guard spots.count > 0 else { return completion(Result.failure(SpotError.noSpotsToSave)) }
        let dispatchGroup = DispatchGroup()
        for spot in spots {
            dispatchGroup.enter()
            spot.saveSpot(context: context) { result in
                if case Result.failure(let error) = result {
                    return completion(Result.failure(error))
                }
            }
            dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: .main) {
            return completion(Result.success(true))
        }
    }

    func saveSpot(context: NSManagedObjectContext, completion: @escaping (Result<Bool, Error>) -> Void) {
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
        } catch let error {
            return completion(Result.failure(error))
        }
        return completion(Result.success(true))
    }

}
