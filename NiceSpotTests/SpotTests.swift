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

    override class func setUp() {
//        let expectation = XCTestExpectation(description: "Wait 2 seconds before starting tests")
//        _ = XCTWaiter.wait(for: [expectation], timeout: 3.0)
        super.setUp()
    }

    override func setUp() {
        super.setUp()
        self.viewContext = PersistenceController.tests.container.viewContext
    }

    override func tearDown() {
        let expectation = XCTestExpectation(description: "Clear Data")
        TestableData.clearData { _ in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
        super.tearDown()
    }

    func testOldSpotSaved_WenGetAllSpots_TheNewSpotSavedOnLast() {
        // Given
        TestableData.saveFakeSpots()
        let date = TestableData.getDate(year: 1900, month: 01, day: 1)
        TestableData.saveFakeSpot(date: date, category: "blabla", municipality: "blabla")
        // When
        Spot.getSpots(context: viewContext) { result in
            switch result {
            case .failure(let error):
                XCTFail("\(error.localizedDescription)")
            case .success(let spots):
                // Then
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
        let completion: (Result<[Spot], Error>) -> Void = { result in
            switch result {
            case .failure(let error):
                XCTFail("\(error.localizedDescription)")
            case .success(let spots):
                // Then
                XCTAssertEqual(4, spots.count)
                XCTAssertEqual("NewSpot", spots.first?.title)
            }
        }

        Spot.getSpots(context: viewContext, completion: completion)
    }

    func testSavedAWrongCategorySpot_WhenGetTheSpot_ThenCategoryIsUnknown() {
        // Given
        TestableData.saveFakeSpot(date: Date(), category: "blabla", municipality: "blabla")
        // When
        Spot.getSpots(context: viewContext) { result in
            switch result {
            case .failure(let error):
                XCTFail("\(error.localizedDescription)")
            case .success(let spots):
                // Then
                XCTAssertEqual(1, spots.count)
                XCTAssertEqual(Spot.Category.unknown, spots.first?.category)
                XCTAssertEqual(Spot.Municipality.unknown, spots.first?.municipality)
            }
        }
    }

    // MARK: - Favorite

    func testSpotsAreSaved_WhenSaveASpotsToFavorite_ThenSpotIsFavorite() {
        TestableData.saveFakeSpots()
        var expectation = XCTestExpectation(description: "Get Spots")
        var spots: [Spot] = []
        Spot.getSpots(context: viewContext) { result in
            switch result {
            case .failure(let error):
                XCTFail("\(error.localizedDescription)")
            case .success(let spotsResult):
                spots = spotsResult
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
        XCTAssertEqual(3, spots.count)
        XCTAssertFalse(spots.first!.isFavorite(context: self.viewContext))
        expectation = XCTestExpectation(description: "Get Favorites")
        var favorites: [Spot] = []
        Spot.getFavorites(context: viewContext) { result in
            switch result {
            case .failure(let error):
                XCTFail("\(error.localizedDescription)")
            case .success(let favoritesResult):
                favorites = favoritesResult
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
        XCTAssertEqual(0, favorites.count)
        // When
        var resultSaveSpot = spots.first!.saveToFavorite(context: viewContext)
        switch resultSaveSpot {
        case .failure(let error):
            XCTFail("\(error.localizedDescription)")
        case .success(let success):
            XCTAssertTrue(success)
        }
        resultSaveSpot = spots.last!.saveToFavorite(context: viewContext)
        switch resultSaveSpot {
        case .failure(let error):
            XCTFail("\(error.localizedDescription)")
        case .success(let success):
            XCTAssertTrue(success)
        }
        // Then
        XCTAssertTrue(spots.first!.isFavorite(context: self.viewContext))
        expectation = XCTestExpectation(description: "Get Favorites")
        Spot.getFavorites(context: viewContext) { result in
            switch result {
            case .failure(let error):
                XCTFail("\(error.localizedDescription)")
            case .success(let favoritesResult):
                favorites = favoritesResult
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
        XCTAssertEqual(2, favorites.count)
    }

    func testSpotsAreSaved_WhenSaveASpotTwiceToFavorite_ThenError() {
        TestableData.saveFakeSpots()
        var expectation = XCTestExpectation(description: "Get Spots")
        var spots: [Spot] = []
        Spot.getSpots(context: viewContext) { result in
            switch result {
            case .failure(let error):
                XCTFail("\(error.localizedDescription)")
            case .success(let spotsResult):
                spots = spotsResult
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
        XCTAssertEqual(3, spots.count)
        XCTAssertFalse(spots.first!.isFavorite(context: self.viewContext))
        expectation = XCTestExpectation(description: "Get Favorites")
        var favorites: [Spot] = []
        Spot.getFavorites(context: viewContext) { result in
            switch result {
            case .failure(let error):
                XCTFail("\(error.localizedDescription)")
            case .success(let favoritesResult):
                favorites = favoritesResult
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
        XCTAssertEqual(0, favorites.count)
        // When
        var resultSaveSpot = spots.first!.saveToFavorite(context: viewContext)
        switch resultSaveSpot {
        case .failure(let error):
            XCTFail("\(error.localizedDescription)")
        case .success(let success):
            XCTAssertTrue(success)
        }
        resultSaveSpot = spots.first!.saveToFavorite(context: viewContext)
        switch resultSaveSpot {
        case .failure(let error):
            XCTAssertEqual("Fail fav a spot that's already faved", error.localizedDescription)
        case .success:
            XCTFail()
        }
        favorites = []
        expectation = XCTestExpectation(description: "Get Favorites")
        Spot.getFavorites(context: viewContext) { result in
            switch result {
            case .failure(let error):
                XCTFail("\(error.localizedDescription)")
            case .success(let favoritesResult):
                favorites = favoritesResult
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
        XCTAssertEqual(1, favorites.count)
    }

    func testTwoSpotsSavedToFavorite_WhenRemoveOneToFavorite_ThenThereIsOneFavorite() {
        TestableData.saveFakeSpots()
        var expectation = XCTestExpectation(description: "Get Spots")
        var spots: [Spot] = []
        Spot.getSpots(context: viewContext) { result in
            switch result {
            case .failure(let error):
                XCTFail("\(error.localizedDescription)")
            case .success(let spotsResult):
                spots = spotsResult
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
        XCTAssertEqual(3, spots.count)
        XCTAssertFalse(spots.first!.isFavorite(context: self.viewContext))
        var resultSaveSpot = spots.first!.saveToFavorite(context: viewContext)
        switch resultSaveSpot {
        case .failure(let error):
            XCTFail("\(error.localizedDescription)")
        case .success(let success):
            XCTAssertTrue(success)
        }
        XCTAssertTrue(spots.first!.isFavorite(context: self.viewContext))
        resultSaveSpot = spots.last!.saveToFavorite(context: viewContext)
        switch resultSaveSpot {
        case .failure(let error):
            XCTFail("\(error.localizedDescription)")
        case .success(let success):
            XCTAssertTrue(success)
        }
        XCTAssertTrue(spots.last!.isFavorite(context: self.viewContext))
        // When
        let resultRemoveSpot = spots.first!.removeToFavorite(context: viewContext)
        switch resultRemoveSpot {
        case .failure(let error):
            XCTFail("\(error.localizedDescription)")
        case .success(let success):
            XCTAssertTrue(success)
        }
        // Then
        var favorites: [Spot] = []
        expectation = XCTestExpectation(description: "Get Favorites")
        Spot.getFavorites(context: viewContext) { result in
            switch result {
            case .failure(let error):
                XCTFail("\(error.localizedDescription)")
            case .success(let favoritesResult):
                favorites = favoritesResult
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
        XCTAssertEqual(1, favorites.count)
    }

    func testSpotSavedToFavorite_WhenRemoveTwiceToFavorite_ThenError() {
        TestableData.saveFakeSpots()
        var expectation = XCTestExpectation(description: "Get Spots")
        var spots: [Spot] = []
        Spot.getSpots(context: viewContext) { result in
            switch result {
            case .failure(let error):
                XCTFail("\(error.localizedDescription)")
            case .success(let spotsResult):
                spots = spotsResult
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
        XCTAssertEqual(3, spots.count)
        XCTAssertFalse(spots.first!.isFavorite(context: self.viewContext))
        var resultSaveSpot = spots.first!.saveToFavorite(context: viewContext)
        switch resultSaveSpot {
        case .failure(let error):
            XCTFail("\(error.localizedDescription)")
        case .success(let success):
            XCTAssertTrue(success)
        }
        XCTAssertTrue(spots.first!.isFavorite(context: self.viewContext))
        resultSaveSpot = spots.last!.saveToFavorite(context: viewContext)
        switch resultSaveSpot {
        case .failure(let error):
            XCTFail("\(error.localizedDescription)")
        case .success(let success):
            XCTAssertTrue(success)
        }
        XCTAssertTrue(spots.last!.isFavorite(context: self.viewContext))
        // When
        var resultRemoveSpot = spots.first!.removeToFavorite(context: viewContext)
        switch resultRemoveSpot {
        case .failure(let error):
            XCTFail("\(error.localizedDescription)")
        case .success(let success):
            XCTAssertTrue(success)
        }
        resultRemoveSpot = spots.first!.removeToFavorite(context: viewContext)
        switch resultRemoveSpot {
        case .failure(let error):
            // Then
            XCTAssertEqual("Fail unfav a spot that's already unfaved", error.localizedDescription)
        case .success:
            XCTFail()
        }
        var favorites: [Spot] = []
        expectation = XCTestExpectation(description: "Get Favorites")
        Spot.getFavorites(context: viewContext) { result in
            switch result {
            case .failure(let error):
                XCTFail("\(error.localizedDescription)")
            case .success(let favoritesResult):
                favorites = favoritesResult
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
        XCTAssertEqual(1, favorites.count)
    }

    func testOldSpotSavedToFavorite_WhenGetFavorites_ThenDisplayFavoritesOrderedByDate() {
        TestableData.saveFakeSpots()
        let date = TestableData.getDate(year: 1900, month: 01, day: 1)
        var expectation = XCTestExpectation(description: "Get Spots")
        var spots: [Spot] = []
        Spot.getSpots(context: viewContext) { result in
            switch result {
            case .failure(let error):
                XCTFail("\(error.localizedDescription)")
            case .success(let spotsResult):
                spots = spotsResult
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
        XCTAssertEqual(3, spots.count)
        var resultSaveSpot = spots[0].saveToFavorite(context: viewContext)
        switch resultSaveSpot {
        case .failure(let error):
            XCTFail("\(error.localizedDescription)")
        case .success(let success):
            XCTAssertTrue(success)
        }
        resultSaveSpot = spots[1].saveToFavorite(context: viewContext, date: date)
        switch resultSaveSpot {
        case .failure(let error):
            XCTFail("\(error.localizedDescription)")
        case .success(let success):
            XCTAssertTrue(success)
        }
        XCTAssertEqual(spots[1].title, "La Plage de la Caravelle New")
        resultSaveSpot = spots[2].saveToFavorite(context: viewContext)
        switch resultSaveSpot {
        case .failure(let error):
            XCTFail("\(error.localizedDescription)")
        case .success(let success):
            XCTAssertTrue(success)
        }
        // When
        var favorites: [Spot] = []
        expectation = XCTestExpectation(description: "Get Favorites")
        Spot.getFavorites(context: viewContext) { result in
            switch result {
            case .failure(let error):
                XCTFail("\(error.localizedDescription)")
            case .success(let favoritesResult):
                favorites = favoritesResult
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
        XCTAssertEqual(favorites[0].title, "La Plage de la Caravelle New")
    }

//    // MARK: - Search
//
//    func testSpotsSaved_WhenSearchAWordThatExistInTitles_ThenReturnSpots() {
//        // Given
//        XCTAssertEqual(0, Spot.getSpots(context: viewContext).count)
//        TestableData.saveFakeSpots()
//        XCTAssertEqual(3, Spot.getSpots(context: viewContext).count)
//        // When
//        let result = Spot.searchSpots(context: viewContext, titleContains: "plage")
//        // Then
//        XCTAssertEqual(result.count, 2)
//        let title1 = result.first!.title
//        XCTAssertTrue(title1.localizedCaseInsensitiveContains("plage"))
//    }
//
//    func testSpotsSaved_WhenSearchAWordThatNOTExistInTitles_ThenReturnError() {
//        // Given
//        XCTAssertEqual(0, Spot.getSpots(context: viewContext).count)
//        TestableData.saveFakeSpots()
//        XCTAssertEqual(3, Spot.getSpots(context: viewContext).count)
//        // When
//        let result = Spot.searchSpots(context: viewContext, titleContains: "route")
//        // Then
//        XCTAssertEqual(result.count, 0)
//    }
//
//    func testSpotsSaved_WhenSearchEmptyWord_ThenReturnError() {
//        // Given
//        XCTAssertEqual(0, Spot.getSpots(context: viewContext).count)
//        TestableData.saveFakeSpots()
//        XCTAssertEqual(3, Spot.getSpots(context: viewContext).count)
//        // When
//        let result1 = Spot.searchSpots(context: viewContext, titleContains: " ")
//        let result2 = Spot.searchSpots(context: viewContext, titleContains: "")
//        // Then
//        XCTAssertEqual(result1.count, 0)
//        XCTAssertEqual(result2.count, 0)
//    }
//
//    func testNoSpotsSaved_WhenSearchWord_ThenReturnError() {
//        // Given
//        XCTAssertEqual(0, Spot.getSpots(context: viewContext).count)
//        // When
//        let result = Spot.searchSpots(context: viewContext, titleContains: "plage")
//        // Then
//        XCTAssertEqual(result.count, 0)
//    }
//
//    // MARK: - Save
//
//    func testSpotsAreSaved_WhenSaveItAgain_ThenItIsMerged() {
//        TestableData.saveFakeSpots()
//        XCTAssertEqual(3, Spot.getSpots(context: viewContext).count)
//    }

    // MARK: - Cloudkit

    func testRefreshSpots() {
        let expectation = XCTestExpectation(description: "Get Spots")
        var spots: [Spot] = []
        Spot.getSpots(context: viewContext) { result in
            switch result {
            case .failure(let error):
                XCTFail("\(error.localizedDescription)")
            case .success(let spotsResult):
                spots = spotsResult
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
        XCTAssertEqual(0, spots.count)
        // When
        let expectation2 = XCTestExpectation(description: "Refresh Spots")
        Spot.refreshSpots(context: viewContext) { result in
            switch result {
            case .failure(let error):
                XCTFail("\(error.localizedDescription) ❌")
            case .success(let success):
                XCTAssertTrue(success)
            }
            expectation2.fulfill()
        }
        wait(for: [expectation2], timeout: 10.0)
        // Then
        let expectation3 = XCTestExpectation(description: "Get Spots")
        spots = []
        Spot.getSpots(context: viewContext) { result in
            switch result {
            case .failure(let error):
                XCTFail("\(error.localizedDescription)")
            case .success(let spotsResult):
                spots = spotsResult
            }
            expectation3.fulfill()
        }
        wait(for: [expectation3], timeout: 10.0)
        XCTAssertEqual(9, spots.count)
    }
    
}
