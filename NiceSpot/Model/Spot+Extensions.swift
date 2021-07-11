//
//  Spot+Extensions.swift
//  NiceSpot
//
//  Created by Ludovic HENRY on 06/07/2021.
//

import Foundation

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

enum SpotError: Error {
    case failReadingSpotsMO
    case failFetchingSpotsMO
    case failSavingFavoriteMO
}

extension SpotError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .failReadingSpotsMO:
            return NSLocalizedString("ERROR", comment: "")
        case .failFetchingSpotsMO:
            return NSLocalizedString("ERROR", comment: "")
        case .failSavingFavoriteMO:
            return NSLocalizedString("ERROR", comment: "")
        }
    }
}
