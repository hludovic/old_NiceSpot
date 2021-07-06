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
    var isFavorite: Bool {
        return false
    }

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

    static func getAll(context: NSManagedObjectContext, completion: @escaping (Result<[Spot], SpotErrors>) -> Void) {
        let request: NSFetchRequest<SpotMO> = SpotMO.fetchRequest()
        do {
            let spotsFetched = try context.fetch(request)
            var result: [Spot] = []
            for spotFetched in spotsFetched {
                guard
                    let spotID = spotFetched.recordID,
                    let date = spotFetched.creationDate,
                    let title = spotFetched.title,
                    let detail = spotFetched.detail,
                    let categoryString = spotFetched.category,
                    let pictureName = spotFetched.pictureName,
                    let municipalityString = spotFetched.municipality
                else { return completion(.failure(.failReadingSpotsMO)) }
                let spot = Spot(id: spotID,
                                date: date,
                                title: title,
                                category: Spot.Category(rawValue: categoryString) ?? .unknown,
                                detail: detail,
                                longitude: spotFetched.longitude,
                                latitude: spotFetched.latitude,
                                picture: pictureName,
                                municipality: Spot.Municipality(rawValue: municipalityString) ?? .unknown
                )
                result.append(spot)
            }
            return completion(.success(result))
        } catch {
            return completion(.failure(.failFetchingSpotsMO))
        }
        print("OK")
    }

    func searchSpots() {
    }

    func refresh() {
    }

    func setFavorite(_ favorite: Bool) {
    }
}

// MARK: - Enum

extension Spot {

    /// The list of categories in which a spot can be placed.
    enum Category: String, CaseIterable {
        case unknown = "Unknown"
        case beach = "Beach"
        case mountain = "Mountain"
        case river = "River"
        case waterfall = "Waterfall"
    }

    /// The list of municipalities in which a spot can be found.
    enum Municipality: String, CaseIterable {
        case unknown = "Unknown"
        case basseTerre = "Basse-Terre"
        case anseBertrand = "Anse-Bertrand"
        case baieMahault = "Baie-Mahault"
        case baillif = "Baillif"
        case bouillante = "Bouillante"
        case capesterreBelleEau = "Capesterre-Belle-Eau"
        case capesterreDeMarieGalante = "Capesterre-de-Marie-Galante"
        case deshaies = "Deshaies"
        case gourbeyre = "Gourbeyre"
        case goyave = "Goyave"
        case grandBourg = "Grand-Bourg"
        case desirade = "La Désirade"
        case lamentin = "Lamentin"
        case leGosier = "Le Gosier"
        case leMoule = "Le Moule"
        case lesAbymes = "Les Abymes"
        case morneALEau = "Morne-à-l'Eau"
        case petitBourg = "Petit-Bourg"
        case petitCanal = "Petit-Canal"
        case pointeNoire = "Pointe-Noire"
        case pointeAPitre = "Pointe-à-Pitre"
        case portLouis = "Port-Louis"
        case saintClaude = "Saint-Claude"
        case saintFrancois = "Saint-François"
        case saintLouis = "Saint-Louis"
        case sainteAnne = "Sainte-Anne"
        case sainteRose = "Sainte-Rose"
        case terreDeBas = "Terre-de-Bas"
        case terreDeHaut = "Terre-de-Haut"
        case troisRivieres = "Trois-Rivières"
        case vieuxFort = "Vieux-Fort"
        case vieuxHabitants = "Vieux-Habitants"
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
