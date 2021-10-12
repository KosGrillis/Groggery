import Foundation

/// #CocktailDataController
///
/// Singleton model controller used by view controllers to access data related to Cocktails.
/// Access via CocktailDataController.sharedInstance
class CocktailDataController {
    static let sharedInstance = CocktailDataController()
   
    private var cocktails = CocktailCollection()
    private var allIngredients = IngredientCollection()
    private var searchHistory: [String: [Cocktail]] = [:]
    
    func searchFor(query: String, completion: @escaping (([Cocktail]) -> Void)) {
        let safeSearchQuery = query
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ", ", with: ",")
        
        // Immediately return already known results if a search query is repeated
        if let previousSearch = self.searchHistory[safeSearchQuery] {
            completion(previousSearch)
            return
        }
        
        // Only need to fetch all ingredients once, the first time a user makes a search
        // Subsequent searches will use pre-fetched ingredients for faster response time
        if (self.allIngredients.count == 0) {
            let ingredientsUrl = API.urlFor(route: API.urlRoutes.list, params: ["i": "list"])
            let ingredientsUrlRequest = URLRequest(url: ingredientsUrl)

            URLSession.shared.blockingRequest(ingredientsUrlRequest) { (_ result: Result<ApiResponseIngredients, Error>) in
                switch result {
                    case let .failure(error):
                        return print(error)
                    case let .success(apiResponseIngredients):
                        self.allIngredients = IngredientCollection.fromApiResponse(response: apiResponseIngredients)
                }
            }
        }
        
        let drinksUrl: URL
        if (query.contains(",")) {
            // If searchQuery contains a comma, assume user intent is to filter by multiple ingredients
            drinksUrl = API.urlFor(route: API.urlRoutes.filter, params: ["i":"\(safeSearchQuery)"])
        } else if (self.allIngredients.contains(ingredient: query)) {
            // Else if the search query is a single ingredient, assumer user intent is to filter by a single ingredient
            drinksUrl = API.urlFor(route: API.urlRoutes.filter, params: ["i":"\(safeSearchQuery)"])
        } else {
            // Else, assume user intent is to search for a specific cocktail
            drinksUrl = API.urlFor(route: API.urlRoutes.search, params: ["s":"\(safeSearchQuery)"])
        }

        let drinksUrlRequest = URLRequest(url: drinksUrl)
        URLSession.shared.request(drinksUrlRequest) { (_ result: Result<ApiResponseDrinks, Error>) in
            switch result {
                case .failure(_):
                    completion([])
                case let .success(apiResponseDrinks):
                    self.cocktails.addMany(array: apiResponseDrinks.drinks)
                    self.searchHistory[safeSearchQuery] = apiResponseDrinks.drinks

                    completion(apiResponseDrinks.drinks)
            }
        }
    }
    
    func requestBy(cocktailId: String, completion: @escaping ((Cocktail) -> Void)) {
        if let alreadyKnownData = self.cocktails.getById(id: cocktailId) {
            completion(alreadyKnownData)
        }
        
        let lookupUrl = API.urlFor(route: API.urlRoutes.lookup, params: ["i": "\(cocktailId)"])
        let lookupUrlRequest = URLRequest(url: lookupUrl)
        
        URLSession.shared.request(lookupUrlRequest) { (_ result: Result<ApiResponseDrinks, Error>) in
            switch result {
                case .failure(_):
                    return // TODO: do nothing? What to do here
                case let .success(apiResponseDrinks):
                    self.cocktails.addMany(array: apiResponseDrinks.drinks)
                    completion(apiResponseDrinks.drinks[0])
            }
        }
    }
    
    func downloadImageFor(cocktailId: String, completion: @escaping ((Data) -> Void)) {
        guard let cocktailForId = self.cocktails.getById(id: cocktailId) else {
            return assertionFailure("Cocktail for given ID does not exist")
        }
        
        let task = URLSession.shared.dataTask(with: cocktailForId.imageUrl!) { (data, response, error) in
            if let imageData = data {
                completion(imageData)
            }
        }
        
        task.resume()
    }
    
    /// #CocktailDataController/addCocktailsToCollection
    ///
    /// Allows other model controllers (like FavouritesDataController) to cache already known cocktails without making an API call
    func addCocktailsToCollection(cocktails: [Cocktail]) {
        self.cocktails.addMany(array: cocktails)
    }
}
