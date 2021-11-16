//
//  ProjectErrors.swift
//  NiceSpot
//
//  Created by Ludovic HENRY on 21/10/2021.
//

import Foundation

// MARK: - Spot Errors

enum SpotError: Error {
    case failReadingSpotCK
    case failReadingSpotMOWhenConvert
    case readFavoriteMOWhenGettingFavoriteMO
    case readSpotMOWhenGettingSpot
    case readFavoriteInGetFav
    case noSpotsToSave
    case searchSpotWrongName
    case unfavAlreadyUnfaved
    case favAlreadyFaved
}

extension SpotError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .failReadingSpotCK:
            return NSLocalizedString("Error reading a spot fetched", comment: "")
        case .noSpotsToSave:
            return NSLocalizedString("Fail SaveSpots, passing empty spots to save", comment: "")
        case .failReadingSpotMOWhenConvert:
            return NSLocalizedString("Fail reading spotMO when converting SpotMO to Spot", comment: "")
        case .searchSpotWrongName:
            return NSLocalizedString("The word used to search a spot is wrong", comment: "")
        case .readSpotMOWhenGettingSpot:
            return NSLocalizedString("Fail reading spotMO when converting when Getting Getting a spot", comment: "")
        case .readFavoriteInGetFav:
            return NSLocalizedString("Unable to read the favorite ID when getting the favorites", comment: "")
        case .unfavAlreadyUnfaved:
            return NSLocalizedString("Fail unfav a spot that's already unfaved", comment: "")
        case .favAlreadyFaved:
            return NSLocalizedString("Fail fav a spot that's already faved", comment: "")
        case .readFavoriteMOWhenGettingFavoriteMO:
            return NSLocalizedString("Fail Reading FavoriteMO when getting a FavoriteMO", comment: "")
        }
    }
}

// MARK: - SubscriptionManager Errors

enum SubscriptionError: Error {
    case fetchRetunsNil
    case failGetSubscriptions
}

extension SubscriptionError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .fetchRetunsNil:
            return NSLocalizedString("The fetch Subscription returns Nil value", comment: "")
        case .failGetSubscriptions:
            return NSLocalizedString("Fail to get subscriptions from UserDefaults ", comment: "")
        }
    }
}
