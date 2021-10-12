import Foundation

/// #Models/API
///
/// Encapsulates API config, acting as a facade to the API implementation.
/// Usage example: API.urlFor(route: API.urlRoutes.list, params: [...])
struct API {
    static let key = "YOUR_API_KEY_HERE"
    static let baseUrl = "https://www.thecocktaildb.com/api/json/v2"
    
    enum urlRoutes: String {
        case list = "list.php"
        case search = "search.php"
        case filter = "filter.php"
        case lookup = "lookup.php"
    }
    
    static func urlFor(route: API.urlRoutes, params: [String: String]) -> URL {
        let baseUrl = "\(API.baseUrl)/\(API.key)/\(route.rawValue)"
        
        var urlComponents = URLComponents(string: baseUrl)
        urlComponents?.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        return urlComponents!.url!
    }
}
