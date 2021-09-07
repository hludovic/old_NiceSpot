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

    func testOldSpotSaved_WenGetAllSpots_TheNewSpotSavedOnLast() {
        // Given
        TestableData.saveFakeSpots()
        let date = TestableData.getDate(year: 1900, month: 01, day: 1)
        TestableData.saveFakeSpot(date: date, category: "blabla", municipality: "blabla")
        // When
        let spots = Spot.getSpots(context: viewContext)
        // Then
        XCTAssertEqual(4, spots.count)
        XCTAssertEqual("NewSpot", spots.last?.title)
    }

    func testSavedAnRecentSpot_WhenGetAllSpots_ThenNewSpotSavedOnFirst() {
        // Given
        TestableData.saveFakeSpots()
        let date = TestableData.getDate(year: 2021, month: 01, day: 1)
        TestableData.saveFakeSpot(date: date, category: "blabla", municipality: "blabla")
        // When
        let spots = Spot.getSpots(context: viewContext)
        // Then
        XCTAssertEqual(4, spots.count)
        XCTAssertEqual("NewSpot", spots.first?.title)
    }

    func testSavedAWrongCategorySpot_WhenGetTheSpot_ThenCategoryIsUnknown() {
        // Given
        TestableData.saveFakeSpot(date: Date(), category: "blabla", municipality: "blabla")
        // When
        let spots = Spot.getSpots(context: viewContext)
        // Then
        XCTAssertEqual(1, spots.count)
        XCTAssertEqual(Spot.Category.unknown, spots.first?.category)
        XCTAssertEqual(Spot.Municipality.unknown, spots.first?.municipality)
    }

    // MARK: - Favorite

    func testSpotsAreSaved_WhenSaveASpotsToFavorite_ThenSpotIsFavorite() {
        TestableData.saveFakeSpots()
        let spots = Spot.getSpots(context: viewContext)
        XCTAssertEqual(3, spots.count)
        XCTAssertFalse(spots.first!.isFavorite(context: self.viewContext))
        var favoriteSpots = Spot.getFavorites(context: self.viewContext)
        XCTAssertEqual(0, favoriteSpots.count)
        // When
        XCTAssertTrue(spots.first!.saveToFavorite(context: self.viewContext))
        XCTAssertTrue(spots.last!.saveToFavorite(context: self.viewContext))
        // Then
        XCTAssertTrue(spots.first!.isFavorite(context: self.viewContext))
        favoriteSpots = Spot.getFavorites(context: self.viewContext)
        XCTAssertEqual(2, favoriteSpots.count)
    }

    func testSpotsAreSaved_WhenSaveASpotTwiceToFavorite_ThenError() {
        TestableData.saveFakeSpots()
        let spots = Spot.getSpots(context: viewContext)
        XCTAssertEqual(3, spots.count)
        XCTAssertFalse(spots.first!.isFavorite(context: self.viewContext))
        var favoriteSpots = Spot.getFavorites(context: self.viewContext)
        XCTAssertEqual(0, favoriteSpots.count)
        // When
        XCTAssertTrue(spots.first!.saveToFavorite(context: self.viewContext))
        // Then
        XCTAssertFalse(spots.first!.saveToFavorite(context: self.viewContext))
        favoriteSpots = Spot.getFavorites(context: self.viewContext)
        XCTAssertEqual(1, favoriteSpots.count)
    }

    func testTwoSpotsSavedToFavorite_WhenRemoveOneToFavorite_ThenThereIsOneFavorite() {
        TestableData.saveFakeSpots()
        let spots = Spot.getSpots(context: viewContext)
        XCTAssertEqual(3, spots.count)
        XCTAssertTrue(spots.first!.saveToFavorite(context: self.viewContext))
        XCTAssertTrue(spots.first!.isFavorite(context: self.viewContext))
        XCTAssertTrue(spots.last!.saveToFavorite(context: self.viewContext))
        XCTAssertTrue(spots.last!.isFavorite(context: self.viewContext))
        var favoriteSpots = Spot.getFavorites(context: self.viewContext)
        XCTAssertEqual(2, favoriteSpots.count)
        // When
        XCTAssertTrue(spots.first!.removeToFavorite(context: self.viewContext))
        // Then
        favoriteSpots = Spot.getFavorites(context: self.viewContext)
        XCTAssertEqual(1, favoriteSpots.count)
    }

    func testSpotSavedToFavorite_WhenRemoveTwiceToFavorite_ThenError() {
        TestableData.saveFakeSpots()
        let spots = Spot.getSpots(context: viewContext)
        XCTAssertEqual(3, spots.count)
        XCTAssertTrue(spots.first!.saveToFavorite(context: self.viewContext))
        XCTAssertTrue(spots.first!.isFavorite(context: self.viewContext))
        var favoriteSpots = Spot.getFavorites(context: self.viewContext)
        XCTAssertEqual(1, favoriteSpots.count)
        // When
        XCTAssertTrue(spots.first!.removeToFavorite(context: self.viewContext))
        // Then
        XCTAssertFalse(spots.first!.removeToFavorite(context: self.viewContext))
        favoriteSpots = Spot.getFavorites(context: self.viewContext)
        XCTAssertEqual(0, favoriteSpots.count)
    }

    func testOldSpotSavedToFavorite_WhenGetFavorites_ThenDisplayFavoritesOrderedByDate() {
        TestableData.saveFakeSpots()
        let date = TestableData.getDate(year: 1900, month: 01, day: 1)
        let spots = Spot.getSpots(context: viewContext)
        XCTAssertTrue(spots[0].saveToFavorite(context: viewContext))
        XCTAssertTrue(spots[1].saveToFavorite(context: viewContext, date: date))
        XCTAssertEqual(spots[1].title, "La Plage de la Caravelle")
        XCTAssertTrue(spots[2].saveToFavorite(context: viewContext))
        // When
        let favorites = Spot.getFavorites(context: viewContext)
        XCTAssertEqual(favorites[0].title, "La Plage de la Caravelle")
    }

    // MARK: - Search

    func testSpotsSaved_WhenSearchAWordThatExistInTitles_ThenReturnSpots() {
        // Given
        XCTAssertEqual(0, Spot.getSpots(context: viewContext).count)
        TestableData.saveFakeSpots()
        XCTAssertEqual(3, Spot.getSpots(context: viewContext).count)
        // When
        let result = Spot.searchSpots(context: viewContext, titleContains: "plage")
        // Then
        XCTAssertEqual(result.count, 2)
        let title1 = result.first!.title
        XCTAssertTrue(title1.localizedCaseInsensitiveContains("plage"))
    }

    func testSpotsSaved_WhenSearchAWordThatNOTExistInTitles_ThenReturnError() {
        // Given
        XCTAssertEqual(0, Spot.getSpots(context: viewContext).count)
        TestableData.saveFakeSpots()
        XCTAssertEqual(3, Spot.getSpots(context: viewContext).count)
        // When
        let result = Spot.searchSpots(context: viewContext, titleContains: "route")
        // Then
        XCTAssertEqual(result.count, 0)
    }

    func testSpotsSaved_WhenSearchEmptyWord_ThenReturnError() {
        // Given
        XCTAssertEqual(0, Spot.getSpots(context: viewContext).count)
        TestableData.saveFakeSpots()
        XCTAssertEqual(3, Spot.getSpots(context: viewContext).count)
        // When
        let result1 = Spot.searchSpots(context: viewContext, titleContains: " ")
        let result2 = Spot.searchSpots(context: viewContext, titleContains: "")
        // Then
        XCTAssertEqual(result1.count, 0)
        XCTAssertEqual(result2.count, 0)
    }

    func testNoSpotsSaved_WhenSearchWord_ThenReturnError() {
        // Given
        XCTAssertEqual(0, Spot.getSpots(context: viewContext).count)
        // When
        let result = Spot.searchSpots(context: viewContext, titleContains: "plage")
        // Then
        XCTAssertEqual(result.count, 0)
    }

    // MARK: - Cloudkit

    func testCloudKit() {
        let expextation = XCTestExpectation(description: "Fetching Spots")
        Spot.fetchSpots { spots in
            print("->>> \(spots.count)")
            print("⭕️ \(spots.first!.title) - \(spots.first!.creationDate.description)")
            expextation.fulfill()
        }
        wait(for: [expextation], timeout: 10.0)
    }

}
