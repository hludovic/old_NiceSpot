//
//  Spot+Extensions.swift
//  NiceSpot
//
//  Created by Ludovic HENRY on 06/07/2021.
//

import Foundation

// MARK: - Enum

extension Spot {

    // The list of categories in which a spot can be placed.
    enum Category: String, CaseIterable {
        case unknown = "Unknown"
        case beach = "Beach"
        case mountain = "Mountain"
        case river = "River"
        case waterfall = "Waterfall"
    }

    // The list of municipalities in which a spot can be found.
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

enum SpotError: Error {
    case failReadingSpotCK
    case failSaveSpot
    case noSpotsToSave
}

extension SpotError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .failReadingSpotCK:
            return NSLocalizedString("Error reading a spot fetched", comment: "")
        case .noSpotsToSave:
            return NSLocalizedString("Fail SaveSpots, passing empty spots to save", comment: "")
        case .failSaveSpot:
            return NSLocalizedString("Fail saving a spot", comment: "")
        }
    }
}
