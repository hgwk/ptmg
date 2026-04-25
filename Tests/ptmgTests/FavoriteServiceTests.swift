import XCTest
@testable import ptmg

final class FavoriteServiceTests: XCTestCase {
    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: "favoritePorts")
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "favoritePorts")
        super.tearDown()
    }

    func testEmptyFavorites() {
        let favorites = FavoriteService.getFavorites()
        XCTAssertTrue(favorites.isEmpty)
    }

    func testIsFavoriteNotSet() {
        XCTAssertFalse(FavoriteService.isFavorite(port: 3000))
    }
}
