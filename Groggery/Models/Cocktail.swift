import Foundation

/// #Models/Cocktail
struct Cocktail: Codable {
    var id: String
    var name: String
    var glass: String? // Literally the glass that the cocktail is served in
    var category: String?
    var instructions: String?
    var ingredientsArrays: [[String]]? // NOTE: this can be encoded to plist
    var ingredientsTuples: [(String, String)]? // ALSO NOTE: this cannot. TODO: Should use core data to avoid this hack

    var tags: [String?] { return [self.category, self.glass, "Serves 1"] }
    
    var imageUrl: URL? { return URL(string: self.imageUrlString) }
    var imageUrlString: String
    
    var thumbnailUrl: URL? { return URL(string: self.thumbnailUrlString) }
    var thumbnailUrlString: String { return "\(self.imageUrlString)/preview" }

    init(from decoder: Decoder) throws {
        let knownKeysDecoder = try decoder.container(keyedBy: CodingKeys.self)
        let unknownKeysDecoder = try decoder.container(keyedBy: DynamicCodingKeys.self)

        // First decode the known keys
        self.id = try knownKeysDecoder.decode(String.self, forKey: .id)
        self.name = try knownKeysDecoder.decode(String.self, forKey: .name)
        self.glass = try knownKeysDecoder.decodeIfPresent(String.self, forKey: .glass)
        self.category = try knownKeysDecoder.decodeIfPresent(String.self, forKey: .category)
        self.instructions = try knownKeysDecoder.decodeIfPresent(String.self, forKey: .instructions)
        self.imageUrlString = try knownKeysDecoder.decode(String.self, forKey: .imageUrlString)
        self.ingredientsArrays = try knownKeysDecoder.decodeIfPresent([[String]].self, forKey: .ingredientsArrays)
        
        // Next decode the unknown keys
        // API keys for ingredients and measurements are of form "strIngredient1", "strIngredient2", "strMeasure1" ...
        // all the way up to 15. To avoid excessive boilerplate code, we loop over all keys and assign ingredients
        // and associated measurements to an array of tuples for easy consumption
        var rawIngredients: [String] = [], rawMeasurements: [String] = []

        for key in unknownKeysDecoder.allKeys.sorted() {
            if (key.stringValue.starts(with: "strIngredient")) {
                if let decoded = try unknownKeysDecoder.decodeIfPresent(String.self, forKey: DynamicCodingKeys(stringValue: key.stringValue)!) {
                    rawIngredients.append(decoded)
                }
            } else if (key.stringValue.starts(with: "strMeasure")) {
                if let decoded = try unknownKeysDecoder.decodeIfPresent(String.self, forKey: DynamicCodingKeys(stringValue: key.stringValue)!) {
                    rawMeasurements.append(decoded)
                }
            }
        }
        
        let ingredientsTuples = Array(zip(rawIngredients, rawMeasurements))
        let ingredientsArrays: [[String]] = ingredientsTuples.map { [ $0.0, $0.1 ] }
            
        self.ingredientsTuples = ingredientsTuples
        if (self.ingredientsArrays == nil) { self.ingredientsArrays = ingredientsArrays }
    }
    
    private enum CodingKeys: String, CodingKey {
        case id = "idDrink"
        case name = "strDrink"
        case glass = "strGlass"
        case category = "strIBA"
        case ingredientsArrays // Must be here for encoding to work!
        case instructions = "strInstructions"
        case imageUrlString = "strDrinkThumb"
    }
    
    private struct DynamicCodingKeys: CodingKey, Comparable {
        var stringValue: String
        init?(stringValue: String) { self.stringValue = stringValue }
        
        var intValue: Int? // Our keys aren't int-keyed, can ignore this
        init?(intValue: Int) { return nil }
        
        // Used to maintain order of integer-suffixed keys, like ingredients and their measurements
        // (the API assigns the number suffix by importance); Swift decoders to not maintain key order
        static func < (lhs: Cocktail.DynamicCodingKeys, rhs: Cocktail.DynamicCodingKeys) -> Bool {
            return lhs.stringValue < rhs.stringValue
        }
    }
}

/// #Models/CocktailCollection
///
/// Basic implementation of the GoF Composite pattern allowing many cocktails to be managed as a single object,
/// allowing quick lookup of by cocktail ID etc
class CocktailCollection {
    private var cocktailsMap: [String: Cocktail] = [:]
        
    func getById(id: String) -> Cocktail? {
        if let foundCocktail = self.cocktailsMap[id] {
            return foundCocktail
        }

        return nil
    }
    
    func addOne(cocktail: Cocktail) {
        // If the cocktail does not already exist in the collection, add it
        guard let alreadyExists = self.cocktailsMap[cocktail.id] else {
            self.cocktailsMap[cocktail.id] = cocktail
            return
        }
        
        // Else, check if the new cocktail has more information than the existing
        // one. If it does, add it to the collection, replacing the old one
        if (alreadyExists.instructions == nil && cocktail.instructions != nil) {
            self.cocktailsMap[cocktail.id] = cocktail
        }
    }

    func addMany(array: [Cocktail]) {
        for cocktail in array {
            self.addOne(cocktail: cocktail)
        }
    }
}
