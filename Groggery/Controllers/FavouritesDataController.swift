import Foundation

/// #FavouritesDataController
///
/// Acts as a facade to stored Cocktails using plist.
/// TODO: This is probably better implemented using core data
class FavouritesDataController {
    static var ENCODER = PropertyListEncoder()
    static var DECODER = PropertyListDecoder()
    static var STORAGE_URL
        = FileManager
            .default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("groggery_favourites")
            .appendingPathExtension("plist")
    
    static func retrieveAll() -> [Cocktail] {        
        guard let retrievedCocktails = try? Data(contentsOf: FavouritesDataController.STORAGE_URL) else {
            return []
        }
        guard let decodedRetrievedCocktails = try? FavouritesDataController.DECODER.decode([Cocktail].self, from: retrievedCocktails) else {
            return []
        }
        
        CocktailDataController.sharedInstance.addCocktailsToCollection(cocktails: decodedRetrievedCocktails)
        return decodedRetrievedCocktails
    }
    
    static func isFavourite(cocktailId: String) -> Bool {
        if FavouritesDataController.retrieveAll().first(where: { $0.id == cocktailId }) != nil {
            return true
        }

        return false
    }
    
    static func addToFavourites(cocktail: Cocktail) -> Bool {
        var existingFavourites = FavouritesDataController.retrieveAll()
        existingFavourites.append(cocktail)
        return FavouritesDataController.writeToDisk(cocktails: existingFavourites)
    }
    
    static func removeFromFavourites(cocktail: Cocktail) -> Bool {
        var existingFavourites = FavouritesDataController.retrieveAll()
        existingFavourites.removeAll(where: { $0.id == cocktail.id })
        
        guard FavouritesDataController.clearFavourites() else {
            return false
        }
        guard existingFavourites.count > 0 else {
            return true
        }
        
        return FavouritesDataController.writeToDisk(cocktails: existingFavourites)
    }
    
    private static func clearFavourites() -> Bool {
        do {
            try FileManager.default.removeItem(at: STORAGE_URL)
            return true
        } catch {
            return false
        }
    }
    
    private static func writeToDisk(cocktails: [Cocktail]) -> Bool {
        do {
            let encodedCocktail = try FavouritesDataController.ENCODER.encode(cocktails)
            try encodedCocktail.write(to: FavouritesDataController.STORAGE_URL, options: .noFileProtection)
            return true
        } catch {
            return false
        }
    }
}
