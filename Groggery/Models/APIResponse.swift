import Foundation

/// #Models/ApiResponseDrinks
struct ApiResponseDrinks: Codable {
    var drinks: [Cocktail] // DrinksValueResponse;
}

/// #Models/ApiResponseIngredients
struct ApiResponseIngredients: Codable {
    var drinks: [Ingredient]
}
