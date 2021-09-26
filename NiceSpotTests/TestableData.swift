//
//  TestableData.swift
//  NiceSpotTests
//
//  Created by Ludovic HENRY on 06/07/2021.
//

import Foundation
import CoreData
@testable import NiceSpot

class TestableData {

    // MARK: - Returns a personalized date

    static func getDate(year: Int, month: Int, day: Int) -> Date {
        var dateComponent = DateComponents()
        dateComponent.year = year
        dateComponent.month = month
        dateComponent.day = day
        
        let userCalendar = Calendar(identifier: .gregorian)
        let theDate = userCalendar.date(from: dateComponent) ?? Date()
        return theDate
    }
    
    // MARK: - Clear all spots saved

    static func clearData(completion: @escaping (Bool) -> Void) {
        clearSpots { clearedSpots in
            guard clearedSpots else { return completion(false) }
            clearFavorites { clearedFavodites in
                guard clearedFavodites else { return completion(false) }
                return completion(true)
            }
        }
    }
    
    private static func clearSpots(completion: @escaping (Bool) -> Void) {
        let fetchRequest: NSFetchRequest<SpotMO> = SpotMO.fetchRequest()
        let objs = try! PersistenceController.tests.container.viewContext.fetch(fetchRequest)
        for case let obj as NSManagedObject in objs {
            PersistenceController.tests.container.viewContext.delete(obj)
        }
        do {
            try PersistenceController.tests.container.viewContext.save()
        } catch {
            return completion(false)
        }
        return completion(true)
    }

    private static func clearFavorites(completion: @escaping (Bool) -> Void) {
        let fetchRequest: NSFetchRequest<FavoriteMO> = FavoriteMO.fetchRequest()
        let objs = try! PersistenceController.tests.container.viewContext.fetch(fetchRequest)
        for case let obj as NSManagedObject in objs {
            PersistenceController.tests.container.viewContext.delete(obj)
        }
        do {
            try PersistenceController.tests.container.viewContext.save()
        } catch {
            return completion(false)
        }
        return completion(true)
    }

    // MARK: - Save a spot with a personalized content

    static func saveFakeSpot(date: Date, category: String, municipality: String) {
        let context = PersistenceController.tests.container.viewContext
        let spot = SpotMO(context: context)
        spot.category = category
        spot.detail = "Detail Spot Detail Spot Detail"
        spot.recordID = "1D997030-81B2-1111-4F62-87EAAD8EE7B3"
        spot.latitude = 11111.112
        spot.longitude = -111111.221
        spot.municipality = municipality
        spot.pictureName = "newSpot"
        spot.title = "NewSpot"
        spot.creationDate = date
        spot.recordChangeTag = "AAAV"
        
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    static func saveFakeSpot(title: String, sha: String) {
        let context = PersistenceController.tests.container.viewContext
        let spot = SpotMO(context: context)
        spot.category = Spot.Category.waterfall.rawValue
        spot.detail = "Detail Spot Detail Spot Detail"
        spot.recordID = "1D997030-81B2-1111-4F62-87EAAD8EE7B3"
        spot.latitude = 11111.112
        spot.longitude = -111111.221
        spot.municipality = Spot.Municipality.lamentin.rawValue
        spot.pictureName = "newSpot"
        spot.title = title
        spot.creationDate = Date()
        spot.recordChangeTag = sha
        
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }


    // MARK: - Save tree spots

    static func saveFakeSpots() {
        let context = PersistenceController.tests.container.viewContext
        
        // -- La Cascade aux Ecrevisses --
        
        let cascecr = SpotMO(context: context)
        cascecr.category = Spot.Category.waterfall.rawValue
        cascecr.detail = """
Située sur la route de la Traversée sur Basse Terre, à un kilomètre de la Maison de la Forêt, cette petite cascade d’environ 10 mètres de hauteur est très facile d’accès. Un parking permet de vous stationner, où est également implanté un plan du tracé ainsi qu’un descriptif des espèces que vous pourrez rencontrer sur le parcours.
Un chemin ombragé par une végétation luxuriante, entièrement balisé le long de la rivière Corossol, vous emmènera en seulement une dizaine de minutes, face à cette jolie cascade en pleine forêt tropicale. Accessible à tous, il n’est pas nécessaire d’être bon marcheur pour aller voir la cascade aux Écrevisses, même les plus petits pourront y accéder sans aucun problème.
"""
        cascecr.recordID = "1D997030-81B2-7E64-4F62-87EAAD8EE7B3"
        cascecr.latitude = 16.179118967390906
        cascecr.longitude = -61.68083214438678
        cascecr.municipality = Spot.Municipality.petitBourg.rawValue
        cascecr.pictureName = "cascecr_1_GqbzwSMC4"
        cascecr.title = "La Cascade aux Ecrevisses New"
        cascecr.creationDate = TestableData.getDate(year: 2020, month: 06, day: 01)
        cascecr.recordChangeTag = "kkyd889w"

        // -- La Plage de l’Anse Rifflet --

        let rifflet = SpotMO(context: context)
        rifflet.category = Spot.Category.beach.rawValue
        rifflet.detail = """
La plage de l’Anse Rifflet se situe au nord de la belle Basse Terre. A une poignée de kilomètres de la bourgade de Deshaies, il faut tourner à gauche, dans une descente (panneau) pour y accéder.

Elle se trouve juste à côté de la très belle plage de la Perle. Les lieux ne sont pas connus du tourisme de masse. Ceux-ci préfèrent aller sur la jolie mais bien plus fréquentée plage de Grande Anse.

La plage de l’Anse Rifflet appelle au farniente et à la contemplation. Impossible de rater vos photos de cette plage, les lieux sont tout droit sortis d’une carte postale.
"""
        rifflet.recordID = "90182901387409184370192"
        rifflet.latitude = 16.336675
        rifflet.longitude = -61.785863
        rifflet.municipality = Spot.Municipality.deshaies.rawValue
        rifflet.pictureName = "rifflet"
        rifflet.title = "La Plage de l’Anse Rifflet New"
        rifflet.creationDate = TestableData.getDate(year: 2020, month: 01, day: 01)
        rifflet.recordChangeTag = "BBB22"

        // -- La Plage de la Caravelle --
        
        let caravelle = SpotMO(context: context)
        caravelle.category = Spot.Category.beach.rawValue
        caravelle.detail = """
Assurément une des plus belles plages en Guadeloupe ! La plage de la Caravelle, qui se trouve à Sainte-Anne, fait en effet figure de référence en terme de destination paradisiaque, puisqu’elle concentre tous les éléments qui la définissent comme les cocotiers toisant les touristes venus profiter des joies du sable blanc et des eaux cristallines, ainsi que des spots de plongée sous-marine ! Très fréquentée en raison de sa renommée, il est toutefois possible d’y profiter d’un moment de calme lors des douces soirées propres à la Guadeloupe.
"""
        caravelle.recordID = "075C8DEC-D2DB-D81C-43CC-B453D78E02E7"
        caravelle.latitude = 16.221350519784288
        caravelle.longitude = -61.39367191555051
        caravelle.municipality = Spot.Municipality.sainteAnne.rawValue
        caravelle.pictureName = "caravelle"
        caravelle.title = "La Plage de la Caravelle New"
        caravelle.creationDate = TestableData.getDate(year: 2020, month: 03, day: 01)
        caravelle.recordChangeTag = "CCC33"

        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }


}
