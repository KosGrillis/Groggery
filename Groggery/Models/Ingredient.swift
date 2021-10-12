import Foundation

/// #Models/Ingredient
struct Ingredient: Codable {
    var name: String

    private enum CodingKeys: String, CodingKey {
        case name = "strIngredient1"
    }
}

/// #Models/IngredientCollection
///
/// Basic implementation of the GoF Composite pattern allowing all possible ingredients to be managed as a single object,
/// allowing quick lookup of ingredients etc
struct IngredientCollection {
    var count: Int { return self.ingredients.count }
    var ingredients: [Ingredient]
    
    init() {
        self.init(ingredients: [])
    }
    init(ingredients: [Ingredient]) {
        self.ingredients = ingredients
    }
    
    static func fromApiResponse(response: ApiResponseIngredients) -> IngredientCollection {
        return IngredientCollection(ingredients: response.drinks)
    }
    
    func contains(ingredient: String) -> Bool {
        if self.ingredients.firstIndex(where: { $0.name.lowercased() == ingredient.lowercased() }) != nil {
            return true
        }
        
        return false
    }
}
