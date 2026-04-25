import Foundation

final class FavoriteService {
    private static let favoritesKey = DefaultsKey.favoritePorts.rawValue
    private static let defaults = UserDefaults.standard
    private static var cachedFavorites: Set<Int>?
    private static let lock = NSLock()

    static func getFavorites() -> Set<Int> {
        lock.lock()
        defer { lock.unlock() }
        if let cached = cachedFavorites { return cached }
        let array = defaults.array(forKey: favoritesKey) as? [Int] ?? []
        let favorites = Set(array)
        cachedFavorites = favorites
        return favorites
    }

    static func isFavorite(port: Int) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return getFavorites().contains(port)
    }

    private static func saveFavorites(_ favorites: Set<Int>) {
        let array = favorites.sorted()
        defaults.set(array, forKey: favoritesKey)
        cachedFavorites = favorites
    }
}
