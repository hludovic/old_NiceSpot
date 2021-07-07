//
//  SpotTests.swift
//  NiceSpotTests
//
//  Created by Ludovic HENRY on 06/07/2021.
//

import XCTest
import CoreData
@testable import NiceSpot

class SpotTests: XCTestCase {
    var viewContext: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        self.viewContext = PersistenceController.tests.container.viewContext
    }

    override func tearDown() {
        TestableData.clearData()
        super.tearDown()
    }

    func testSavedAnOldSpot_WenGetAllSpots_TheNewSpotSavedOnLast() {
        // Given
        TestableData.saveFakeSpots()
        let date = TestableData.getDate(year: 1900, month: 01, day: 1)
        TestableData.saveFakeSpot(date: date, category: "blabla", municipality: "blabla")
        // When
        Spot.getAll(context: viewContext) { result in
            switch result {
            // Then
            case .failure(let error):
                XCTAssertNil(error)
            case .success(let spots):
                XCTAssertEqual(4, spots.count)
                XCTAssertEqual("NewSpot", spots.last?.title)
            }
        }
    }

    func testSavedAnRecentSpot_WhenGetAllSpots_ThenNewSpotSavedOnFirst() {
        // Given
        TestableData.saveFakeSpots()
        let date = TestableData.getDate(year: 2021, month: 01, day: 1)
        TestableData.saveFakeSpot(date: date, category: "blabla", municipality: "blabla")
        // When
        Spot.getAll(context: viewContext) { result in
            switch result {
            // Then
            case .failure(let error):
                XCTAssertNil(error)
            case .success(let spots):
                XCTAssertEqual(4, spots.count)
                XCTAssertEqual("NewSpot", spots.first?.title)
            }
        }
    }

    func testSavedAWrongCategorySpot_WhenGetTheSpot_ThenCategoryIsUnknown() {
        // Given
        TestableData.saveFakeSpot(date: Date(), category: "blabla", municipality: "blabla")
        // When
        Spot.getAll(context: viewContext) { result in
            switch result {
            // Then
            case .failure(let error):
                XCTAssertNil(error)
            case .success(let spots):
                XCTAssertEqual(1, spots.count)
                XCTAssertEqual(Spot.Category.unknown, spots.first?.category)
                XCTAssertEqual(Spot.Municipality.unknown, spots.first?.municipality)
            }
        }
    }

    func testIsfavorite() {
        TestableData.saveFakeSpots()
        Spot.getAll(context: viewContext) { result in
            switch result {
            // Then
            case .failure(let error):
                XCTAssertNil(error)
            case .success(let spots):
                XCTAssertEqual(3, spots.count)
                XCTAssertEqual(false, spots.first?.isFavorite(context: self.viewContext))
            }
        }
    }

//    func testGOGOGOG() {
//        // Given
//        TestableData.saveFakeSpots()
//        // When
//        Spot.getAll(context: viewContext) { result in
//            switch result {
//            // Then
//            case .failure(let error):
//                XCTAssertNil(error)
//            case .success(let spots):
//                print("❌\(spots.first?.isFavorite())")
//            }
//        }
//    }

//    func testGOGOGOG2() {
//        // Given
//        TestableData.saveFakeSpots()
//        Spot.getAll(context: viewContext) { result in
//            switch result {
//            // Then
//            case .failure(let error):
//                XCTAssertNil(error)
//            case .success(let spots):
//                XCTAssertEqual(3, spots.count)
//                print("🅾️\(spots.first?.recordID)")
//            }
//        }
//
//
//        let spot = Spot.getSpot(context: viewContext, id: "1D997030-81B2-7E64-4F62-87EAAD8EE7B3")
//        XCTAssertEqual(spot?.title, "La Cascade aux Ecrevisses")
//
//    }

}
